-- Run with installed plugins: nvim --headless -u NONE -i NONE -l tests/rgflow_telescope.lua
-- RGFLOW_TEST_PLUGIN may point to a separate rgflow checkout.
local config = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, 'S').source:sub(2)))
vim.opt.rtp:prepend(config)
local packages = vim.fn.stdpath('data') .. '/site/pack/packer/start/'
vim.opt.rtp:append(vim.env.RGFLOW_TEST_PLUGIN or packages .. 'rgflow.nvim')
vim.opt.rtp:append(packages .. 'telescope.nvim')
vim.opt.rtp:append(packages .. 'plenary.nvim')
vim.cmd('filetype plugin on')
require('telescope').setup({ defaults = { layout_config = { horizontal = { preview_cutoff = 0 } } } })
dofile(config .. '/after/plugin/rgflow.rc.lua')
assert(vim.g.config_rgflow_setup, 'rgflow setup failed')
local rgflow = require('rgflow')
local view = require('rgflow_telescope')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local state = require('rgflow.state').get_state()
local modes = require('rgflow.modes')

local searches = 0
local spawn = vim.uv.spawn
vim.uv.spawn = function(command, opts, ...)
    if command == 'rg' then searches = searches + 1 end
    return spawn(command, opts, ...)
end
-- Any synchronous process added by the integration fails the test.
vim.fn.system = function() error('synchronous system()') end
vim.fn.systemlist = function() error('synchronous systemlist()') end
io.popen = function() error('synchronous popen()') end

local root = vim.fn.tempname() .. '/Game Space'
vim.fn.mkdir(root .. '/Source', 'p')
vim.fn.writefile({ 'prefix NeedleSuffix', '  NeedleSuffix', 'é NeedleSuffix' }, root .. '/Source/One.cpp')
vim.fn.writefile({ 'Different OtherNeedle' }, root .. '/Source/Two.cpp')
for _, dir in ipairs(require('ue_paths').outputs) do
    vim.fn.mkdir(root .. '/' .. dir, 'p')
    vim.fn.writefile({ 'NeedleSuffix OtherNeedle' }, root .. '/' .. dir .. '/excluded.cpp')
end
vim.t.root_dir = root

local function wait_for(test, message)
    assert(vim.wait(15000, test, 10), message)
