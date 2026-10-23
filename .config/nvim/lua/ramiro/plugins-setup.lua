-- auto install lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- import lazy safely
local status, lazy = pcall(require, "lazy")
if not status then
	return
end

-- add list of plugins to install. Versions are pinned in lazy-lock.json
-- (`:Lazy restore` to go back to them, `:Lazy update` to move them).
lazy.setup({
	"nvim-lua/plenary.nvim", -- lua functions that many plugins use

	"folke/tokyonight.nvim",

	--colorschemes
	"bluz71/vim-nightfly-guicolors",
	{ "catppuccin/nvim", name = "catppuccin" },
	"sainnhe/sonokai",
	{
		"daltonmenezes/aura-theme",
		-- the neovim theme lives in a subdirectory of the repo
		config = function(plugin)
			vim.opt.rtp:append(plugin.dir .. "/packages/neovim")
		end,
	},
	"bluz71/vim-moonfly-colors",
	"navarasu/onedark.nvim",

	-- add, delete, change surroundings
	"tpope/vim-surround",

	--detect tabstop and shiftwidth automatically
	"tpope/vim-sleuth",

	-- commenting with gc
	"numToStr/Comment.nvim",

	-- file explorer
	"nvim-tree/nvim-tree.lua",

	-- vs-code like icons
	"nvim-tree/nvim-web-devicons",

	-- statusline
	"nvim-lualine/lualine.nvim",

	-- fuzzy finding w/ telescope
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" }, -- dependency for better sorting performance
	{ "nvim-telescope/telescope.nvim", branch = "master" }, -- fuzzy finder

	-- autocompletion
	"hrsh7th/nvim-cmp", -- completion plugin
	"hrsh7th/cmp-buffer", -- source for text in buffer
	"hrsh7th/cmp-path", -- source for file system paths
	"hrsh7th/cmp-nvim-lsp", -- for autocompletion
	"saadparwaiz1/cmp_luasnip", -- for autocompletion

	-- snippets
	"L3MON4D3/LuaSnip", -- snippet engine
	"rafamadriz/friendly-snippets", -- useful snippets

	-- managing & installing lsp servers
	"williamboman/mason.nvim", -- in charge of managing lsp servers
	"williamboman/mason-lspconfig.nvim", -- bridges gap b/w mason & lspconfig

	-- configuring lsp servers
	"neovim/nvim-lspconfig", -- easily configure language servers

	-- treesitter configuration. The main branch is a rewrite: there is no
	-- nvim-treesitter.configs module, and it does not support lazy-loading.
	{ "nvim-treesitter/nvim-treesitter", branch = "main", build = ":TSUpdate" },

	-- auto closing
	"windwp/nvim-autopairs", -- autoclose parens, brackets, quotes, etc...
	"windwp/nvim-ts-autotag", -- autoclose tags

	-- git integration
	"lewis6991/gitsigns.nvim",

	--vimtex
	"lervag/vimtex",

	-- copilot
	"github/copilot.vim",

	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	--colorizer
	"norcalli/nvim-colorizer.lua",
}, {
	-- load everything at startup, as packer did: each plugin is configured by
	-- its module, required from init.lua right after this file.
	defaults = { lazy = false },
	install = { colorscheme = { "tokyonight-night" } },
	change_detection = { notify = false },
})
