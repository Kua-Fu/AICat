class_name ActionButton
extends Button

const UiTheme := preload("res://scripts/ui/ui_theme_helper.gd")
const DrawIcons := preload("res://scripts/ui/draw_icons.gd")

var sparkle_color := Color("#ffd35b")
var sparkle_texture: Texture2D


func setup(label: String, icon_texture: Texture2D, tooltip: String, bg: Color, border: Color, bg_texture: Texture2D = null, sparkle: Texture2D = null) -> void:
	sparkle_color = border.lightened(0.25)
	sparkle_texture = sparkle
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
	add_theme_constant_override("icon_max_width", 68)
	add_theme_constant_override("h_separation", 8)
	add_theme_stylebox_override("normal", UiTheme.make_texture_panel_style(bg_texture, bg, 22, border, 3, 4, Vector2(12, 12)))
	add_theme_stylebox_override("hover", UiTheme.make_texture_panel_style(bg_texture, bg.lightened(0.18), 22, border, 3, 4, Vector2(12, 12), Color(1.08, 1.08, 1.08, 1.0)))
	add_theme_stylebox_override("pressed", UiTheme.make_texture_panel_style(bg_texture, bg.darkened(0.05), 22, border.darkened(0.08), 3, 2, Vector2(12, 14), Color(0.96, 0.96, 0.96, 1.0)))


func _draw() -> void:
	_draw_sparkle(Vector2(size.x - 22, 18), 10.0)
	if text == "叫醒":
		_draw_sparkle(Vector2(22, 32), 8.0)


func _draw_sparkle(center: Vector2, radius: float) -> void:
	if sparkle_texture != null:
		draw_texture_rect(sparkle_texture, Rect2(center - Vector2(radius, radius) * 1.35, Vector2(radius, radius) * 2.7), false)
		return

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
