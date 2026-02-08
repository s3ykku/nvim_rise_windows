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

-- COPILOT:
-- показать подсказку (на самом деле: запросить первую/следующую)
vim.keymap.set("i", "<M-s>", function()
	local ok, sug = pcall(require, "copilot.suggestion")
	if ok then
		sug.next()
	end
end, { silent = true, desc = "Copilot show" })

-- следующая (только если подсказка уже видна)
vim.keymap.set("i", "<M-n>", function()
	local ok, sug = pcall(require, "copilot.suggestion")
	if ok and sug.is_visible() then
		sug.next()
	end
end, { silent = true, desc = "Copilot next" })

-- предыдущая
vim.keymap.set("i", "<M-p>", function()
	local ok, sug = pcall(require, "copilot.suggestion")
	if ok and sug.is_visible() then
		sug.prev()
	end
end, { silent = true, desc = "Copilot prev" })

-- скрыть
vim.keymap.set("i", "<M-d>", function()
	local ok, sug = pcall(require, "copilot.suggestion")
	if ok and sug.is_visible() then
		sug.dismiss()
	end
end, { silent = true, desc = "Copilot dismiss" })

-- принять
vim.keymap.set("i", "<M-y>", function()
	local ok, sug = pcall(require, "copilot.suggestion")
	if ok and sug.is_visible() then
		sug.accept()
	end
end, { silent = true, desc = "Copilot accept" })
