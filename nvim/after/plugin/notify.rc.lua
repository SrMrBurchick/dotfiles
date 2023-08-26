vim.opt.termguicolors = true

local status, notify = pcall(require, 'notify')
if (not status) then
    return
end

notify.setup({
    background_colour = "#000000",
    timeout = 1500
})

-- Standalone UI for nvim-lsp progress.
require('lsp-notify').setup({
    notify = require('notify'),
})

