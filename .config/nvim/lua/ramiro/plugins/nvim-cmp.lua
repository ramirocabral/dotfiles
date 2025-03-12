-- import nvim-cmp plugin safely
local cmp_status, cmp = pcall(require, "cmp")
if not cmp_status then
	return
end

-- import luasnip plugin safely
local luasnip_status, luasnip = pcall(require, "luasnip")
if not luasnip_status then
	return
end

require("luasnip/loaders/from_vscode").lazy_load()

vim.opt.completeopt = "menu,menuone,noselect"

cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-p>"] = cmp.mapping.select_prev_item(), -- previous suggestion
		["<C-n>"] = cmp.mapping.select_next_item(), -- next suggestion
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
		["<C-e>"] = cmp.mapping.abort(), -- close completion window
		["<CR>"] = cmp.mapping.confirm({ select = false }),
	}),
	-- sources for autocompletion
	sources = cmp.config.sources({
		{ name = "nvim_lsp" }, -- lsp
		{ name = "luasnip" }, -- snippets
		{ name = "buffer" }, -- text within current buffer
		{ name = "path" }, -- file system paths
	}),
	formatting = {
		fields = { "kind", "abbr", "menu" },
		format = function(entry, vim_item)
			vim_item.menu = ({
				nvim_lsp = "[LSP]",
				luasnip = "[LuaSnip]",
				buffer = "[Buffer]",
				path = "[Path]",
			})[entry.source.name]

			--for showing colors on tailwindcss autocomplete
			if vim_item.kind == 'Color' and entry.completion_item.documentation then

				if type(entry.completion_item.documentation) ~= 'table' then
					local _, _, r, g, b =
					---@diagnostic disable-next-line: param-type-mismatch
					string.find(entry.completion_item.documentation, '^rgb%((%d+), (%d+), (%d+)')
					local color

					if r and g and b then
						color = string.format('%02x', r) .. string.format('%02x', g) .. string.format('%02x', b)
					else
						color = entry.completion_item.documentation:gsub('#', '')
					end
					local group = 'Tw_' .. color

					if vim.api.nvim_call_function('hlID', { group }) < 1 then
						vim.api.nvim_command('highlight' .. ' ' .. group .. ' ' .. 'guifg=#' .. color)
					end

					vim_item.kind = '󰹞󰹞󰹞󰹞󰹞󰹞'
					vim_item.kind_hl_group = group
				end

			end

			return vim_item
		end
	}
})
