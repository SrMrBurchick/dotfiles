require('base')
require('configuration')
require('highlights')
require('maps')
require('plugins')
-- require('unreal_engine_cpp_setup')

if vim.v.argc ~= 0 then
    if vim.v.argv[2] == "pr" then
        vim.cmd 'autocmd VimEnter * bdelete pr | NERDTree new | :NERDTreeToggle'
        vim.cmd 'autocmd BufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif'
    end
end

vim.cmd [[autocmd CursorHold,CursorHoldI * lua require('nvim-lightbulb').update_lightbulb()]]

local rc_file = vim.fn.getcwd() .. "/.exrc"
local f = io.open(rc_file,"r")
if f ~=nil then
    io.close(f)
    vim.cmd [[ source .exrc ]]
end
