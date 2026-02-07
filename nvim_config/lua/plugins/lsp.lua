return {
	{
		"mason-org/mason.nvim",
	},
	{
		"folke/lazydev.nvim",
		ft = "lua", -- загружать только для lua файлов
		opts = {
			library = {
				-- Путь к плагинам, чтобы работало автодополнение
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"rust-analyzer",
					"rustfmt",
					"basedpyright",
					"ruff",
					"emmet-language-server",
					"html-lsp",
					"htmlhint",
					"css-lsp",
					"stylelint",
					"vtsls",
					"eslint_d",
					"prettierd",
					"lua-language-server",
					"stylua",
					"vim-language-server",
				},
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			require("mason").setup()
			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						require("lspconfig")[server_name].setup({
							capabilities = capabilities,
							filetypes = {
								"html",
								"css",
								"javascript",
								"javascriptreact",
								"scss",
								"typescriptreact",
							},
							init_options = {
								showAbbreviationSuggestions = true,
								showExpandedAbbreviation = "always",
								showSuggestionsAsSnippets = false,
								syntaxProfiles = {},
								variables = {},
							},
						})
					end,
				},
			})
			vim.lsp.config('basedpyright', {
				settings = {
					basedpyright = {
						analysis = {
							-- Отключает диагностику (подчеркивания) определенных правил
							typeCheckingMode = "off",
						},
					},
					python = {
						analysis = {
							-- Отключение конкретно виртуальных подсказок типов
							inlayHints = {
								variableTypes = false,
								functionReturnTypes = false,
								callArgumentNames = false,
								taggedTupleElements = false,
							},
						},
					},
				},
			})
		end,
	},
}
