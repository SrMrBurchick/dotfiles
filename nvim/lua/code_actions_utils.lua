local M = {}

-- Optional project-local listener. No automatic requests are registered here.
function M.code_action_listener()
    local bufnr = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    local diagnostics = vim.diagnostic.get(bufnr, { lnum = vim.api.nvim_win_get_cursor(win)[1] - 1 })
    local lsp_diagnostics = {}
    for _, diagnostic in ipairs(diagnostics) do
        if diagnostic.user_data and diagnostic.user_data.lsp then
            table.insert(lsp_diagnostics, diagnostic.user_data.lsp)
        end
    end
    vim.lsp.buf_request(bufnr, 'textDocument/codeAction', function(client)
        local params = vim.lsp.util.make_range_params(win, client.offset_encoding)
        params.context = { diagnostics = lsp_diagnostics }
        return params
    end, function(_err, _result, _ctx)
        -- Hook for project-local consumers.
    end)
end

return M
