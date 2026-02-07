vim.g.mapleader = " "

vim.keymap.set("n", "<leader>e", "<CMD>Neotree toggle<CR>")
vim.keymap.set("n", "<M-j>", "<CMD>resize -2<CR>")
vim.keymap.set("n", "<M-k>", "<CMD>resize +2<CR>")
vim.keymap.set("n", "<M-h>", "<CMD>vertical resize +2<CR>")
vim.keymap.set("n", "<M-l>", "<CMD>vertical resize -2<CR>")

-- toggle term
vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<cr>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>ff", function()
	require("conform").format({
		lsp_fallback = true,
		async = false,
		--timeout_ms = 500,
	})
end, { desc = "Format file (Conform)" })
