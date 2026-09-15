local status, tz = pcall(require, 'true-zen')

if (not status) then
    return
end

tz.setup {
    -- your config goes here
    -- or just leave it empty :)
}

vim.api.nvim_set_keymap("n", "<C-f>", ":TZFocus<CR>", {})
