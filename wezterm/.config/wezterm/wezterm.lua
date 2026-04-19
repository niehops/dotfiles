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

-- ====================================================================
-- SETTINGS
-- ====================================================================
-- appearance --
config.color_scheme = "Catppuccin Mocha" -- Example setting
config.font = wezterm.font("JetBrainsMono Nerd Font")
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
  config.window_background_opacity = 0.5
  config.macos_window_background_blur = 40
else
  config.window_background_opacity = 0.6
  config.macos_window_background_blur = 50
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
