if has("nvim")
    let g:plug_home = stdpath('data') . '/plugged'
endif

call plug#begin()

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'cohama/lexima.vim'

if has("nvim")
    Plug 'hoob3rt/lualine.nvim'
    Plug 'kristijanhusak/defx-git'
    Plug 'kristijanhusak/defx-icons'
    Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
    Plug 'neovim/nvim-lspconfig'
    Plug 'glepnir/lspsaga.nvim'
    Plug 'folke/lsp-colors.nvim'
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'saadparwaiz1/cmp_luasnip'
    Plug 'L3MON4D3/LuaSnip'
    Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'nvim-lua/popup.nvim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'akinsho/toggleterm.nvim', {'tag' : 'v2.*'}
    Plug 'nvim-telescope/telescope-file-browser.nvim'
    Plug 'williamboman/mason.nvim'
    Plug 'williamboman/mason-lspconfig.nvim'
    Plug 'neoclide/coc-snippets'
    Plug 'rafamadriz/friendly-snippets'
endif

Plug 'https://github.com/preservim/nerdtree.git'
Plug 'ryanoasis/vim-devicons'
Plug 'https://github.com/rafi/awesome-vim-colorschemes.git'
Plug 'airblade/vim-gitgutter'
Plug 'rhysd/git-messenger.vim'
Plug 'kamykn/spelunker.vim'
Plug 'tibabit/vim-templates'
Plug 'https://github.com/preservim/tagbar.git'
Plug 'https://github.com/drichardson/vim-unreal.git'
Plug 'sheerun/vim-polyglot'

call plug#end()
