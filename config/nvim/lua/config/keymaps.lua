local keymap = vim.keymap

vim.g.mapleader = " "

-- Directory navigation
keymap.set("n", "<leader>e", ":Lex 20<cr>")

-- Window navigation
keymap.set("n", "<C-h>", "<C-w>h")
keymap.set("n", "<C-j>", "<C-w>j")
keymap.set("n", "<C-k>", "<C-w>k")
keymap.set("n", "<C-l>", "<C-w>l")

-- Clear search highlights
keymap.set("n", "<leader>nh", ":nohlsearch<cr>")
