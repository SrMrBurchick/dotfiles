local status, mason = pcall(require, "mason")
if (not status) then return end

mason.setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

status, mason_lsp = pcall(require, "mason-lspconfig")
if (not status) then return end

mason_lsp.setup()
--
-- status, mason_dap = pcall(require, "mason-nvim-dap")
-- if (not status) then return end
--
-- mason_dap.setup({
--     automatic_installation = true
-- })

local handlers = {
    ["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics, {
            -- Disable virtual_text
            virtual_text = false
        })
}

local protocol = require('vim.lsp.protocol')

-- Add additional capabilities supported by nvim-cmp
local capabilities = protocol.make_client_capabilities()

capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local opts = { noremap = true, silent = true }
--vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
--vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    require("lsp-inlayhints").on_attach(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', 'ca', vim.lsp.buf.code_action, bufopts)
end

-- Loop through all of the installed servers and set it up via lspconfig
mason_lsp.setup_handlers {
    function(server_name)
        require('lspconfig')[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
            handlers = handlers
        })
    end
}

-- QML
vim.lsp.handlers["textDocument/semanticTokens"] = vim.lsp.handlers["textDocument/semanticTokens"] or function(_, _, _, _, _, _, _)
  return { data = {} }
end
require('lspconfig').qml_lsp.setup {
    cmd = { "qmlls6" },
    filetypes = { "qml", "qmljs" },
    on_attach = on_attach,
    capabilities = capabilities,
    handlers = handlers

}


-- glsl
require'lspconfig'.glsl_analyzer.setup{}
-- require'lspconfig'.glslls.setup {
--     cmd = { "glslls"},
--     filetypes = { "glsl", "vert", "tesc", "tese", "frag", "geom", "comp" },
--     on_attach = on_attach,
--     capabilities = capabilities,
-- }

-- require'lspconfig'.qmlls.setup{}

-- -- Rust
-- require('lspconfig').rust_analyzer.setup {
--     settings = {
--         ["rust-analyzer"] = {
--             check = {
--                 overrideCommand = {
--                     "cargo",
--                     "clippy",
--                     "--message-format=json-diagnostic-rendered-ansi",
--                     "--fix",
--                     "--allow-dirty"
--                 }
--             }
--         }
--     }
-- }
-- require('lspconfig')["rust_analyzer"].setup {
--     cmd = "ra-multiplex"
-- }

-- require('lspconfig').rust_analyzer.setup {
--     cmd = { "ra-multiplex" },
--     settings = {
--         ["rust-analyzer"] = {
--             check = {
--                 overrideCommand = {
--                     "cargo",
--                     "clippy",
--                     "--message-format=json-diagnostic-rendered-ansi",
--                     "--fix",
--                     "--allow-dirty"
--                 }
--             }
--         }
--     }
-- }

-- Clangd server
require("clangd_extensions").setup {
    server = {
        on_attach = on_attach,
        cmd = {
            "clangd",
            "--background-index",
            "--cross-file-rename",
            "--header-insertion=never",
            "--limit-references=100",
            "--completion-style=detailed",
            "--limit-results=20"
        },
        capabilities = capabilities,
        handlers = handlers,
    },
}

local luasnip = require 'luasnip'
vim.keymap.set('i', '<C-s>', function()
    vim.cmd("LuaSnipUnlinkCurrent")
end)
-- nvim-cmp setup
local cmp = require 'cmp'
local lspkind = require('lspkind')
lspkind.init({
    -- DEPRECATED (use mode instead): enables text annotations
    --
    -- default: true
    -- with_text = true,

    -- defines how annotations are shown
    -- default: symbol
    -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
    mode = 'symbol_text',

    -- default symbol map
    -- can be either 'default' (requires nerd-fonts font) or
    -- 'codicons' for codicon preset (requires vscode-codicons font)
    --
    -- default: 'default'
    preset = 'codicons',

    -- override preset symbols
    --
    -- default: {}
    symbol_map = {
        Text = "󰉿",
        Method = "󰆧",
        Function = "󰊕",
        Constructor = "",
        Field = "󰜢",
        Variable = "󰀫",
        Class = "󰠱",
        Interface = "",
        Module = "",
        Property = "󰜢",
        Unit = "󰑭",
        Value = "󰱯 {fuck you}",
        Enum = "",
        Keyword = "󰌋",
        Snippet = "",
        Color = "󰏘",
        File = "󰈙",
        Reference = "󰈇",
        Folder = "󰉋",
        EnumMember = "",
        Constant = "󰏿",
        Struct = "󰙅",
        Event = "",
        Operator = "󰆕",
        TypeParameter = "",
    },
})

cmp.setup {
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    formatting = {
        format = lspkind.cmp_format({
            mode = 'symbol_text',  -- show only symbol annotations
            maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
            -- The function below will be called before any actual modifications from lspkind
            -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
            before = function(entry, vim_item)
                return vim_item
            end
        })
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }),
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'path' }
    },
    sorting = {
        comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.recently_used,
            require("clangd_extensions.cmp_scores"),
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    },
}
