local M = {}

local function get_tab_root()
    return vim.t.root_dir
end

local function set_tab_root(dir)
    vim.t.root_dir = dir
end

function M.create_workspace_tab(dir)
    dir = dir or vim.fn.input("Workspace root: ", vim.fn.getcwd(), "dir")
    if dir == "" then return end

    dir = vim.fn.resolve(vim.fn.fnamemodify(dir, ":p"))

    vim.cmd("tabnew")
    set_tab_root(dir)
    vim.cmd("lcd " .. vim.fn.fnameescape(dir))

end

vim.api.nvim_create_autocmd("TabEnter", {
    group = vim.api.nvim_create_augroup("WorkspaceTabs", { clear = true }),
    callback = function()
        local root = get_tab_root()
        if root then
            vim.cmd("lcd " .. vim.fn.fnameescape(root))
            local ok, nvim_tree_api = pcall(require, "nvim-tree.api")
            if ok then
                nvim_tree_api.tree.change_root(root)
            end
        end
    end,
})

vim.keymap.set("n", "<leader>tw", function()
    M.create_workspace_tab()
end, { desc = "New workspace tab" })

return M
