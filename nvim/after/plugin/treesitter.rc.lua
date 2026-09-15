local ok, ts = pcall(require, 'nvim-treesitter')
if not ok then
    vim.notify('Tree-sitter plugin missing: install with Packer, then :TSInstall c cpp lua', vim.log.levels.WARN)
    return
end
-- Current main-branch API. No parser downloads or builds during startup/editing.
ts.setup({})
local group = vim.api.nvim_create_augroup('ConfigTreesitter', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = { 'c', 'cpp', 'lua', 'json', 'python', 'rust', 'markdown' },
    callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        local loaded, err = pcall(vim.treesitter.language.add, lang)
        if not loaded then
            vim.notify('Tree-sitter: ' .. tostring(err) .. '\nInstall with :TSInstall ' .. lang, vim.log.levels.WARN)
            return
        end
        -- Native start is idempotent and disables duplicate regex highlighting.
        vim.treesitter.start()
        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})
