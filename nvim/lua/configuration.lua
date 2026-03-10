-- VS tasks
-- local status, vstask = pcall(require, "vstask")
-- if (status) then
--     vstask.setup({
--         use_harpoon = false, -- use harpoon to auto cache terminals
--         telescope_keys = { -- change the telescope bindings used to launch tasks
--             vertical = '<C-v>',
--             split = '<C-p>',
--             tab = '<C-t>',
--             current = '<CR>',
--         },
--         terminal = 'toggleterm',
--         term_opts = {
--             horizontal = {
--                 direction = "horizontal",
--                 size = "10"
--             },
--         }
--     })
--
--     -- VS launch
--     require("vslaunch").setup({
--         use_harpoon = false, -- use harpoon to auto cache terminals
--         telescope_keys = { -- change the telescope bindings used to launch tasks
--             vertical = '<C-v>',
--             split = '<C-p>',
--             tab = '<C-t>',
--             current = '<CR>',
--         },
--         terminal = 'toggleterm',
--         term_opts = {
--             horizontal = {
--                 direction = "horizontal",
--                 size = "10"
--             },
--         }
--     })
--
-- end

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


-- Minimal plugin to disable features for specific file types
-- local function disable_features_for_large_files()
--   -- Disable various settings to improve performance
--   vim.cmd("setlocal noswapfile")         -- Disable swap file
--   vim.cmd("setlocal noundofile")         -- Disable undo file
--   vim.cmd("setlocal nolist")             -- Disable listchars like tabs and EOL
--   vim.cmd("setlocal nonumber")           -- Disable line numbers
--   vim.cmd("setlocal norelativenumber")   -- Disable relative line numbers
--   vim.cmd("syntax off")                  -- Disable syntax highlighting
--   vim.cmd("filetype off")                -- Disable filetype detection
--   vim.cmd("setlocal foldcolumn=0")       -- Disable fold column
-- end
--
-- -- Autocmd for disabling features based on file type or size
-- vim.api.nvim_create_autocmd({"BufReadPre", "FileReadPre"}, {
--   pattern = {"*.txt", "*.log", "*.csv"},  -- Add file types here
--   callback = function()
--     disable_features_for_large_files()
--   end,
-- })
--
-- -- Optional: Disable features for large files (over 1MB in this case)
-- vim.api.nvim_create_autocmd({"BufReadPre"}, {
--   pattern = "*",
--   callback = function()
--     local file_size = vim.fn.getfsize(vim.fn.expand('%:p'))
--     local size_limit = 1024 * 1024 -- 1 MB limit
--     if file_size > size_limit then
--       disable_features_for_large_files()
--     end
--   end,
-- })
