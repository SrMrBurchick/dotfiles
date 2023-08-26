local status, lsp_inlayhints = pcall(require, 'lsp-inlayhints')
if (not status) then
    print("LSP inlayhints not installed")
    return
end

lsp_inlayhints.setup()

vim.cmd("hi LspInlayHint guifg=#3a3a3a guibg=none")
