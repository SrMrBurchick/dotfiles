local status, mason = pcall(require, "mason")
if (not status) then return end

mason.setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

require("mason-nvim-dap").setup({
    automatic_setup = true,
})
require 'mason-nvim-dap'.setup_handlers {}
