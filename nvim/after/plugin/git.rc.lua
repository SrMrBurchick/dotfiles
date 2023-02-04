-- Keymaps
vim.keymap.set('n', '<M-g>m', '<CMD>GitMessenger<CR>')
vim.keymap.set('n', '<M-g>b', '<CMD>Git blame<CR>')

vim.keymap.set('n', '<M-g>a', function ()
    require('toggleterm').exec('git add -p')
end)

vim.keymap.set('n', '<M-g>d', function ()
    require('toggleterm').exec('git diff')
end)

vim.keymap.set('n', '<M-g>r', function ()
    require('toggleterm').exec('git restore --staged -p .')
end)

vim.keymap.set('n', '<M-g>s', function ()
    vim.cmd('Telescope git_status')
end)

vim.keymap.set('n', '<M-g>u', function ()
    require('toggleterm').exec('git fetch origin dev')
end)
local status, git_blame = pcall(require, 'blame_line')
if (not status) then
    return
end

git_blame.setup {
    -- whether the blame line should be shown in visual modes
    show_in_visual = true,

    -- whether the blame line should be shown in insert mode
    show_in_insert = true,

    -- the string to prefix the blame line with
    prefix = " ",

    -- String specifying the the blame line format.
    -- Any combination of the following specifiers, along with any additional text.
    --     - `"<author>"` - the author of the change.
    --     - `"<author-mail>"` - the email of the author.
    --     - `"<author-time>"` - the time the author made the change.
    --     - `"<committer>"` - the person who committed the change to the repository.
    --     - `"<committer-mail>"` - the email of the committer.
    --     - `"<committer-time>"` - the time the change was committed to the repository.
    --     - `"<summary>"` - the commit summary/message.
    --     - `"<commit-short>"` - short portion of the commit hash.
    --     - `"<commit-long>"` - the full commit hash.
    template = "<author> • <author-time> • <summary>",

    -- The date format settings, for `"<author-time>"` and `"<committer-time>"`
    date = {
        -- whether the date should be relative instead of precise
        -- (I.E. "3 days ago" instead of "09-06-2022".
        relative = true,

        -- `strftime` compatible format string.
        -- Only used if `date.relative == false`
        format = "%d-%m-%y",
    },

    -- The highlight group to highlight the blame line with.
    -- The highlight of this group defaults to `Comment`.
    hl_group = "BlameLineNvim",

    -- The delay in milliseconds between a cursor movement and
    -- when the blame line should appear/update
    delay = 0,
}

