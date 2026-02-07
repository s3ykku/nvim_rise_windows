vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = false

vim.opt.clipboard = "unnamedplus"

vim.g.clipboard = {
	name = "win32yank-wsl",
	copy = {
		["+"] = "win32yank.exe -i --crlf",
		["*"] = "win32yank.exe -i --crlf",
	},
	paste = {
		["+"] = "win32yank.exe -o --lf",
		["*"] = "win32yank.exe -o --lf",
	},
	cache_enabled = true,
}

require("../config.lazy")
require("../keymap")

vim.cmd("colorscheme kanagawa-wave")

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python", "rust", "html", "css", "javascript", "vim", "lua" },
	callback = function()
		vim.treesitter.start()
	end,
})

vim.diagnostic.config({
	-- 1. Настройка иконок (Новый метод)
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = "󰠠 ",
			[vim.diagnostic.severity.INFO] = " ",
		},
	},

	-- 2. Настройка текста ошибки в строке кода
	virtual_text = {
		source = "if_many", -- Показывать источник (например, "Pyright"), если их несколько
		prefix = "●", -- Кружочек вместо квадрата
		-- Или можно использовать иконку: prefix = "icons",
	},

	-- 3. Общие настройки
	update_in_insert = false, -- Не обновлять ошибки, пока ты печатаешь (чтобы не мелькало)
	underline = true, -- Подчеркивать проблемное место
	severity_sort = true, -- Сначала показывать ошибки, потом предупреждения

	-- 4. Всплывающее окно (когда наводишь курсор и жмешь d)
	float = {
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})
