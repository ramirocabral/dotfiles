-- import nvim-treesitter plugin safely (main branch: no nvim-treesitter.configs)
local status, treesitter = pcall(require, "nvim-treesitter")
if not status then
	return
end

-- ensure these language parsers are installed. Runs in the background and skips
-- the ones already installed; compiling needs the tree-sitter CLI.
treesitter.install({
	"json",
	"javascript",
	"typescript",
	"tsx",
	"yaml",
	"html",
	"css",
	"markdown",
	"markdown_inline",
	"svelte",
	"graphql",
	"bash",
	"lua",
	"vim",
	"dockerfile",
	"gitignore",
	"java",
	"c",
	"cpp",
	"latex",
	"python",
	"go",
	"terraform",
	"hcl",
})

-- enable syntax highlighting and indentation wherever a parser is installed
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("ramiro_treesitter", { clear = true }),
	callback = function(args)
		if pcall(vim.treesitter.start, args.buf) then
			vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

-- enable autotagging (w/ nvim-ts-autotag plugin)
local autotag_status, autotag = pcall(require, "nvim-ts-autotag")
if autotag_status then
	autotag.setup()
end
