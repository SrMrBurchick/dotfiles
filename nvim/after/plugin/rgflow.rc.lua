local ok, rgflow = pcall(require, 'rgflow')
if not ok then
    vim.notify('rgflow.nvim is missing; install it with Packer to use ;r', vim.log.levels.WARN)
    return
end

-- Upstream setup registers a ColorScheme autocmd each time: call it only once.
if not vim.g.config_rgflow_setup then
    rgflow.setup({
        cmd_flags = '--smart-case --no-ignore-vcs --max-columns 500 '
            .. table.concat(require('ue_paths').rg_args(), ' '),
        default_trigger_mappings = false,
        default_ui_mappings = true,
        default_quickfix_mappings = true,
        incsearch_after = false, -- retain the existing no-hlsearch preference
        quickfix = {
            new_list_always_appended = true,
            open_qf_cmd_or_func = function() require('rgflow_telescope').on_quickfix_open() end,
        },
    })
    vim.g.config_rgflow_setup = true
end
vim.cmd('packadd cfilter') -- rgflow's normal c/C quickfix filters

local function open()
    -- Same project selection as the existing Telescope pickers; no root scanning.
    rgflow.open(nil, nil, vim.t.root_dir or vim.fn.getcwd())
end
local view = require('rgflow_telescope')
vim.api.nvim_create_user_command('RgFlowSearch', open, { desc = 'New rgflow project search' })
vim.api.nvim_create_user_command('RgFlowTelescope', function() view.results() end,
    { desc = 'View latest retained rgflow results without searching again' })
vim.api.nvim_create_user_command('RgFlowQuickfix', function() view.quickfix() end,
    { desc = 'Reopen latest retained rgflow quickfix buffer' })
vim.api.nvim_create_user_command('RgFlowHistory', view.history,
    { desc = 'Browse retained rgflow searches without rerunning them' })
vim.api.nvim_create_user_command('RgFlowAbort', rgflow.abort, { desc = 'Abort rgflow search / close its form' })
vim.keymap.set('n', ';r', open, { desc = 'Rgflow project search' })
vim.keymap.set('n', ';R', '<Cmd>RgFlowTelescope<CR>', { desc = 'Reopen rgflow results in Telescope' })
