-- VS tasks
local status, vstask = pcall(require, "vstask")
if (status) then
    vstask.setup({
        use_harpoon = false, -- use harpoon to auto cache terminals
        telescope_keys = { -- change the telescope bindings used to launch tasks
            vertical = '<C-v>',
            split = '<C-p>',
            tab = '<C-t>',
            current = '<CR>',
        },
        terminal = 'toggleterm',
        term_opts = {
            horizontal = {
                direction = "horizontal",
                size = "10"
            },
        }
    })

    -- VS launch
    require("vslaunch").setup({
        use_harpoon = false, -- use harpoon to auto cache terminals
        telescope_keys = { -- change the telescope bindings used to launch tasks
            vertical = '<C-v>',
            split = '<C-p>',
            tab = '<C-t>',
            current = '<CR>',
        },
        terminal = 'toggleterm',
        term_opts = {
            horizontal = {
                direction = "horizontal",
                size = "10"
            },
        }
    })

end

-- Comments
local comment = {}

status, comment = pcall(require, "Comment")
if status then
    comment.setup()
end

-- Bufferline
local bufferline = {}

status, bufferline = pcall(require, "bufferline")
if status then
    bufferline.setup()
end

-- Standalone UI for nvim-lsp progress.
local fidget = {}

status, fidget = pcall(require, "fidget")
if status then
    fidget.setup()
end
