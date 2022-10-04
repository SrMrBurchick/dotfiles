-- load refactoring Telescope extension
require("telescope").load_extension("refactoring")

-- remap to open the Telescope refactoring menu in visual mode
vim.api.nvim_set_keymap(
    "v",
    "rf",
    "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
    { noremap = true }
)
