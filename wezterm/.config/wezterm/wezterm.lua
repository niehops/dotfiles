-- ====================================================================
-- WEZTERM API
-- ====================================================================
local wezterm = require("wezterm")

local config = {}

-- ====================================================================
-- CONFIG BUILDER
-- ====================================================================

if wezterm.config_builder then
	config = wezterm.config_builder()
end
-- config.default_prog = { "/opt/homebrew/bin/tmux", "new-session", "-A", "-s", "main" }

-- ====================================================================
-- SETTINGS
-- ====================================================================
-- appearance --
config.color_scheme = "Catppuccin Mocha" -- Example setting
--config.font = wezterm.font("JetBrainsMono Nerd Font")
--config.font = wezterm.font("Noto Sans Myanmar")
config.cell_width = 1.0
config.font_shaper = "Harfbuzz"
config.front_end = "Software"
config.font = wezterm.font_with_fallback({
	"JetBrainsMono Nerd Font",
	"Noto Sans Myanmar",
})
-- config.font = wezterm.font_with_fallback({
-- 	"JetBrains Mono",
-- 	{ family = "Padauk", weight = "Regular" },
-- 	{ family = "Noto Sans Myanmar", weight = "Regular" },
-- })

--config.harfbuzz_features = { "calt=1", "clig=1", "liga=1", "dlig=1" }

-- Non-monospace glyph များကို auto-scale လုပ်ပြီး grid မပျက်စေရန်
--config.allow_square_glyphs_to_overflow_width = "Always"

--config.unicode_version = 14
config.font_size = 19
config.window_decorations = "RESIZE"
config.enable_tab_bar = false

-- background blur --
local function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

local is_dark = get_appearance():find("Dark")

if is_dark then
	config.window_background_opacity = 0.7
	config.macos_window_background_blur = 70
else
	config.window_background_opacity = 0.7
	config.macos_window_background_blur = 70
end

-- ====================================================================
-- KEYMAPS
-- ====================================================================
config.keys = {
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
}

-- return --
return config
