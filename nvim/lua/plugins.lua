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
	use { "scottmckendry/cyberdream.nvim" }
	use({
		"Pocco81/true-zen.nvim",
	})
	use {
		'akinsho/bufferline.nvim',
		branch = 'main',
		requires = 'kyazdani42/nvim-web-devicons'
	}
	use 'rafi/awesome-vim-colorschemes'
	-- use 'romgrk/barbar.nvim'

	use {
		'kyazdani42/nvim-tree.lua',
	}

	-- LSP
	use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
	use 'hrsh7th/nvim-cmp'      -- Autocompletion plugin
	use 'hrsh7th/cmp-nvim-lsp'  -- LSP source for nvim-cmp
	use 'hrsh7th/cmp-path'
	use 'hrsh7th/cmp-buffer'
	use 'ray-x/lsp_signature.nvim'
	use 'onsails/lspkind.nvim'  -- vscode-like pictograms
	use({
		"glepnir/lspsaga.nvim",
		branch = "main",
	})
	-- use 'lvimuser/lsp-inlayhints.nvim'
	-- use 'netmute/ctags-lsp.nvim'

	-- Rust
	-- use 'simrat39/rust-tools.nvim'

	-- Snippets
	use 'L3MON4D3/LuaSnip' -- Snippets plugin

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
	use 'xiyaowong/telescope-emoji.nvim'

	use 'windwp/nvim-autopairs'

	-- Commenting util
	use {
		'numToStr/Comment.nvim',
		config = function()
			require('Comment').setup()
		end
	}
	use 'mangelozzi/nvim-rgflow.lua'

	-- Debugger
	use {
		"mfussenegger/nvim-dap",
		"jay-babu/mason-nvim-dap.nvim",
		"mxsdev/nvim-dap-vscode-js"
	}

	use {
		"rcarriga/nvim-dap-ui",
		requires = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio"
		}
	}

	use 'SrMrBurchick/perforce.nvim'
	use 'D:/Tools/cpphelper.nvim'
	use 'javiorfo/nvim-soil'

	-- Optional for puml syntax highlighting:
	use 'javiorfo/nvim-nyctophilia'

	use 'Pocco81/true-zen.nvim'
	use 'C:\\Users\\s.Bura\\AppData\\Local\\nvim-data\\site\\pack\\packer\\start\\markdown-preview.nvim'
	use "D:\\Toos\\cpphelper.nvim"
	use 'rcarriga/nvim-notify'
	-- use({ "iamcco/markdown-preview.nvim", run = "cd app && npm install", setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" }, })
end)
