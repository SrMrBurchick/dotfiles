local config = require("clangd_extensions.config")

local M = {}

M.hint_aucmd_set_up = false

local commands = [[
if !exists(':ClangdAST')

  function s:memuse_compl(_a,_b,_c)
      return ['expand_preamble']
  endfunction

  command ClangdSetInlayHints lua require('clangd_extensions.inlay_hints').set_inlay_hints()
  command ClangdDisableInlayHints lua require('clangd_extensions.inlay_hints').disable_inlay_hints()
  command ClangdToggleInlayHints lua require('clangd_extensions.inlay_hints').toggle_inlay_hints()
  command -range ClangdAST lua require('clangd_extensions.ast').display_ast(<line1>, <line2>)
  command ClangdTypeHierarchy lua require('clangd_extensions.type_hierarchy').show_hierarchy()
  command ClangdSymbolInfo lua require('clangd_extensions.symbol_info').show_symbol_info()
  command -nargs=? -complete=customlist,s:memuse_compl ClangdMemoryUsage lua require('clangd_extensions.memory_usage').show_memory_usage('<args>' == 'expand_preamble')

endif
]]

function M.setup(opts)
    -- Set up extensions, get lspconfig opts
    config.setup(opts)
    -- Server ownership stays in clangd_setup, including for project-local callers.
    if opts and opts.server and next(opts.server) then
        vim.notify('Move clangd server overrides to lua/clangd_setup.lua', vim.log.levels.WARN)
    end
    require('clangd_setup').setup()
    vim.cmd(commands)

    -- Set up AST state stuff
    require("clangd_extensions.ast").init()
end

return M
