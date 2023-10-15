-- set leader key to space
vim.g.mapleader = " "

-------------------
--General keymaps--
-------------------

--movement
vim.keymap.set("n", "J", "mzJ`z") -- send bottom line to actual
vim.keymap.set("n", "n", "nzzzv") -- search terms stay in the middle
vim.keymap.set("n", "N", "Nzzzv") -- search terms(backwards) stay in the middle
vim.keymap.set("n", "K", "<esc>mpa<cr><esc>dd`pP`pa") -- in visual mode, move lines up with K

--clipboard management
vim.keymap.set("n", "<leader>y", [["+y]]) -- copy to system clipboard
vim.keymap.set("v", "<leader>y", [["+y]]) -- copy to system clipboard
vim.keymap.set("v", "<leader>u", [["+p]]) -- paste from system clipboard
vim.keymap.set("n", "<leader>u", [["+p]]) -- paste from system clipboard
vim.keymap.set("n", "<leader>d", [["_d]]) -- delete to void register
vim.keymap.set("v", "<leader>d", [["_d]]) -- delete to void register
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]) --replace ocurrences of word

-- ignores
vim.keymap.set("n", "s", "<nop>") -- ignore s
vim.keymap.set("n", "S", "<nop>") -- ignore S

--vertical split
vim.keymap.set("n", "<leader>v", ":vsplit<CR>")

--send deleted character to black h000le
vim.keymap.set("n", "x", '"_x')

-- window management
vim.keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
vim.keymap.set("n", "<leader>sh", "<C-w>s") -- split window horizontally
vim.keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
vim.keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window

vim.keymap.set("n", "<leader>to", ":tabnew<CR>") -- open new tab
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
vim.keymap.set("n", "<leader>tn", ":tabn<CR>") --  go to next tab
vim.keymap.set("n", "<leader>tp", ":tabp<CR>") --  go to previous tab

--moving between windows
vim.keymap.set("n", "<C-h>", "<C-w>h") -- Window left
vim.keymap.set("n", "<C-l>", "<C-w>l") -- Window right
vim.keymap.set("n", "<C-j>", "<C-w>j") -- Window down
vim.keymap.set("n", "<C-k>", "<C-w>k") -- Window up
vim.keymap.set("n", "<C-w>", ":q!<CR>") -- close window

-- CHAMOUD
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true }) --chmod current file

--save file
vim.keymap.set("n", "<C-s>", ":w<CR>") -- save file

-- shebang
vim.keymap.set("n", "<leader>b", "i#!/bin/sh") -- insert shebang

--visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv") -- in visual mode, move lines down with J
vim.keymap.set("v", "K", ":m '>-2<CR>gv=gv") -- in visual mode, move lines up with K

-------------------
--Plugins Keymaps--
-------------------

-- nvim-tree
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>") -- toggle file explorer

-- telescope
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- find files within current working directory, respects .gitignore
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
vim.keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags
vim.keymap.set("n", "<leader>fk", "<cmd>Telescope keymaps<cr>") -- list keymaps

-- disable git signs
vim.keymap.set("n", "<leader>tg", "<cmd>Gitsigns toggle_signs<cr>")

--compile c programs and see output on floating terminal
vim.keymap.set("n", "<leader>cc", "<cmd>!gcc %<cr> <cmd>TermExec cmd='./a.out'<cr>")
