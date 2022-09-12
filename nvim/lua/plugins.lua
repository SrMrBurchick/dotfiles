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
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }
    use {
        'akinsho/bufferline.nvim',
        tag = "v2.*",
        requires = 'kyazdani42/nvim-web-devicons'
    }
    use 'rafi/awesome-vim-colorschemes'
    -- Text->Color UI
    use 'NvChad/nvim-colorizer.lua'
    use 'max397574/colortils.nvim'


    -- LSP
    use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
    use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
    use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
    use 'glepnir/lspsaga.nvim' -- Lightweight LSP UI
    use 'onsails/lspkind.nvim' -- vscode-like pictograms
    use 'j-hui/fidget.nvim' -- Standalone UI for nvim-lsp progress


    -- Snippets
    use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
    use 'L3MON4D3/LuaSnip' -- Snippets plugin


    -- Mason
    use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'


    -- Language based highlight
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
    -- Treesitter highlight colorizer
    use 'p00f/nvim-ts-rainbow'
    use 'windwp/nvim-ts-autotag'


    -- Icons
    use 'kyazdani42/nvim-web-devicons'
    use 'ryanoasis/vim-devicons'


    -- Telescope stuff
    use 'nvim-lua/popup.nvim'
    use 'nvim-lua/plenary.nvim'
    use 'nvim-telescope/telescope.nvim'
    use 'nvim-telescope/telescope-file-browser.nvim'
    use 'akinsho/toggleterm.nvim'
    -- Telescope media files preview
    use 'nvim-telescope/telescope-media-files.nvim'


    -- Git
    use 'tpope/vim-fugitive'
    use 'airblade/vim-gitgutter'
    use 'rhysd/git-messenger.vim'
    use {
        'pwntester/octo.nvim',
        requires = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope.nvim',
            'kyazdani42/nvim-web-devicons',
        },
        config = function()
            require "octo".setup()
        end
    }


    -- Refactoring server
    use {
        "ThePrimeagen/refactoring.nvim",
        requires = {
            { "nvim-lua/plenary.nvim" },
            { "nvim-treesitter/nvim-treesitter" }
        }
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
    use 'preservim/nerdtree'
    use 'arithran/vim-delete-hidden-buffers'
    use 'rhysd/vim-clang-format'
    use 'preservim/tagbar'
    use 'kamykn/spelunker.vim'
    use 'tibabit/vim-templates'
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

end)
