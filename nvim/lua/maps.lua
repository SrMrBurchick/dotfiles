local keymap = vim.keymap

keymap.set('n', 'x', '"_x')

-- Increment/decrement
keymap.set('n', '+', '<C-a>')
keymap.set('n', '-', '<C-x>')

-- Select all
keymap.set('n', '<C-a>', 'gg<S-v>G')

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})
-- Lsp formatting
keymap.set('n', 'cf', '<cmd> lua vim.lsp.buf.format()<cr>')

-- New tab
keymap.set('n', 'tn', ':tabnew <CR>')
-- New tab terminal
keymap.set('n', 'tnt', ':tabnew<CR>:terminal<CR>')
-- Split window
keymap.set('n', 'ss', ':split<Return><C-w>w')
keymap.set('n', 'sv', ':vsplit<Return><C-w>w')
-- Move window
keymap.set('', '<Space>', '<C-w>w')
keymap.set('', 'sh', '<C-w>h')
keymap.set('', 'sk', '<C-w>k')
keymap.set('', 'sj', '<C-w>j')
keymap.set('', 'sl', '<C-w>l')

-- Resize window
keymap.set('n', '<C-w>r<left>', '<C-w><')
keymap.set('n', '<C-w>r<right>', '<C-w>>')
keymap.set('n', '<C-w>r<up>', '<C-w>+')
keymap.set('n', '<C-w>r<down>', '<C-w>-')

-- Copy to system buffer
keymap.set('', '<C-c>', '"+y')
keymap.set('', '<C-p>', '"+p')

-- NvimTree
keymap.set('n', '<C-e>', ':NvimTreeToggle<CR>')

-- Code Actions
keymap.set('', 'va', '<cmd>Lspsaga code_action<CR>')
keymap.set('', 'vd', '<cmd>Lspsaga show_line_diagnostics<CR>')

-- Remove empty spaces
keymap.set('n', 'rs', ':%s/\\s\\+$//e <CR>')

-- Markdown preview
keymap.set('n', '<M-m>p', '<Plug>MarkdownPreview')
keymap.set('n', '<M-m>s', '<Plug>MarkdownPreviewStop')
keymap.set('n', '<M-m>t', '<Plug>MarkdownPreviewToggle')

-- VS Tasks
keymap.set('', 'ta', ':lua require("telescope").extensions.vstask.tasks()<CR>',
    { noremap = true })

-- VS Launch
keymap.set('', 'la', ':lua require("telescope").extensions.vslaunch.launches()<CR>',
    { noremap = true })

-- Symbols outline
keymap.set('', '<M-o>', function()
    -- local opts= {
    --     symbols = {
    --         "function",
    --         "variable",
    --         "class",
    --         "constructor",
    --         "method",
    --     }
    -- }
    -- if vim.bo.filetype == "vim" then
    --     opts.symbols = { "function" }
    -- end
    require('telescope.builtin').lsp_document_symbols()
end)
