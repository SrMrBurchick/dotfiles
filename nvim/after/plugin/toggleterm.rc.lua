local status, toggleterm = pcall(require, "toggleterm")
if (not status) then return end

toggleterm.setup {
    direction = 'float'
}

local current_term = 1
local terms_count = 1

local function open_term(term_id)
    print("open term")
    if type(term_id) == 'number' then
        current_term = term_id

        vim.cmd(current_term .. 'ToggleTerm')

        local terms = require("toggleterm.terminal"):get_all()
        terms_count = #terms
    end
end

local function go_next_term()
    local next_term = current_term + 1
    if next_term <= terms_count then
        open_term(next_term)
    end
end

local function go_prev_term()
    local prev_term = current_term - 1
    if prev_term >= 1 then
        open_term(prev_term)
    end
end

vim.keymap.set('t', '<C-]>', function ()
    go_next_term()
end)
vim.keymap.set('t', '<C-[>', function ()
    go_prev_term()
end)

vim.keymap.set('n', '<C-t>t', function ()
    open_term(current_term)
end)
vim.keymap.set('n', '2<C-t>t', function ()
    open_term(2)
end)
vim.keymap.set('n', '3<C-t>t', function ()
    open_term(3)
end)

vim.keymap.set('t', '<C-d>', '<C-\\><C-n>:ToggleTerm<CR>')

