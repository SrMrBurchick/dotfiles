local status, saga = pcall(require, 'lspsaga')
if (not status) then
    print("Lspsaga not installed")
    return
end

saga.init_lsp_saga {
    server_filetype_map = {},
    code_action_lightbulb = {
        virtual_text = false,
    },
    show_outline = {
        win_width = 30,
        auto_enter = false,
    },
}

local opts = { noremap = true, silent = true }
vim.keymap.set('n', 'gr', '<Cmd> Lspsaga lsp_finder<cr>', opts)
vim.keymap.set('n', 'rn', '<Cmd> Lspsaga rename<cr>', opts)
vim.keymap.set('n', 'gp', '<Cmd> Lspsaga preview_definition<cr>', opts)
vim.keymap.set('n', 'K', '<Cmd> Lspsaga hover_doc<cr>', opts)
vim.keymap.set('n', 'sot', '<Cmd> LSoutlineToggle<cr>', opts)
vim.keymap.set('n', 'tt', '<Cmd> Lspsaga open_floaterm<cr>', opts)
vim.keymap.set('t', 'tt', '<Cmd> Lspsaga close_floaterm<cr>', opts)
-- vim.keymap.set('i', '<C-k>', '<Cmd> Lspsaga signature_help<cr>', opts)
