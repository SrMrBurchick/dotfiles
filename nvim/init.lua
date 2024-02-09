require('base')

require('configuration')
require('highlights')
require('maps')
require('plugins')

if vim.v.argc ~= 0 then
    if vim.v.argv[2] == "pr" then
        vim.cmd 'autocmd VimEnter * bdelete pr | NvimTreeToggle'
    end
end

local local_vimrc = vim.fn.getcwd() .. '/.nvimrc.lua'
if vim.loop.fs_stat(local_vimrc) then
    vim.cmd('source ' .. local_vimrc)
end

local has = vim.fn.has
local is_win = has "win32"
local is_linux = has "linux"

if 0 ~= is_win then
    require('win')
elseif 0 ~= is_linux then
    require('linux')
else
    print("Uknown system!")
end

if vim.g.neovide then
    vim.g.neovide_cursor_vfx_mode = "torpedo"
    vim.g.neovide_transparency = 0.8
    vim.g.transparency = 0.8
    vim.g.neovide_background_color = "#000000"
    vim.g.neovide_floating_blur_amount_x = 5.0
    vim.g.neovide_floating_blur_amount_y = 5.0
    vim.o.guifont = "Hack:h20"
end
