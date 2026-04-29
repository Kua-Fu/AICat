class_name ActionButton
extends Button

const UiTheme := preload("res://scripts/ui/ui_theme_helper.gd")
const DrawIcons := preload("res://scripts/ui/draw_icons.gd")

var sparkle_color := Color("#ffd35b")
var sparkle_texture: Texture2D
var icon_rect: TextureRect
var title_label: Label


func setup(label: String, icon_texture: Texture2D, tooltip: String, bg: Color, border: Color, bg_texture: Texture2D = null, sparkle: Texture2D = null) -> void:
	sparkle_color = border.lightened(0.25)
	sparkle_texture = sparkle
	text = ""
	icon = null
	tooltip_text = tooltip
	clip_contents = true
	custom_minimum_size = Vector2(130, 156)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	focus_mode = Control.FOCUS_NONE

	add_theme_stylebox_override("normal", UiTheme.make_panel_style(bg, 22, border, 3, 4))
	add_theme_stylebox_override("hover", UiTheme.make_panel_style(bg.lightened(0.12), 22, border, 3, 4))
	add_theme_stylebox_override("pressed", UiTheme.make_panel_style(bg.darkened(0.04), 22, border.darkened(0.08), 3, 2))
	add_theme_stylebox_override("disabled", UiTheme.make_panel_style(bg.darkened(0.05), 22, border.lightened(0.3), 3, 0))

	for child in get_children():
		child.queue_free()

	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 10
	box.offset_right = -10
	box.offset_top = 10
	box.offset_bottom = -8
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 8)
	add_child(box)

	icon_rect = TextureRect.new()
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_rect.texture = icon_texture
	icon_rect.custom_minimum_size = Vector2(78, 78)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_child(icon_rect)

	title_label = Label.new()
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.text = label
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color("#4a2f1c"))
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(title_label)

	queue_redraw()


func set_title(label: String) -> void:
	if title_label != null:
		title_label.text = label
	queue_redraw()


func _draw() -> void:
	_draw_sparkle(Vector2(size.x - 22, 18), 10.0)
	if title_label != null and title_label.text == "叫醒":
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
