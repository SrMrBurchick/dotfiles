local status, telescope = pcall(require, "telescope")
if (not status) then return end
local actions = require('telescope.actions')
local builtin = require("telescope.builtin")

local function telescope_buffer_dir()
    return vim.fn.expand('%:p:h')
end

local fb_actions = require "telescope".extensions.file_browser.actions
telescope.setup {
    defaults = {
        vimgrep_arguments = vim.list_extend({
            'rg', '--color=never', '--no-heading', '--with-filename',
            '--line-number', '--column', '--smart-case',
        }, require('ue_paths').rg_args()),
        mappings = {
            n = {
                ["q"] = actions.close
            },
        },
    },
    pickers = {
        buffers = {
            mappings = {
                i = {
                    ["<C-d>"] = "delete_buffer",
                },
                n = {
                    ["d"] = "delete_buffer",
                },
            }
        }
    },
    extensions = {
        project = {
            base_dirs = {
            },
            hidden_files = true, -- default: false
            theme = "dropdown",
            order_by = "asc",
            sync_with_nvim_tree = true,
        },
        file_browser = {
            depth = 1, -- bound the plugin's synchronous grouped/fallback scans
            git_status = false, -- Perforce: no synchronous git status calls
            follow_symlinks = false,
            file_ignore_patterns = require('ue_paths').ignore_patterns(),
            theme = "dropdown",
            -- disables netrw and use telescope-file-browser in its place
            hijack_netrw = true,
            mappings = {
                -- your custom insert mode mappings
                ["i"] = {
                    ["<C-w>"] = function() vim.cmd('normal vbd') end,
                },
                ["n"] = {
                    -- your custom normal mode mappings
                    ["N"] = fb_actions.create,
                    ["h"] = fb_actions.goto_parent_dir,
                    ["/"] = function()
                        vim.cmd('startinsert')
                    end
                },
            },
        }
    },
}

telescope.load_extension("file_browser")
telescope.load_extension('project')

local function get_cwd()
    return vim.t.root_dir or vim.fn.getcwd()
end

vim.keymap.set('n', ';f',
    function()
        builtin.find_files({
            find_command = vim.list_extend({ 'rg', '--files', '--hidden', '--no-ignore' }, require('ue_paths').rg_args()),
            hidden = true,
            cwd = get_cwd()
        })
    end)
vim.keymap.set('n', ';r', function()
    builtin.live_grep({
        cwd = get_cwd()
    })
end)
vim.keymap.set('n', '\\\\', function()
    builtin.buffers()
end)
vim.keymap.set('n', ';t', function()
    builtin.help_tags()
end)
vim.keymap.set('n', ';;', function()
    builtin.resume()
end)
vim.keymap.set('n', ';e', function()
    builtin.diagnostics()
end)
vim.keymap.set("n", "sf", function()
    telescope.extensions.file_browser.file_browser({
        theme = "ivy",
        path = "%:p:h",
        cwd = telescope_buffer_dir(),
        respect_gitignore = false,
        hidden = true,
        grouped = true,
        previewer = false,
        initial_mode = "normal",
        layout_config = { height = 40 }
    })
end)
