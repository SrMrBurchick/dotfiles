local status, nvim_tree = pcall(require, 'nvim-tree')
if (not status) then
    print("Nvim-tree not installed")
    return
end


-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1
nvim_tree.setup({
    diagnostics = {
        enable = false
    },
    sort_by = "case_sensitive",
    renderer = {
        group_empty = true,
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
