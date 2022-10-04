local status, nvim_tree = pcall(require, 'nvim-tree')
if (not status) then
    print("Nvim-tree not installed")
    return
end


-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1

nvim_tree.setup({
    sort_by = "case_sensitive",
    view = {
        width = 30,
        mappings = {
            list = {
                { key = "u", action = "dir_up" },
            },
        },
    },
    renderer = {
        group_empty = true,
    },
})
