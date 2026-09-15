vim.opt.shell = 'fish'

-- Open/Load config
local keymap = vim.keymap
keymap.set('n', '<M-c>o', ':tabnew ~/.config/nvim/init.lua <CR>')
keymap.set('n', '<M-c>l', ':so ~/.config/nvim/init.lua <CR>')
