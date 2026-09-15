local ok, colors = pcall(require, 'nvim-highlight-colors')
if ok then
    colors.setup({ render = 'background', enable_named_colors = true, enable_tailwind = true })
end
