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
			indent = { enable = true },
		})

		vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
			pattern = "*",
			callback = function()
				vim.schedule(function()
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					vim.opt_local.smartindent = false
				end)
			end,
		})
	end,
}
