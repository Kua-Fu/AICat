class_name UIThemeHelper
extends Node

const COLOR_BG := Color("#fff7ea")
const COLOR_PANEL := Color("#fff3d8")
const COLOR_PANEL_LIGHT := Color("#fff9ec")
const COLOR_TEXT := Color("#4b2f1f")
const COLOR_TEXT_WEAK := Color("#7e6754")
const COLOR_BORDER := Color("#e8c07a")
const COLOR_SHADOW := Color(0.84, 0.62, 0.30, 0.18)

const COLOR_HUNGER := Color("#f47c62")
const COLOR_HAPPY := Color("#ef8fb3")
const COLOR_ENERGY := Color("#6e6dda")
const COLOR_CLEAN := Color("#58b7c8")

const COLOR_BTN_FEED := Color("#ffe5b8")
const COLOR_BTN_PLAY := Color("#dff1ff")
const COLOR_BTN_PET := Color("#ffe4e6")
const COLOR_BTN_BATH := Color("#ddf7eb")
const COLOR_BTN_SLEEP := Color("#e9ddff")


static func make_panel_style(
		bg: Color,
		radius: int = 24,
		border_color: Color = COLOR_BORDER,
		border_width: int = 2,
		shadow_size: int = 0
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	if shadow_size > 0:
		style.shadow_color = COLOR_SHADOW
		style.shadow_size = shadow_size
		style.shadow_offset = Vector2(0, 3)
	return style
