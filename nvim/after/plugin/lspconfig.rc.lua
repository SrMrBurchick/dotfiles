-- Mason manages binaries; clangd is configured independently of Mason/cmp availability.
require('clangd_setup').setup()

local ok, mason = pcall(require, 'mason')
if ok then
    mason.setup({
        ui = { icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" } },
    })
    local has_bridge, bridge = pcall(require, 'mason-lspconfig')
    if has_bridge then
        -- Preserve automatic setup for other installed servers.
        bridge.setup({ automatic_enable = { exclude = { 'clangd' } } })
    end
end

vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, { silent = true })
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, { silent = true })
