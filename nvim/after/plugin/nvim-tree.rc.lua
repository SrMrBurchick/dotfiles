local status, nvim_tree = pcall(require, 'nvim-tree')
if (not status) then
    print("Nvim-tree not installed")
    return
end


-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1
nvim_tree.setup({
    sync_root_with_cwd = true,
    diagnostics = {
        enable = false
    },
    sort_by = "case_sensitive",
    view = {
        width = 30,
    },
    renderer = {
        group_empty = false,
    },
    filters = {
        dotfiles = false,
        -- custom = { '^.git$' }
    },
    git = {
        enable = false,
    },
    renderer = {
        icons = {
            glyphs = {
                git = {
                    unstaged = "",
                    staged = "",
                    unmerged = "󰿡",
                    renamed = "󰛿",
                    untracked = "",
                    deleted = "",
                    ignored = "󰮔",
                },
            },
        },
    }
})

-- set highlights
vim.o.termguicolors = true
vim.cmd.highlight 'NvimTreeGitStaged guifg=green'
vim.cmd.highlight 'NvimTreeGitDirty guifg=#e3b341'
vim.cmd.highlight 'NvimTreeGitNew guifg=gray'
vim.cmd.highlight 'NvimTreeGitRenamed guifg=#f0883e'
vim.cmd.highlight 'NvimTreeGitDeleted guifg=red'


vim.keymap.set('n', '<C-e>', ':NvimTreeToggle<CR>')
