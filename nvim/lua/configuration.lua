-- VS tasks
require("vstask").setup({
  use_harpoon = false, -- use harpoon to auto cache terminals
  telescope_keys = { -- change the telescope bindings used to launch tasks
      vertical = '<C-v>',
      split = '<C-p>',
      tab = '<C-t>',
      current = '<CR>',
  },
  terminal = 'toggleterm',
  term_opts = {
    horizontal = {
      direction = "horizontal",
      size = "10"
    },
  }
})

-- VS launch
require("vslaunch").setup({
  use_harpoon = false, -- use harpoon to auto cache terminals
  telescope_keys = { -- change the telescope bindings used to launch tasks
      vertical = '<C-v>',
      split = '<C-p>',
      tab = '<C-t>',
      current = '<CR>',
  },
  terminal = 'toggleterm',
  term_opts = {
    horizontal = {
      direction = "horizontal",
      size = "10"
    },
  }
})

-- Comments
require('Comment').setup()

-- Bufferline
vim.opt.termguicolors = true
require("bufferline").setup{}

-- Standalone UI for nvim-lsp progress.
require('fidget').setup()

-- Telescope Refactoring
require('refactoring').setup({
    prompt_func_return_type = {
        cpp = true,
        c = true,
        h = true,
        hpp = true,
        cxx = true,
    },
    prompt_func_param_type = {
        cpp = true,
        c = true,
        h = true,
        hpp = true,
        cxx = true,
    },
    printf_statements = {},
    print_var_statements = {},
})
