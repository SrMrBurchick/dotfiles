local status, soil = pcall(require, 'soil')
if (not status) then
    return
end

soil.setup({
    opts = {
        actions = {
            redraw = true
        }
    },
    image = {
        darkmode = true,
        execute_to_open = function(img)
        end
    }
})

-- Function to send buffer content to PlantUML server
local function render_puml_server()
  -- Call PlantUML server via curl
  local cmd = {
    "plantuml", "-darkmode", "."
  }
  vim.fn.jobstart(cmd)
end

-- Autocmd to trigger on save for .puml files
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.puml",
  callback = function()
    render_puml_server()
  end,
})
