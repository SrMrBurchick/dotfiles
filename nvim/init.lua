require('base')

require('configuration')
require('maps')
require('plugins')
require('highlights')
require('fold')
--
-- if vim.v.argc ~= 0 then
--     if vim.v.argv[2] == "pr" then
--         vim.cmd 'autocmd VimEnter * bdelete pr | NvimTreeToggle'
--     end
-- end

if vim.g.neovide then
    vim.g.neovide_cursor_vfx_mode = "torpedo"
    vim.g.neovide_background_color = "#000000"
    -- vim.o.guifont = "FiraCode Nerd Font:h18"
    vim.o.guifont = "FiraCode Nerd Font:h14:b"

    -- Helper function for transparency formatting
    local alpha = function()
        return string.format("%x", math.floor(255 * vim.g.transparency or 0.8))
    end
    -- g:neovide_transparency should be 0 if you want to unify transparency of content and title bar.
    vim.g.neovide_transparency = 0.8
    vim.g.transparency = 0.8
	vim.g.neovide_fullscreen = true

    -- vim.g.neovide_background_color = "#0f1117" .. alpha()
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
