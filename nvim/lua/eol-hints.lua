local M = {}
local ns = vim.api.nvim_create_namespace("eol_inlay_hints")

function M.enable(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local function render_hints()
    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

    vim.lsp.buf_request(bufnr, "textDocument/inlayHint", {
      textDocument = vim.lsp.util.make_text_document_params(),
      range = {
        start = { line = 0, character = 0 },
        ["end"] = {
          line = vim.api.nvim_buf_line_count(bufnr),
          character = 0,
        },
      },
    }, function(err, result, ctx)
      if err then
        vim.notify("InlayHint error: " .. vim.inspect(err), vim.log.levels.ERROR)
        return
      end
      if not result then return end

      local lines = {}

      for _, hint in ipairs(result) do
        local line = hint.position.line
        local label = ""

        if type(hint.label) == "string" then
          label = hint.label
        elseif type(hint.label) == "table" then
          for _, part in ipairs(hint.label) do
            label = label .. (type(part) == "string" and part or part.value)
          end
        end

        lines[line] = lines[line] or { params = {}, returns = {} }
        if hint.kind == 2 then
          table.insert(lines[line].params, label)
        elseif hint.kind == 1 then
          table.insert(lines[line].returns, label)
        end
      end

      for line, hint in pairs(lines) do
        local virt = "\t"
        if #hint.params > 0 then
          virt = virt .. table.concat(hint.params, ", ")
        end
        if #hint.returns > 0 then
          virt = virt .. " -> " .. table.concat(hint.returns, ", ")
        end

        vim.api.nvim_buf_set_extmark(bufnr, ns, line, -1, {
          virt_text = { { virt, "Comment" } },
          virt_text_pos = "eol",
        })
      end
    end)
  end

  render_hints()
  vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "CursorHold", "BufWritePost" }, {
    buffer = bufnr,
    callback = render_hints,
  })
end

return M
