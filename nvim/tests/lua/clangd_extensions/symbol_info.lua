local config = require("clangd_extensions.config")

local function handler(err, result, ctx)
    if err or not result or #result == 0 or vim.api.nvim_get_current_buf() ~= ctx.bufnr then
        return
    end
    local name_str = string.format("name: %s", result[1].name)
    local container_str = string.format("container: %s", result[1].containerName)
    vim.lsp.util.open_floating_preview({ name_str, container_str }, "", {
        height = 2,
        width = math.max(string.len(name_str), string.len(container_str)),
        focusable = false,
        focus = false,
        border = config.options.extensions.symbol_info.border,
    })
end

local M = {}

function M.show_symbol_info()
    local win = vim.api.nvim_get_current_win()
    vim.lsp.buf_request(0, "textDocument/symbolInfo", function(client)
        return vim.lsp.util.make_position_params(win, client.offset_encoding)
    end, handler)
end

return M