end
local function search(pattern, count, hidden)
    local before = searches
    vim.cmd.RgFlowSearch()
    assert(vim.bo.filetype == 'rgflow')
    local lines = vim.api.nvim_buf_get_lines(0, 0, 3, false)
    assert(lines[3] == root, 'workspace path, including spaces')
    if hidden then lines[1] = lines[1] .. ' --hidden' end
    lines[2] = pattern
    vim.api.nvim_buf_set_lines(0, 0, 3, false, lines)
    vim.cmd.stopinsert()
    rgflow.start()
    -- Reject picker/history commands while rgflow owns the active output list.
    local active = vim.fn.getqflist({ id = 0 }).id
    view.history()
    assert(vim.fn.getqflist({ id = 0 }).id == active)
    wait_for(function() return state.mode == modes.DONE end, 'rgflow did not finish')
    vim.wait(50, function() return false end) -- drain upstream deferred title updates
    assert(searches == before + 1, 'expected exactly one rg process')
    assert(#vim.fn.getqflist() == count, 'unexpected number of matches')
    return vim.fn.getqflist({ id = 0 }).id
end
local function picker()
    local prompt = vim.api.nvim_get_current_buf()
    local current = action_state.get_current_picker(prompt)
    wait_for(function() return current:get_selection() ~= nil end, 'picker did not populate')
    return prompt, current
end
local first = search('NeedleSuffix', 3, true)
local original = vim.fn.getqflist()
for _, item in ipairs(original) do
    assert(vim.api.nvim_buf_get_name(item.bufnr):find('/Source/', 1, true), 'UE exclusion failed')
end
assert(original[1].col == 8 and original[3].col == 4, 'upstream byte columns')
vim.cmd.cclose()
view.results()
local prompt, current = picker()
assert(current.manager:num_results() == #original, 'Telescope/quickfix count mismatch')
assert(current.previewer, 'no source previewer')
wait_for(function()
    local buf = current.previewer.state.bufnr
    return buf and vim.api.nvim_buf_is_valid(buf) and (vim.bo[buf].syntax == 'cpp' or vim.treesitter.highlighter.active[buf] ~= nil)
end, 'source preview did not load with C++ syntax')
assert(current.cache_picker == false, 'result table must not persist in Telescope cache')
local selected = action_state.get_selected_entry()
assert(selected.filename == vim.api.nvim_buf_get_name(original[1].bufnr))
local before = vim.fn.getqflist({ id = first, changedtick = 0 }).changedtick
-- Exercise the actual Escape mapping (including insert mode).
vim.cmd.startinsert()
vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'xt', false)
wait_for(function() return not vim.api.nvim_buf_is_valid(prompt) end, 'Escape did not close Telescope')
assert(vim.deep_equal(original, vim.fn.getqflist()), 'Escape changed quickfix entries')
assert(vim.fn.getqflist({ id = first, changedtick = 0 }).changedtick == before)
view.results()
prompt = picker()
selected = action_state.get_selected_entry()
local expected = selected.value
local ok, err = pcall(actions.select_default, prompt)
assert(ok, err)
assert(vim.api.nvim_get_current_buf() == expected.bufnr, 'wrong selected file')
assert(vim.deep_equal(vim.api.nvim_win_get_cursor(0), { expected.lnum, expected.col - 1 }), 'wrong line/column')
assert(searches == 1, 'opening/reopening/selecting results reran rg')
vim.api.nvim_buf_set_lines(0, 0, 0, false, { '// edited after search' })
view.results()
prompt = picker()
local shown = action_state.get_selected_entry()
assert(shown.lnum == vim.fn.getqflist()[shown.value.rgflow_index].lnum, 'not reading live native quickfix positions')
actions.close(prompt)
vim.cmd('write')
local second = search('OtherNeedle', 1)
assert(second ~= first)
view.history()
prompt, current = picker()
assert(current.manager:num_results() == 2, 'missing native search history')
actions.select_default(prompt)
prompt, current = picker()
assert(current.manager:num_results() == 1, 'history selection did not open existing latest results')
actions.close(prompt)
-- Showing old entries is read-only until a result is chosen.
view.results(first)
prompt = picker()
assert(vim.fn.getqflist({ id = 0 }).id == second)
actions.select_default(prompt)
assert(vim.fn.getqflist({ id = 0 }).id == first, 'selection did not activate original list')
assert(searches == 2)
view.quickfix()
assert(vim.bo.buftype == 'quickfix')
assert(vim.fn.getqflist({ id = 0 }).id == second, 'latest results not reopened')
local qfbuf = vim.api.nvim_get_current_buf()
vim.cmd.cclose()
vim.cmd('bwipeout! ' .. qfbuf)
view.quickfix(first)
assert(#vim.fn.getqflist() == 3, 'wiping the quickfix view lost its native list')
vim.cmd.cnext()
vim.cmd.cprevious()
-- Other tools can create lists without stealing the last rgflow search.
vim.fn.setqflist({}, ' ', { nr = '$', title = 'unrelated', items = {} })
view.quickfix()
assert(vim.fn.getqflist({ id = 0 }).id == second)
-- Upstream no-match searches retain the old list; our metadata must not relabel it.
local empty = search('DefinitelyAbsent_92791', 1)
assert(empty == second, 'unexpected upstream no-match behavior')
assert(vim.fn.getqflist({ id = second, context = 0 }).context.rgflow_telescope.label:find('OtherNeedle', 1, true))
-- Large actual rgflow result set, not a mocked table.
view.quickfix(first) -- searching from an older list must append, not discard newer searches
local many = {}
for i = 1, 3000 do many[i] = '  LargeNeedle ' .. i end
vim.fn.writefile(many, root .. '/Source/Large.cpp')
local large = search('LargeNeedle', 3000)
assert(vim.fn.getqflist({ id = second }).id == second, 'new search discarded newer history')
local start = vim.uv.hrtime()
view.results(large)
prompt, current = picker()
assert(current.manager:num_results() == 3000)
local elapsed = (vim.uv.hrtime() - start) / 1e6
-- Stale view must not jump to a different item after native quickfix edits.
vim.fn.setqflist({}, 'a', { id = large, items = { original[1] } })
actions.select_default(prompt)
assert(vim.api.nvim_buf_is_valid(prompt), 'stale snapshot was accepted')
actions.close(prompt)
local autocmds = #vim.api.nvim_get_autocmds({})
dofile(config .. '/after/plugin/rgflow.rc.lua')
assert(#vim.api.nvim_get_autocmds({}) == autocmds, 'reload duplicated autocmds')
assert(searches == 4, 'result/history views started another rg process')
-- Native history removal must not leave private result copies to resurrect.
vim.fn.setqflist({}, 'f')
view.results(large)
assert(vim.fn.getqflist({ nr = '$' }).nr == 0, 'expired search was recreated')
print(string.format('PASS: four searches / four rg processes; exclusions, native persistence/history, preview, Escape, exact jump, stale guard, reload; 3000-result picker %.1f ms', elapsed))
vim.uv.spawn = spawn
vim.cmd('qa!')
