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
    use 'rafi/awesome-vim-colorschemes'
    use 'scottmckendry/cyberdream.nvim'

    -- CSS
    use {
        'brenoprata10/nvim-highlight-colors',
        config = function()
            require("nvim-highlight-colors").setup {
                render = 'background', -- or 'foreground' or 'first_column'
                enable_named_colors = true,
                enable_tailwind = true
            }
        end
    }


     -- QML
    use 'artoj/qmake-syntax-vim'
    use 'peterhoeg/vim-qml'
    use {
        use 'Decodetalkers/neoqmllsp',
        run = "cargo build --release"
    }

    -- LSP
    use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
    use 'hrsh7th/nvim-cmp'      -- Autocompletion plugin
    use 'hrsh7th/cmp-nvim-lsp'  -- LSP source for nvim-cmp
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-buffer'
    use 'onsails/lspkind.nvim'  -- vscode-like pictograms
    use({
        "glepnir/lspsaga.nvim",
        branch = "main",
    })

    -- Snippets
    use({
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        tag = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!:).
        run = "make install_jsregexp"
    })
    use 'saadparwaiz1/cmp_luasnip'
    use 'rafamadriz/friendly-snippets'

    -- Mason
    use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'

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
    -- use 'tpope/vim-fugitive'
    -- use 'airblade/vim-gitgutter'
    -- use 'rhysd/git-messenger.vim'
    -- use 'braxtons12/blame_line.nvim'
    -- use {
    --     'tanvirtin/vgit.nvim',
    --     requires = {
    --         'nvim-lua/plenary.nvim'
    --     },
    --     config = function()
    --         require('vgit').setup()
    --     end
    --
    -- }


    -- Markdown preview
    use({
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    })

    -- Other
    -- use 'arithran/vim-delete-hidden-buffers'
    use 'kamykn/spelunker.vim'
    use 'windwp/nvim-autopairs'

    -- Commenting util
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }


    use {
        'kyazdani42/nvim-tree.lua',
        -- requires = {
        --     'kyazdani42/nvim-web-devicons', -- optional, for file icons
        -- },
        -- tag = 'nightly'                     -- optional, updated every week. (see issue #1193)
    }


    -- Debugger
    use {
        "mfussenegger/nvim-dap",
        "jay-babu/mason-nvim-dap.nvim",
    }

    use {
        "rcarriga/nvim-dap-ui",
        requires = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio"
        }
    }

    use {
      "startup-nvim/startup.nvim",
      requires = {"nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim"},
      config = function()
        require"startup".setup()
      end
    }

    -- use 'SrMrBurchick/perforce.nvim'
end)
