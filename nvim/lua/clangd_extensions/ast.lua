local fmt = string.format
local api = vim.api
local conf = require("clangd_extensions.config").options.extensions.ast

local M = {}

local function setup_hl_autocmd(source_buf, ast_buf)
    local group = api.nvim_create_augroup('ClangdAST' .. ast_buf, { clear = true })
    api.nvim_create_autocmd('CursorMoved', {
        group = group, buffer = ast_buf,
        callback = function() M.update_highlight(source_buf, ast_buf) end,
    })
    api.nvim_create_autocmd('BufLeave', {
        group = group, buffer = ast_buf,
        callback = function() M.clear_highlight(source_buf) end,
    })
    api.nvim_create_autocmd('BufWipeout', {
        group = group, buffer = ast_buf, once = true,
        callback = function()
            M.clear_highlight(source_buf)
            if M.node_pos[source_buf] then M.node_pos[source_buf][ast_buf] = nil end
            M.detail_pos[ast_buf] = nil
            api.nvim_del_augroup_by_id(group)
        end,
    })
end

local function icon_prefix(role, kind)
    if conf.kind_icons[kind] then
        return conf.kind_icons[kind] .. "  "
    elseif conf.role_icons[role] then
        return conf.role_icons[role] .. "  "
    else
        return "   "
    end
end

local function describe(role, kind, detail)
    local str = ""
    local icon = icon_prefix(role, kind)
    local detailpos = nil
    str = str .. kind
    if
        not (
            role == "expression"
            or role == "statement"
            or role == "declaration"
            or role == "template name"
        )
    then
        str = str .. " " .. role
    end
    if detail then
        detailpos = {
            start = string.len(str) + (icon == "   " and 0 or 2) + 4,
            ["end"] = string.len(str) + string.len(detail) + 6,
        }
        str = str .. " " .. detail
    end
    return (icon .. str), detailpos
end

local function walk_tree(node, visited, result, padding, hl_bufs)
    visited[node] = true
    local str, detpos = describe(node.role, node.kind, node.detail)
    table.insert(result, padding .. str)

    if node.detail and detpos then
        M.detail_pos[hl_bufs.ast_buf][#result] = {
            start = string.len(padding) + detpos.start,
            ["end"] = string.len(padding) + detpos["end"],
        }
    end

    if node.range then
        M.node_pos[hl_bufs.source_buf][hl_bufs.ast_buf][#result] = {
            start = { node.range.start.line, node.range.start.character },
            ["end"] = { node.range["end"].line, node.range["end"].character },
        }
    end

    if node.children then
        for _, child in pairs(node.children) do
            if not visited[child] then
                walk_tree(child, visited, result, padding .. "  ", hl_bufs)
            end
        end
    end

    return result
end

local function highlight_detail(ast_buf)
    for linenum, range in pairs(M.detail_pos[ast_buf]) do
        vim.hl.range(
            ast_buf,
            M.nsid,
            conf.highlights.detail,
            { linenum - 1, range.start },
            { linenum - 1, range["end"] },
            { priority = 110 }
        )
    end
end

local function handler(err, ASTNode, ctx)
    if err or not ASTNode or not api.nvim_buf_is_valid(ctx.bufnr)
        or api.nvim_get_current_buf() ~= ctx.bufnr then
        return
    else
        local source_buf = api.nvim_get_current_buf()
        vim.cmd.vsplit(vim.fn.fnameescape((ASTNode.detail or "clangd") .. ": AST"))
        local ast_buf = api.nvim_get_current_buf()
        if not M.node_pos[source_buf] then
            M.node_pos[source_buf] = {}
        end
        M.node_pos[source_buf][ast_buf] = {}
        M.detail_pos[ast_buf] = {}

        local lines = walk_tree(ASTNode, {}, {}, "", { source_buf = source_buf, ast_buf = ast_buf })
        api.nvim_buf_set_lines(ast_buf, 0, -1, true, lines)
        vim.bo.buftype = "nofile"
        vim.bo.bufhidden = "wipe"
        vim.bo.modifiable = false
        vim.bo.shiftwidth = 2
        vim.wo.foldmethod = "indent"
        vim.wo.number = false
        vim.wo.relativenumber = false
        vim.wo.spell = false
        vim.wo.cursorline = false
        setup_hl_autocmd(source_buf, ast_buf)
        highlight_detail(ast_buf)
    end
end

function M.init()
    --- node_pos[source_buf][ast_buf][linenum] = { start = start, end = end }
    --- position of node in `source_buf` corresponding to line no. `linenum` in `ast_buf`
    M.node_pos = M.node_pos or {}
    --- detail_pos[ast_buf][linenum] = { start = start, end = end }
    --- position of `detail` in line no. `linenum` of `ast_buf`
    M.detail_pos = M.detail_pos or {}
    M.nsid = vim.api.nvim_create_namespace("clangd_extensions")
end

function M.clear_highlight(source_buf)
    if not api.nvim_buf_is_valid(source_buf) then return end
    api.nvim_buf_clear_namespace(source_buf, M.nsid, 0, -1)
end

function M.update_highlight(source_buf, ast_buf)
    M.clear_highlight(source_buf)
    if not api.nvim_buf_is_valid(source_buf) or api.nvim_get_current_buf() ~= ast_buf then
        return
    end
    local curline = vim.fn.getcurpos()[2]
    local curline_ranges = M.node_pos[source_buf][ast_buf][curline]
    if curline_ranges then
        vim.hl.range(
            source_buf,
            M.nsid,
            "Search",
            curline_ranges.start,
            curline_ranges["end"],
            { priority = 110 }
        )
    end
end

function M.display_ast(line1, line2)
    local buf = api.nvim_get_current_buf()
    local tick = api.nvim_buf_get_changedtick(buf)
    vim.lsp.buf_request(0, "textDocument/ast", {
        textDocument = { uri = vim.uri_from_bufnr(0) },
        range = {
            start = {
                line = line1 - 1,
                character = 0,
            },
            ["end"] = {
                line = line2,
                character = 0,
            },
        },
    }, function(err, result, ctx)
        if api.nvim_buf_is_valid(buf) and api.nvim_buf_get_changedtick(buf) == tick then
            handler(err, result, ctx)
        end
    end)
end

return M
