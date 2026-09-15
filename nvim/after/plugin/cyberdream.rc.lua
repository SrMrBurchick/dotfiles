local status, cyberdream = pcall(require, "cyberdream")
if (not status) then return end

vim.notify("Setup cyberdream")
cyberdream.setup({
    -- Enable transparent background
    transparent = true,

    -- Improve start up time by caching highlights. Generate cache with :CyberdreamBuildCache and clear with :CyberdreamClearCache
    cache = true,

    -- Override a color entirely
    colors = {
        bg = "NONE",
    },
})

vim.cmd 'colorscheme cyberdream'
vim.opt.background = 'dark'
-- vim.cmd 'highlight clear LineNr'
vim.cmd 'set colorcolumn=81'
vim.cmd 'highlight ColorColumn ctermbg=102'
vim.cmd 'hi CursorLine gui=underline cterm=underline'

vim.cmd 'set termguicolors'
vim.cmd 'hi Normal guibg=NONE ctermbg=NONE'
