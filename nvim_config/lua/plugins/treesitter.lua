return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	init = function()
		-- Оставляем только самое важное для Windows
		local install = require("nvim-treesitter.install")
		install.compilers = { "cl", "gcc" } -- Чтобы он сразу шел к нашим shim-файлам
		install.prefer_git = false -- Чтобы не мучиться с git-блоками на Windows
	end,
	config = function()
		require("nvim-treesitter").setup({
			highlight = { enable = true },
		})
		require("nvim-treesitter.config").setup({
			indent = {
				enable = true,
			},
		})
	end,
}
