extends RefCounted
class_name UiTheme

static func create_app_theme():
	var theme = Theme.new()
	theme.set_default_font(UiStyle.ui_font(false))
	theme.set_default_font_size(15)

	theme.set_font("font", "Label", UiStyle.ui_font(false))
	theme.set_font_size("font_size", "Label", 15)
	theme.set_color("font_color", "Label", UiStyle.INK)

	theme.set_font("font", "Button", UiStyle.DISPLAY_FONT)
	theme.set_font_size("font_size", "Button", 17)
	theme.set_color("font_color", "Button", UiStyle.INK)
	theme.set_color("font_hover_color", "Button", UiStyle.INK)
	theme.set_color("font_pressed_color", "Button", UiStyle.INK)
	theme.set_color("font_disabled_color", "Button", UiStyle.MUTED)
	theme.set_constant("outline_size", "Button", 0)
	theme.set_stylebox("normal", "Button", UiStyle.panel_style(UiStyle.YELLOW, UiStyle.INK, 3, 18, 8))
	theme.set_stylebox("hover", "Button", UiStyle.panel_style(UiStyle.YELLOW.lightened(0.05), UiStyle.INK, 3, 18, 8))
	theme.set_stylebox("pressed", "Button", UiStyle.panel_style(UiStyle.ORANGE, UiStyle.INK, 3, 18, 8))
	theme.set_stylebox("disabled", "Button", UiStyle.panel_style(Color(0.82, 0.87, 0.93), UiStyle.INK, 2, 18, 8))

	theme.set_stylebox("panel", "PanelContainer", UiStyle.panel_style())
	theme.set_stylebox("background", "ProgressBar", UiStyle.panel_style(Color(0.86, 0.91, 0.96), Color(1, 1, 1, 0), 0, 6, 0, false))
	theme.set_stylebox("fill", "ProgressBar", UiStyle.panel_style(UiStyle.WATER, Color(1, 1, 1, 0), 0, 6, 0, false))
	return theme
