-- Compatibility entry point for project-local configs; native hints own refreshes.
local M = {}
function M.enable(bufnr)
    require('clangd_setup').set_hints(bufnr, true)
end
return M
