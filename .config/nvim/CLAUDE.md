# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Personal Neovim config (Lua), part of the larger `~/dotfiles` repo — see `../../CLAUDE.md` for the dotfiles/Stow install pipeline. This directory is stowed to `~/.config/nvim`.

## No test/lint tooling

Like the parent repo, there is no test suite. To validate a change actually loads without errors, run headless:

```sh
nvim --headless "+qa"        # exits non-zero / prints errors on a broken config
nvim --headless "+checkhealth" "+qa"
```

## Plugin management: Packer (not lazy.nvim)

Plugins are declared in `lua/ramiro/plugins-setup.lua` via `use(...)`. `plugin/packer_compiled.lua` is **generated** — never hand-edit it; regenerate with `:PackerCompile` (or `:PackerSync` to also install/update). On a fresh machine `plugins-setup.lua` bootstraps Packer itself by cloning it into `stdpath("data")`.

### Adding a plugin requires THREE edits, not one

`init.lua` does **not** auto-load plugin config modules — it lists each `require(...)` explicitly and in a deliberate order. To add a plugin:

1. Add `use("author/plugin")` in `lua/ramiro/plugins-setup.lua`.
2. Create its config module under `lua/ramiro/plugins/` (or `lua/ramiro/plugins/lsp/`).
3. Add a `require("ramiro.plugins.<name>")` line to `init.lua`.

Omitting step 3 means the plugin installs but is never configured. Commented-out `require` lines in `init.lua` (e.g. `null-ls`) are the intended way features are toggled off.

### Defensive pcall pattern

Every plugin module guards its `require` with `pcall(...)` and returns early on failure. Preserve this — on first launch Packer installs asynchronously, so modules may run before their plugin exists.

## Structure

- `init.lua` — the ordered load manifest (see above); also sets the colorscheme (`tokyonight-night`).
- `lua/ramiro/core/` — `options.lua`, `keymaps.lua`, `colorscheme.lua`. Editor-wide settings and all non-LSP keymaps live here.
- `lua/ramiro/plugins/` — one module per plugin, each named after the plugin.
- `lua/ramiro/plugins/lsp/` — `mason.lua`, `lspconfig.lua`, `null-ls.lua` (disabled).
- `lua/ramiro/snippets/` — LuaSnip snippets (e.g. `tex.lua`).
- `spell/` — custom spell dictionaries (`spelllang` is `es`).

## LSP setup

Uses the newer **`vim.lsp.config`** API (Neovim 0.11+) — `lspconfig.lua` aliases `local lspconfig = vim.lsp.config` and assigns `lspconfig["server"] = {...}`; it is **not** the classic `require("lspconfig").server.setup{}` style. When editing, match this form.

Server lifecycle spans two files: declare the server name in `mason.lua`'s `ensure_installed` (Mason installs the binary) **and** add its config block in `lspconfig.lua` (capabilities + shared `on_attach`). The `on_attach` in `lspconfig.lua` defines the buffer-local LSP keymaps (`gd`, `gf`, `<leader>ca`, `<leader>rn`, etc.).

## Conventions

- Leader is `<Space>` (set at the top of `keymaps.lua`).
- Many default keys are remapped to use the black-hole register (`c`, `x`, `<leader>d`) so they don't clobber yanks; `s`/`S` are `<nop>`. Keep this in mind before adding mappings on those keys.
- Custom `:command`s and autocmds (e.g. `:TypstCompileWatch`) live in `core/options.lua`.
