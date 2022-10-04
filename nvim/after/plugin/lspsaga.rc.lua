local status, saga = pcall(require, 'lspsaga')
if (not status) then
    print("Lspsaga not installed")
    return
end

saga.init_lsp_saga {
    server_filetype_map = {},
    show_outline = {
        win_position = 'left',
        win_with = '',
        win_width = 10,
        auto_enter = false,
        auto_preview = false,
        virt_text = '┃',
        jump_key = 'o',
        auto_refresh = true,
    },
}

local opts = { noremap = true, silent = true }
vim.keymap.set('n', 'gr', '<Cmd> Lspsaga lsp_finder<cr>', opts)
vim.keymap.set('n', 'rn', '<Cmd> Lspsaga rename<cr>', opts)
vim.keymap.set('n', 'gp', '<Cmd> Lspsaga preview_definition<cr>', opts)
vim.keymap.set('n', 'K', '<Cmd> Lspsaga hover_doc<cr>', opts)
-- vim.keymap.set('i', '<C-k>', '<Cmd> Lspsaga signature_help<cr>', opts)