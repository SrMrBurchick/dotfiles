local symbol_kind = require("clangd_extensions.symbol_kind")
local fmt = string.format
local api = vim.api
local M = {}

local function format_tree(node, visited, result, padding)
    visited[node.data] = true
    table.insert(result, padding .. fmt(" • %s: %s", node.name, symbol_kind[node.kind]))

    if node.parents then
        if #node.parents > 0 then
            table.insert(result, padding .. "   Parents:")
            for _, parent in pairs(node.parents) do
                if not visited[parent.data] then
                    format_tree(parent, visited, result, padding .. "   ")
                end
            end
        end
    end

    if node.children then
        if #node.children > 0 then
            table.insert(result, padding .. "   Children:")
            for _, child in pairs(node.children) do
                if not visited[child.data] then
                    format_tree(child, visited, result, padding .. "   ")
                end
            end
        end
    end

    return result
end

local function handler(err, TypeHierarchyItem, ctx)
    if err or not TypeHierarchyItem or api.nvim_get_current_buf() ~= ctx.bufnr then
        return
    else
        local lines = format_tree(TypeHierarchyItem, {}, {}, "")
        vim.cmd.split(vim.fn.fnameescape(TypeHierarchyItem.name .. ": type hierarchy"))
        local bufnr = vim.api.nvim_get_current_buf()
        api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
        vim.bo.buftype = "nofile"
        vim.bo.modifiable = false
        vim.bo.bufhidden = "wipe"
        vim.wo.number = false
        vim.wo.relativenumber = false
        vim.wo.spell = false
        vim.wo.cursorline = false
    end
end

function M.show_hierarchy()
    local win = api.nvim_get_current_win()
    vim.lsp.buf_request(0, "textDocument/typeHierarchy", function(client)
        local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
        params.resolve = 3
        params.direction = 2
        return params
    end, handler)
end

return M
