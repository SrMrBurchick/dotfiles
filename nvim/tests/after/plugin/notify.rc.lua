vim.opt.termguicolors = true
--
local status, notify = pcall(require, 'notify')
if (not status) then
    return
end

notify.setup({
    background_colour = "#000000",
    timeout = 1500
})

vim.notify = notify
