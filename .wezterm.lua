local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = "kanagawabones"
config.font_size = 13

config.font = wezterm.font("JetBrainsMono Nerd Font Mono", { weight = 500 })
config.font_rules = {

	-- Bold
	{
		intensity = "Bold",
		italic = false,
		font = wezterm.font({
			family = "JetBrainsMono Nerd Font Mono",
			weight = 700,
			italic = false,
		}),
	},

	-- Bold-and-italic
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font({
			family = "JetBrainsMono Nerd Font Mono",
			weight = 700,
			italic = true,
		}),
	},

	-- normal-intensity-and-italic
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font({
			family = "JetBrainsMono Nerd Font Mono",
			weight = 500,
			italic = true,
		}),
	},

	-- half-intensity-and-italic (half-bright or dim); use a lighter weight font
	{
		intensity = "Half",
		italic = true,
		font = wezterm.font({
			family = "JetBrainsMono Nerd Font Mono",
			weight = 300,
			italic = true,
		}),
	},

	-- half-intensity-and-not-italic
	{
		intensity = "Half",
		italic = false,
		font = wezterm.font({
			family = "JetBrainsMono Nerd Font Mono",
			weight = 300
		}),
	},
}

config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

config.default_prog = { "powershell", "-NoLogo" }

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	local gui_window = window:gui_window()
	gui_window:maximize()
end)

return config
