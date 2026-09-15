local status, packer = pcall(require, "packer")
if (not status) then
    print("Packer is not installed")
    return
end

vim.cmd [[packadd packer.nvim]]

packer.startup(function(use)
    -- Packer
    use 'wbthomason/packer.nvim'

    -- UI
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons' }
    }
    use 'rafi/awesome-vim-colorschemes'
    use 'scottmckendry/cyberdream.nvim'

    -- Setup lives in after/plugin; all packages here load eagerly.
    use 'brenoprata10/nvim-highlight-colors'
    use 'hat0uma/csvview.nvim'

     -- QML
    use 'artoj/qmake-syntax-vim'
    use 'peterhoeg/vim-qml'
    use {
        'Decodetalkers/neoqmllsp',
        run = "cargo build --release"
    }

    -- Native highlighting; install/update parsers explicitly, never on buffer entry.
    use { 'nvim-treesitter/nvim-treesitter', branch = 'main', run = ':TSUpdate' }

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

    -- Markdown preview
    use({
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    })

    -- Other
    use 'kamykn/spelunker.vim'
    use 'windwp/nvim-autopairs'

    use {
        'kyazdani42/nvim-tree.lua',
    }


    -- Debugger
    use "mfussenegger/nvim-dap"
    use "jay-babu/mason-nvim-dap.nvim"

    use {
        "rcarriga/nvim-dap-ui",
        requires = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio"
        }
    }

    use {
        'startup-nvim/startup.nvim',
        requires = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
    }
    use '~/Projects/buffer_highlight.nvim'
    use 'javiorfo/nvim-soil'
    -- Optional for puml syntax highlighting:
    use 'javiorfo/nvim-nyctophilia'
    -- use 'SrMrBurchick/perforce.nvim'
    use '/home/srmrburchick/Projects/sqlui'
    use({
        "Pocco81/true-zen.nvim",
    })
    use("mangelozzi/nvim-rgflow.lua")
end)
