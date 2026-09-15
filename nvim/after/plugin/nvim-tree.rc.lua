local status, nvim_tree = pcall(require, 'nvim-tree')
if (not status) then
    print("Nvim-tree not installed")
    return
end


nvim_tree.setup({
    diagnostics = {
        enable = false
    },
    sort_by = "case_sensitive",
    filters = {
        dotfiles = false,
        custom = { '^Binaries$', '^DerivedDataCache$', '^Intermediate$', '^Saved$', '^\\.vs$' },
    },
    git = {
        enable = false,
    },
    filesystem_watchers = {
        ignore_dirs = function(path)
            return require("ue_paths").is_tree_ignored(path)
        end,
    },
    renderer = {
        group_empty = true,
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
