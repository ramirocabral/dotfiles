--set relativenumber
vim.opt.relativenumber = true
vim.opt.number = true

-- always 8 lines under when you scroll
vim.opt.scrolloff = 8

--some search shit
vim.opt.hlsearch = false
vim.opt.incsearch = true

--update times
vim.opt.updatetime = 750

vim.opt.cursorline = true

--tabs config
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true

--line wrapping
vim.opt.wrap = true

--appearance
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.signcolumn = "yes"

--backspace
vim.opt.backspace = "indent,eol,start"

--clipboard
vim.opt.clipboard:append("unnamedplus")

--split windows
vim.opt.splitright = true
vim.opt.splitbelow = true

-- now - sign is part of a word
vim.opt.iskeyword:append("-")
