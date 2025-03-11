--set relativenumber
vim.opt.relativenumber = true
vim.opt.number = true

vim.opt.showmode = false

-- always 8 lines under when you scroll
vim.opt.scrolloff = 8

--some search shit
vim.opt.hlsearch = false
vim.opt.incsearch = true

--update times
vim.opt.updatetime = 750

vim.opt.cursorline = true

vim.opt["guicursor"] = ""

--tabs config
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true

--line wrapping
vim.opt.wrap = true


vim.opt.mouse = ""



--appearance
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.signcolumn = "yes"
vim.g.nightflyTransparent = true

vim.opt.undofile = true

vim.opt.signcolumn = 'yes'

vim.opt.inccommand = 'split'

--backspace
vim.opt.backspace = "indent,eol,start"

--clipboard
vim.opt.clipboard:append("unnamedplus")

--split windows
vim.opt.splitright = true
vim.opt.splitbelow = true

-- now - sign is part of a word
vim.opt.iskeyword:append("-")

vim.cmd([[autocmd FileType * set formatoptions-=ro]])


-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- vim.diagnostic.config({ virtual_text = false })
