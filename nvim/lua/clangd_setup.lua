-- The only server configuration for clangd (Neovim >= 0.11).
local M = {}

-- Search ancestors only, asynchronously; never descend into an Unreal tree.
-- A .uproject wins over a nested compilation database. Perforce markers bound
-- the search; otherwise the nearest database is the fallback, never .git/cwd.
function M.root_dir(bufnr, on_dir)
    local filename = vim.api.nvim_buf_get_name(bufnr)
    if filename == '' then return end
    local explicit = vim.t.root_dir -- selected with <leader>tw; also covers sibling Engine sources
    local function finish(root)
        vim.schedule(function()
            if root and vim.api.nvim_buf_is_valid(bufnr)
                and vim.api.nvim_buf_get_name(bufnr) == filename then
                on_dir(root)
            end
        end)
    end
    if explicit and explicit ~= '' then
        vim.uv.fs_stat(explicit, function(_, stat)
            if stat and stat.type == 'directory' then finish(vim.fs.normalize(explicit)) end
        end)
        return
    end
    local fallback
    local function visit(dir, depth)
        if not dir or depth > 32 then finish(fallback); return end
        vim.uv.fs_scandir(dir, function(err, scan)
            if err then finish(fallback); return end
            local project, p4, database = false, false, false
            while true do
                local name, kind = vim.uv.fs_scandir_next(scan)
                if not name then break end
                if kind ~= 'directory' then
                    project = project or name:lower():match('%.uproject$') ~= nil
                    p4 = p4 or name == '.p4config' or name == '.p4ignore.txt'
                    database = database or name == 'compile_commands.json'
                end
            end
            if project then finish(dir); return end
            if database and not fallback then fallback = dir end
            if p4 then finish(dir); return end
            local parent = vim.fs.dirname(dir)
            if not parent or parent == dir then finish(fallback); return end
            visit(parent, depth + 1)
        end)
    end
    visit(vim.fs.dirname(filename), 1)
end

function M.set_hints(bufnr, enabled)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    local ft = vim.bo[bufnr].filetype
    if ft ~= 'c' and ft ~= 'cpp' then return end
    vim.b[bufnr].clangd_inlay_hints = enabled
    vim.lsp.inlay_hint.enable(enabled, { bufnr = bufnr })
end

function M.toggle_hints()
    local buf = vim.api.nvim_get_current_buf()
    M.set_hints(buf, not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }))
end

function M.setup()
    if M.configured then return end
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local has_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
    if has_cmp then
        capabilities = vim.tbl_deep_extend('force', capabilities, cmp_lsp.default_capabilities())
    end
    -- Avoid registering recursive native Windows workspace watchers.
    capabilities.workspace.didChangeWatchedFiles = { dynamicRegistration = false }
    capabilities.textDocument.semanticTokens = nil

    vim.lsp.config('clangd', {
        cmd = {
            'clangd', '--background-index', '--clang-tidy=false',
            '--completion-style=detailed', '--header-insertion=never',
            '--log=error', '--function-arg-placeholders=true',
        },
        filetypes = { 'c', 'cpp' },
        root_markers = { 'compile_commands.json', '.p4config', '.p4ignore.txt' },
        root_dir = M.root_dir, -- also recognizes *.uproject, without recursive globbing
        workspace_required = true,
        capabilities = capabilities,
        before_init = function(params, config)
            -- One stat per client, not per edit. Do not read/parse the huge JSON in Lua.
            -- Pin a project-root UBT database for sibling Engine files as well.
            if vim.uv.fs_stat(config.root_dir .. '/compile_commands.json') then
                params.initializationOptions = params.initializationOptions or {}
                params.initializationOptions.compilationDatabasePath = config.root_dir
            end
            -- Drop lspconfig's legacy offsetEncoding extension; use LSP 3.17 negotiation.
            params.capabilities.offsetEncoding = nil
            params.capabilities.textDocument.semanticTokens = nil
        end,
        on_init = function(client)
            client.server_capabilities.semanticTokensProvider = nil
        end,
        on_attach = function(client, bufnr)
            client.server_capabilities.semanticTokensProvider = nil
            vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
            local opts = { silent = true, buffer = bufnr }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
            vim.keymap.set('n', 'ca', vim.lsp.buf.code_action, opts)
            -- Preserve the existing quiet policy without enabling disabled diagnostics.
            vim.diagnostic.config({ virtual_text = false, update_in_insert = false },
                vim.lsp.diagnostic.get_namespace(client.id))
            if client:supports_method('textDocument/inlayHint', bufnr) then
                M.set_hints(bufnr, vim.b[bufnr].clangd_inlay_hints ~= false)
            end
            vim.api.nvim_buf_create_user_command(bufnr, 'LspClangdShowSymbolInfo', function()
                local extensions = require('clangd_extensions.config')
                if not extensions.options.extensions then extensions.setup() end
                require('clangd_extensions.symbol_info').show_symbol_info()
            end, {})
            vim.api.nvim_buf_create_user_command(bufnr, 'LspClangdSwitchSourceHeader', function()
                local win = vim.api.nvim_get_current_win()
                client:request('textDocument/switchSourceHeader',
                    vim.lsp.util.make_text_document_params(bufnr), function(err, path)
                        if err then vim.notify(err.message, vim.log.levels.ERROR); return end
                        if not path or path == '' then
                            vim.notify('Corresponding source/header not found'); return
                        end
                        if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == bufnr then
                            vim.api.nvim_win_call(win, function() vim.cmd.edit(vim.fn.fnameescape(vim.uri_to_fname(path))) end)
                        end
                    end, bufnr)
            end, {})
        end,
    })
    for name, action in pairs({
        ClangdToggleInlayHints = M.toggle_hints,
        ClangdSetInlayHints = function() M.set_hints(nil, true) end,
        ClangdDisableInlayHints = function() M.set_hints(nil, false) end,
    }) do
        vim.api.nvim_create_user_command(name, action, {})
    end
    vim.lsp.enable('clangd')
    M.configured = true
end

return M
