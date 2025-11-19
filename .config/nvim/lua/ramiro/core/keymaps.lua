vim.g.mapleader = " "

-------------------
--General keymaps--
-------------------
--movement
vim.keymap.set("n", "j", "gj") --move down in wrapped lines
vim.keymap.set("n", "k", "gk") --move up in wrapped lines

vim.keymap.set("n", "J", "mzJ`z") -- send bottom line to actual
vim.keymap.set("n", "n", "nzzzv") -- search terms stay in the middle
vim.keymap.set("n", "N", "Nzzzv") -- search terms(backwards) stay in the middle

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

--send deleted character to black h000le
vim.keymap.set("n", "x", '"_x')

-- window management
vim.keymap.set("n", "<leader>v", ":vsplit<CR>") -- split window vertically
vim.keymap.set("n", "<leader>V", ":split<CR>") -- split window horizontally

vim.keymap.set("n", "<leader>to", ":tabnew<CR>") -- open new tab
vim.keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
vim.keymap.set("n", "<leader>tn", ":tabn<CR>") --  go to next tab
vim.keymap.set("n", "<leader>tp", ":tabp<CR>") --  go to previous tab
vim.keymap.set("n", "<leader>q", ":q!<CR>")

--moving between windows
vim.keymap.set("n", "<C-h>", ":wincmd h<CR>") -- Window left
vim.keymap.set("n", "<C-l>", ":wincmd l<CR>") -- Window right
vim.keymap.set("n", "<C-j>", ":wincmd j<CR>") -- Window down
vim.keymap.set("n", "<C-k>", "wincmd k<CR>") -- Window up
-- vim.keymap.set("n", "<C-w>", ":q!<CR>") -- close window

--resize windows
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>") -- increase window height
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>") -- decrease window height
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>") -- increase window width
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>") -- decrease window width

-- CHAMOUD
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true }) --chmod current file

--save file
vim.keymap.set("n", "<C-s>", ":w<CR>") -- save file

-- shebang
vim.keymap.set("n", "<leader>b", "i#!/bin/sh") -- insert shebang

--visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv") -- in visual mode, move lines down with J
vim.keymap.set("v", "K", ":m '>-2<CR>gv=gv") -- in visual mode, move lines up with K

vim.keymap.set("x", "p", [["_dP]]) --paste without yanking in visual mode

--indentation

vim.keymap.set("v", "<", "<gv") -- indent left in visual mode
vim.keymap.set("v", ">", ">gv") -- indent right in visual mode

-------------------
--Plugins Keymaps--
-------------------

-- nvim-tree
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>") -- toggle file explorer

-- telescope
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- find files within current working directory, respects .gitignore
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope git_files<cr>") -- find tracked git files
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
vim.keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags
vim.keymap.set("n", "<leader>fk", "<cmd>Telescope keymaps<cr>") -- list keymaps

-- toggle git signs
vim.keymap.set("n", "<leader>tg", "<cmd>Gitsigns toggle_signs<cr>")

--compile c programs and see output on floating terminal
vim.keymap.set("n", "<leader>cc", "<cmd>!gcc %<cr> <cmd>TermExec cmd='./a.out'<cr>")

-- disable/enable spellchecking
vim.keymap.set("n", "<leader>sp", function()
  vim.opt.spell = not vim.opt.spell:get()
end)

-- see spelling suggestions
vim.keymap.set("n", "<leader>wS", "z=")
-- add word to dictionary
vim.keymap.set("n", "<leader>wi", "zg")


local function auto_correct_first_suggestion()
  local word = vim.fn.expand("<cword>")
  local suggestions = vim.fn.spellsuggest(word, 1)

  if #suggestions == 0 then
    print("No suggestions found for '" .. word .. "'")
    return
  end

  local replacement = suggestions[1]
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local col = cursor_pos[2]

  local pattern = "\\<" .. word .. "\\>"
  local s, e = vim.regex(pattern):match_str(line)
  if not s then
    print("Could not find word '" .. word .. "' in the current line.")
    return
  end

  local new_line = line:sub(1, s) .. replacement .. line:sub(e + 1)
  vim.api.nvim_set_current_line(new_line)

  vim.api.nvim_win_set_cursor(0, { cursor_pos[1], s + #replacement })
  print("Replaced '" .. word .. "' with '" .. replacement .. "'")
end

vim.keymap.set("n", "<leader>ws", auto_correct_first_suggestion, { desc = "Auto-correct with first spelling suggestion" })
