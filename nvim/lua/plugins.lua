local status, packer = pcall(require, "packer")
if (not status) then
    print("Packer is not installed")
    return
end

vim.cmd [[packadd packer.nvim]]

packer.startup(function(use)
    -- Packer
    use 'wbthomason/packer.nvim'

    -- Large Files
    use {
      "LunarVim/bigfile.nvim",
    }

    -- UI
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }
    use {
        'akinsho/bufferline.nvim',
        tag = "v2.*",
        requires = 'kyazdani42/nvim-web-devicons'
    }
    use 'rafi/awesome-vim-colorschemes'

    -- CSS
    use {
        'brenoprata10/nvim-highlight-colors',
        config = function()
            require("nvim-highlight-colors").setup {
                render = 'background', -- or 'foreground' or 'first_column'
                enable_named_colors = true,
                enable_tailwind = false
            }
        end
    }

    -- Notify
    use {
        'mrded/nvim-lsp-notify',
        requires = { 'rcarriga/nvim-notify' },
    }

    -- LSP
    use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
    use 'hrsh7th/nvim-cmp'      -- Autocompletion plugin
    use 'hrsh7th/cmp-nvim-lsp'  -- LSP source for nvim-cmp
    use 'hrsh7th/cmp-path'
    use 'onsails/lspkind.nvim'  -- vscode-like pictograms
    use({
        "glepnir/lspsaga.nvim",
        branch = "main",
    })
    use 'lvimuser/lsp-inlayhints.nvim'

    -- Snippets
    use 'L3MON4D3/LuaSnip' -- Snippets plugin


    -- Mason
    use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'

    use {
        "mfussenegger/nvim-dap",
        "jay-babu/mason-nvim-dap.nvim",
    }

    -- Language based highlight
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
    -- Treesitter highlight colorizer
    use 'p00f/nvim-ts-rainbow'


    -- Icons
    use 'kyazdani42/nvim-web-devicons'
    use 'ryanoasis/vim-devicons'


    -- Telescope stuff
    use 'nvim-lua/popup.nvim'
    use 'nvim-lua/plenary.nvim'
    use 'nvim-telescope/telescope.nvim'
    use 'nvim-telescope/telescope-file-browser.nvim'
    use 'nvim-telescope/telescope-project.nvim'
    -- Telescope media files preview
    use 'nvim-telescope/telescope-media-files.nvim'


    -- Git
    use 'tpope/vim-fugitive'
    use 'airblade/vim-gitgutter'
    use 'rhysd/git-messenger.vim'
    -- use 'braxtons12/blame_line.nvim'
    use {
        'tanvirtin/vgit.nvim',
        requires = {
            'nvim-lua/plenary.nvim'
        },
        config = function()
            require('vgit').setup()
        end

    }


    -- Markdown preview
    use({
        "iamcco/markdown-preview.nvim",
        run = "cd app && npm install",
        setup = function() vim.g.mkdp_filetypes = { "markdown" } end,
        ft = { "markdown" },
        opt = true
    })


    -- Other
    use 'arithran/vim-delete-hidden-buffers'
    use 'kamykn/spelunker.vim'
    use 'windwp/nvim-autopairs'


    -- VScode tasks & launches
    use {
        'SrMrBurchick/vs-tasks.nvim',
        branch = 'new_feature',
        requires = {
            'nvim-lua/popup.nvim',
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope.nvim'
        }
    }


    -- Commenting util
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }


    use {
        'kyazdani42/nvim-tree.lua',
        requires = {
            'kyazdani42/nvim-web-devicons', -- optional, for file icons
        },
        tag = 'nightly'                     -- optional, updated every week. (see issue #1193)
    }


    -- Debugger
    use {
        'rcarriga/nvim-dap-ui',
        requires = {
            'mfussenegger/nvim-dap'
        }
    }

    use 'akinsho/toggleterm.nvim'

    use {
        "princejoogie/chafa.nvim",
        requires = {
            "nvim-lua/plenary.nvim",
            "m00qek/baleia.nvim"
        },
    }
end)
