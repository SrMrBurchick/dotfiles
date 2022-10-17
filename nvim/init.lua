require('base')

require('configuration')
require('highlights')
require('maps')
require('plugins')
require('unreal_engine_cpp_setup')

-- Neovide
vim.cmd [[
    if exists("g:neovide")
        set guifont=Hack:h8
        let g:neovide_remember_window_size = v:true
        let g:neovide_cursor_trail_size = 0.2
        let g:neovide_hide_mouse_when_typing = v:true
        let g:neovide_cursor_vfx_mode = "pixiedust"
        let g:neovide_underline_automatic_scaling = v:false
        let g:neovide_transparency=0.8
        autocmd VimEnter * Telescope project

        " system clipboard
        inoremap <c-v> <c-r>+
        cnoremap <c-v> <c-r>+
    endif
]]

if vim.v.argc ~= 0 then
    if vim.v.argv[2] == "pr" then
        vim.cmd 'autocmd VimEnter * bdelete pr | NvimTreeToggle'
    end
end

local rc_file = vim.fn.getcwd() .. "/.exrc"
local f = io.open(rc_file, "r")
if f ~= nil then
    io.close(f)
end
