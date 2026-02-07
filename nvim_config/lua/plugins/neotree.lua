return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	lazy = false,
	{
		"nvim-neo-tree/neo-tree.nvim",
		opts = {
			filesystem = {
				filtered_items = {
					visible = true, -- Сделать скрытые файлы видимыми по умолчанию
					hide_dotfiles = false,
					hide_gitignored = false, -- Если хотите видеть и файлы из .gitignore
				},
			},
		},
	},
}
