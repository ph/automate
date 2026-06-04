local wezterm = require "wezterm"

function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return 'Dark'
end

function scheme_for_appearance(appearance)
  -- if appearance:find("Dark") then
    return "Catppuccin Mocha"
  -- else
    -- return "Catppuccin Latte"
  -- end
end

return {
  color_scheme = scheme_for_appearance(get_appearance()),
  font = wezterm.font('JetBrainsMono Nerd Font'),
  font_size = 9,
  enable_tab_bar = false,
  window_background_opacity = 0.9,  -- 0.0 transparent, 1.0 opaque
  text_background_opacity = 1.0,
}
