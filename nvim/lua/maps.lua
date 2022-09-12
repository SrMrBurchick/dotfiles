local keymap = vim.keymap

keymap.set('n', 'x', '"_x')

-- Increment/decrement
keymap.set('n', '+', '<C-a>')
keymap.set('n', '-', '<C-x>')

-- Select all
keymap.set('n', '<C-a>', 'gg<S-v>G')

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})

-- New tab
keymap.set('n', 'tn', ':tabnew <CR>')
-- New tab terminal
keymap.set('n', 'tnt', ':tabnew<CR>:terminal<CR>')
-- Split window
keymap.set('n', 'ss', ':split<Return><C-w>w')
keymap.set('n', 'sv', ':vsplit<Return><C-w>w')
-- Move window
keymap.set('', '<Space><Space>', '<C-w>w')
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

-- NerdTREE
keymap.set('n', '<C-e>', ':NERDTreeToggle<CR>')

-- ToggleTerm
keymap.set('t', '<ESC>', '<C-\\><C-n>')
keymap.set('', 'tt', ':ToggleTerm <CR>')

-- Code Actions
-- Rename
keymap.set("n", "rn", "<cmd>lua vim.lsp.buf.rename()<CR>", { noremap = true })
-- Remaps for the refactoring operations currently offered by the plugin
-- load refactoring Telescope extension
require("telescope").load_extension("refactoring")

-- remap to open the Telescope refactoring menu in visual mode
vim.api.nvim_set_keymap(
    "",
    "tr",
    "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
    { noremap = true }
)

-- Clang formatte
keymap.set('n', 'cf', ':ClangFormat<CR>', { noremap = true })

-- Remove empty spaces
keymap.set('n', 'rs', ':%s/\\s\\+$//e <CR>')

-- Markdown preview
keymap.set('n', '<M-m>p', '<Plug>MarkdownPreview')
keymap.set('n', '<M-m>s', '<Plug>MarkdownPreviewStop')
keymap.set('n', '<M-m>t', '<Plug>MarkdownPreviewToggle')

-- VS Tasks
keymap.set('', 'ta', ':lua require("telescope").extensions.vstask.tasks()<CR>',
           {noremap = true})

-- VS Launch
keymap.set('', 'la', ':lua require("telescope").extensions.vslaunch.launches()<CR>',
           {noremap = true})
