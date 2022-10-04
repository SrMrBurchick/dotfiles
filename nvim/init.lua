require('base')
require('configuration')
require('highlights')
require('maps')
require('plugins')

-- Neovide
vim.cmd [[
    if exists("g:neovide")
        set guifont=Monospace:h8
        let g:neovide_remember_window_size = v:true
        let g:neovide_cursor_trail_size = 0.2
        let g:neovide_hide_mouse_when_typing = v:true
        let g:neovide_cursor_vfx_mode = "pixiedust"
        let g:neovide_underline_automatic_scaling = v:false
        let g:neovide_transparency=0.8
    endif

]]

if vim.v.argc ~= 0 then
    if vim.v.argv[2] == "pr" then
        vim.cmd 'autocmd VimEnter * bdelete pr | NvimTree new | :NvimTreeToggle'
--[[        vim.cmd 'autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif' ]]
    end
end

--vim.cmd [[autocmd CursorHold,CursorHoldI * lua require('nvim-lightbulb').update_lightbulb()]]
vim.cmd [[autocmd CursorHold,CursorHoldI * lua require('lspsaga').show_cursor_diagnostic() ]]

local rc_file = vim.fn.getcwd() .. "/.exrc"
local f = io.open(rc_file,"r")
if f ~=nil then
    io.close(f)
end

vim.cmd [[ noswapfile ]]
vim.cmd [[ let g:OmniSharp_highlighting = 3 ]]
