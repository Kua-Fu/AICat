class_name ActionButton
extends Button

const UiTheme := preload("res://scripts/ui/ui_theme_helper.gd")
const DrawIcons := preload("res://scripts/ui/draw_icons.gd")

var sparkle_color := Color("#ffd35b")


func setup(label: String, icon_texture: Texture2D, tooltip: String, bg: Color, border: Color) -> void:
	sparkle_color = border.lightened(0.25)
	text = label
	icon = icon_texture
	expand_icon = true
	vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	alignment = HORIZONTAL_ALIGNMENT_CENTER
	tooltip_text = tooltip
	custom_minimum_size = Vector2(126, 148)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_font_size_override("font_size", 24)
	add_theme_color_override("font_color", Color("#4a2f1c"))
	add_theme_stylebox_override("normal", UiTheme.make_panel_style(bg, 22, border, 3, 4))
	add_theme_stylebox_override("hover", UiTheme.make_panel_style(bg.lightened(0.18), 22, border, 3, 4))
	add_theme_stylebox_override("pressed", UiTheme.make_panel_style(bg.darkened(0.05), 22, border.darkened(0.08), 3, 2))


func _draw() -> void:
	_draw_sparkle(Vector2(size.x - 22, 18), 10.0)
	if text == "叫醒":
		_draw_sparkle(Vector2(22, 32), 8.0)


func _draw_sparkle(center: Vector2, radius: float) -> void:
	draw_polygon(DrawIcons.sparkle_points(center, radius), PackedColorArray([
		sparkle_color,
		sparkle_color,
		sparkle_color,
		sparkle_color,
		sparkle_color,
		sparkle_color,
		sparkle_color,
		sparkle_color
	]))
