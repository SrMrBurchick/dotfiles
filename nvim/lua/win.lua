vim.cmd [[
    let &shell = executable('pwsh') ? 'pwsh' : 'powershell'
    let &shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
    let &shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait'
    let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    set shellquote= shellxquote=
]]

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

