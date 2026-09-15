-- rgflow owns the quickfix lists. Telescope is a disposable, read-only view.
local M = {}
local context_key = 'rgflow_telescope'

local function notify(message)
    vim.notify(message, vim.log.levels.INFO, { title = 'RgFlow' })
end

local function idle()
    -- Only private dependency: rgflow appends to the CURRENT list, not a list ID.
    -- Its public completion callback misses small/empty searches, so it cannot
    -- safely guard history switching. Never read its result queue or buffer IDs.
    local ok, state = pcall(require, 'rgflow.state')
    local has_modes, modes = pcall(require, 'rgflow.modes')
    if not ok or not has_modes then
        notify('rgflow is unavailable; install it with Packer first')
        return false
    end
    local mode = state.get_state().mode
    if mode == modes.SEARCHING or mode == modes.ADDING or mode == modes.ABORTING or mode == modes.OPEN then
        notify('Finish/close the rgflow search form or wait for the search before opening saved results')
        return false
    end
    return true
end

local function metadata(id)
    return vim.fn.getqflist({ id = id, nr = 0, title = 0, size = 0, context = 0, changedtick = 0 })
end

local function tagged(info)
    return info and info.id ~= 0 and type(info.context) == 'table'
        and type(info.context[context_key]) == 'table'
end

-- Supported rgflow quickfix.open_qf_cmd_or_func hook, called after list creation.
function M.on_quickfix_open()
    local info = metadata(0)
    local context = type(info.context) == 'table' and info.context or {}
    context[context_key] = {
        -- Remove only the progress prefix for display; never parse result lines.
        -- Save the label because upstream can retitle an old list on a no-match search.
        label = info.title:match('| (.*)') or info.title,
    }
    vim.fn.setqflist({}, 'a', { id = info.id, context = context })
    vim.cmd.copen()
end

local function searches()
    local lists = {}
    -- Metadata only: bounded by native quickfix history, no reading every list's items.
    for nr = vim.fn.getqflist({ nr = '$' }).nr, 1, -1 do
        local info = vim.fn.getqflist({ nr = nr, id = 0, title = 0, size = 0, context = 0 })
        if tagged(info) then lists[#lists + 1] = info end
    end
    return lists
end

local function resolve(id)
    local info = id and metadata(id) or searches()[1]
    if not tagged(info) then
        notify('No retained rgflow results (the list may have expired from quickfix history)')
        return
    end
    return info
end

local function activate(id)
    local info = resolve(id)
    if not info then return end
    -- Native list selection, no copying/replacing of entries.
    vim.cmd('silent ' .. info.nr .. 'chistory')
    return info
end

function M.quickfix(id)
    if not idle() then return end
    local info = resolve(id)
    if info and activate(info.id) then vim.cmd.copen() end
end

local function telescope_modules()
    local ok, pickers = pcall(require, 'telescope.pickers')
    if not ok then
        notify('Telescope is unavailable; use :RgFlowQuickfix instead')
        return
    end
    return pickers, require('telescope.finders'), require('telescope.config').values,
        require('telescope.actions'), require('telescope.actions.state')
end

local function close_mappings(map, actions)
    for _, mode in ipairs({ 'i', 'n' }) do
        map(mode, '<Esc>', actions.close)
        -- This view already has a source quickfix list: do not export a second one.
        map(mode, '<C-q>', function() notify('Use :RgFlowQuickfix to reopen the original list') end)
        map(mode, '<M-q>', function() notify('Use rgflow quickfix mappings to filter/mark results') end)
    end
end

function M.results(id)
    if not idle() then return end
    local info = resolve(id)
    if not info then return end
    local pickers, finders, conf, actions, action_state = telescope_modules()
    if not pickers then return end
    local snapshot = vim.fn.getqflist({ id = info.id, items = 0, changedtick = 0 })
    if #snapshot.items == 0 then notify('This rgflow list is empty'); return end
    local opts = { cache_picker = false, path_display = { 'relative' }, show_line = true }
    local make_entry = require('telescope.make_entry').gen_from_quickfix(opts)
    local transform_path = require('telescope.utils').transform_path
    local function display(entry)
        local path, highlights = transform_path(opts, entry.filename)
        return string.format('%s:%d:%d  %s', path, entry.lnum, entry.col, entry.text), highlights
    end
    for index, item in ipairs(snapshot.items) do item.rgflow_index = index end
    pickers.new(opts, {
        prompt_title = 'RgFlow: ' .. info.context[context_key].label,
        finder = finders.new_table({
            results = snapshot.items,
            entry_maker = function(item)
                if item.valid == 1 and item.bufnr > 0 and vim.api.nvim_buf_is_valid(item.bufnr) then
                    local entry = make_entry(item)
                    entry.display = display
                    return entry
                end
            end,
        }),
        previewer = conf.qflist_previewer(opts),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            close_mappings(map, actions)
            local function select(split)
                local entry = action_state.get_current_picker(prompt_bufnr):get_selection()
                if not entry or not idle() then return end
                local current = metadata(info.id)
                if not tagged(current) or current.changedtick ~= snapshot.changedtick then
                    notify('Quickfix results changed; close and reopen the picker to read the current list')
                    return
                end
                actions.close(prompt_bufnr)
                if activate(info.id) then
                    if split then vim.cmd(split) end
                    -- :cc honours quickfix byte/virtual columns and adjusted line numbers.
                    local ok, err = pcall(vim.cmd, 'cc ' .. entry.value.rgflow_index)
                    if not ok then notify(tostring(err)) end
                end
            end
            actions.select_default:replace(function() select() end)
            actions.select_horizontal:replace(function() select('new') end)
            actions.select_vertical:replace(function() select('vnew') end)
            actions.select_tab:replace(function() select('tabnew') end)
            return true
        end,
    }):find()
end

function M.history()
    if not idle() then return end
    local lists = searches()
    if #lists == 0 then notify('No retained rgflow searches'); return end
    local pickers, finders, conf, actions, action_state = telescope_modules()
    if not pickers then return end
    pickers.new({ cache_picker = false }, {
        prompt_title = 'RgFlow search history',
        finder = finders.new_table({
            results = lists,
            entry_maker = function(info)
                local label = info.context[context_key].label
                return { value = info.id, ordinal = label,
                    display = string.format('%s  [%d matches]', label, info.size) }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            close_mappings(map, actions)
            actions.select_default:replace(function()
                local entry = action_state.get_current_picker(prompt_bufnr):get_selection()
                if not entry then return end
                actions.close(prompt_bufnr)
                M.results(entry.value)
            end)
            return true
        end,
    }):find()
end

return M
