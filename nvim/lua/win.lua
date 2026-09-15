-- Open/Load config
local keymap = vim.keymap
keymap.set('n', '<M-c>o', ':tabnew ~\\AppData\\Local\\nvim\\init.lua<CR>')
keymap.set('n', '<M-c>l', ':so ~\\AppData\\Local\\nvim\\init.lua<CR>')

-- Neovide
vim.cmd [[
    if exists("g:neovide")
        let g:neovide_transparency=1.0
    endif
]]

