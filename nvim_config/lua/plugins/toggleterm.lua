return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		require("toggleterm").setup({
			size = 20,
			direction = "float",
			float_opts = {
				border = "single",
			},
			start_in_insert = true,
		})
		function _G.set_terminal_keymaps()
			local opts = { buffer = 0 }

			vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)

			vim.keymap.set("n", "q", "<cmd>close<CR>", opts)
		end

		vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
	end,
}
