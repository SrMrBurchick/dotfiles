local status, perforce = pcall(require, "perforce")
local ptelescope = {}
if (not status) then return end

status, ptelescope = pcall(require, 'perforce.telescope')
if (not status) then return end

perforce.setup({
})

local opts = { noremap = true, silent = true }
vim.keymap.set('n', 'pf', '<CMD>lua require("perforce.telescope").files()<CR>', opts)
vim.keymap.set('n', 'po', '<CMD>lua require("perforce.telescope").opened()<CR>', opts)
vim.keymap.set('n', 'pl', '<CMD>lua require("perforce.telescope").file_log()<CR>', opts)
vim.keymap.set('n', 'pa', '<CMD>Perforce  Add<CR>', opts)
vim.keymap.set('n', 'pd', '<CMD>Perforce  Delete<CR>', opts)
vim.keymap.set('n', 'pi', '<CMD>Perforce  Info<CR>', opts)
vim.keymap.set('n', 'pc', '<CMD>Perforce  Checkout<CR>', opts)
vim.keymap.set('n', 'pr', '<CMD>Perforce  Revert<CR>', opts)
