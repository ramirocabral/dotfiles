-- import mason plugin safely
local mason_status, mason = pcall(require, "mason")
if not mason_status then
	return
end

-- import mason-lspconfig plugin safely
local mason_lspconfig_status, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_status then
	return
end

-- enable mason
mason.setup()

mason_lspconfig.setup({
	-- list of servers for mason to install (lspconfig names, not mason's).
	-- Installed servers are enabled automatically with their config from
	-- lspconfig.lua.
	ensure_installed = {
		"bashls",
		"ts_ls",
		"html",
		"tailwindcss",
		"lua_ls",
		"clangd",
		"texlab",
		"pyright",
		"gopls",
		"eslint",
		"templ",
		"tinymist",
		"terraformls",
	},
})
