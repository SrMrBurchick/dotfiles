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

    if vim.fn.filereadable(dir .. "/compile_commands.json") == 1 or
       vim.fn.filereadable(dir .. "/.clangd") == 1 then
        vim.lsp.start({
            name = "clangd",
            cmd = {
                "clangd",
                "--background-index",
                "--cross-file-rename",
                "--header-insertion=never",
                "--limit-references=100",
                "--completion-style=detailed",
                "--limit-results=20",
                "--inlay-hints=true"
            },
            root_dir = dir,
        })
    end
end

vim.api.nvim_create_autocmd("TabEnter", {
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
