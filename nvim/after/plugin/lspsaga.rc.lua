local status, saga = pcall(require, 'lspsaga')
if (not status) then
    print("Lspsaga not installed")
    return
end

saga.setup {
    lightbulb = {
        enable = false,
        virtual_text = false,
    },
    diagnostic = {
        on_insert = false,
        on_insert_follow = false,
        insert_winblend = 0,
        show_code_action = false,
        show_source = false,
        jump_num_shortcut = false,
        --1 is max
        max_width = 0.7,
        custom_fix = nil,
        custom_msg = nil,
        text_hl_follow = false,
        border_follow = true,
        keys = {
            exec_action = "o",
            quit = "q",
            go_action = "g"
        },
    },
}

local opts = { noremap = true, silent = true }
vim.keymap.set('n', 'gr', '<Cmd> Lspsaga lsp_finder<cr>', opts)
vim.keymap.set('n', 'rn', '<Cmd> Lspsaga rename<cr>', opts)
vim.keymap.set('n', 'gp', '<Cmd> Lspsaga preview_definition<cr>', opts)
vim.keymap.set('n', 'K', '<Cmd> Lspsaga hover_doc<cr>', opts)
vim.keymap.set('n', 'sot', '<Cmd> Lspsaga outline<cr>', opts)
-- vim.keymap.set('n', '<C-t>t', '<Cmd> Lspsaga open_floaterm<cr>', opts)
-- vim.keymap.set('t', '<C-t>t', '<Cmd> Lspsaga close_floaterm<cr>', opts)
-- vim.keymap.set('i', '<C-k>', '<Cmd> Lspsaga signature_help<cr>', opts)
