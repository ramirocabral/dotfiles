-- import ls
local lspconfig_status, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status then
	return
end

-- import cmp-nvim-lsp plugin safely
local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_nvim_lsp_status then
	return
end

-- enable keybinds only for when lsp server available
local on_attach = function(client, bufnr)
	-- keybind options
	local opts = { noremap = true, silent = true, buffer = bufnr }

	vim.keymap.set("n", "gf", function() vim.lsp.buf.references() end, opts) -- show definition, references
	vim.keymap.set("n", "gD",function() vim.lsp.buf.declaration() end , opts) -- got to declaration
	vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts) -- see definition
	vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts) -- go to implementation
	vim.keymap.set("n", "<leader>ca",function() vim.lsp.buf.code_action() end, opts) -- see available code actions
	vim.keymap.set("n", "<leader>rn",function() vim.lsp.buf.rename() end, opts) -- smart rename
	vim.keymap.set("n", "<leader>D", function() vim.lsp.diagnostic.get_line_diagnostics() end, opts) -- show diagnostics for current line
	vim.keymap.set("n", "<leader>sd", function() vim.lsp.buf.hover() end, opts) --show documentation for what is under cursor
end

-- used to enable autocompletion (assign to every lsp server config)
local capabilities = cmp_nvim_lsp.default_capabilities()

-- configure html server
lspconfig["html"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

lspconfig["tsserver"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "javascript.jsx" },
})

lspconfig["eslint"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "javascript.jsx" },
})

lspconfig["tailwindcss"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "typescript", "typescriptreact", "typescript.tsx", "javascript", "javascriptreact", "javascript.jsx", "templ", "vue", "html", "astro", "htmlangular", "react"},
})

-- configure pyright server
lspconfig["pyright"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "python" },
})

-- configure lua server (with special settings)
lspconfig["lua_ls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
    filetypes = { "lua" },
	settings = { -- custom settings for lua
		Lua = {
			-- make the language server recognize "vim" global
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				-- make language server aware of runtime files
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
		},
	},

	lspconfig.clangd.setup({
		on_attach = on_attach,
		capabilities = capabilities,
        filetypes = { "c", "cpp", "objc", "objcpp" },
	}),
})

lspconfig["gopls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "go" },
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
			},
			staticcheck = true,
			completeUnimported = true,
		},
	}
})

lspconfig["templ"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})
