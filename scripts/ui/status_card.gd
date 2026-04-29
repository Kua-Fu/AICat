class_name StatusCard
extends PanelContainer

const UiTheme := preload("res://scripts/ui/ui_theme_helper.gd")
const DrawIcons := preload("res://scripts/ui/draw_icons.gd")

var accent := Color("#f47c62")
var base_color := Color("#f47c62")
var value_label: Label
var bar: ProgressBar
var card_style: StyleBox
var sparkle_texture: Texture2D


func setup(title: String, icon_texture: Texture2D, color: Color, bg: Color, bg_texture: Texture2D = null, sparkle: Texture2D = null) -> void:
	base_color = color
	accent = color
	sparkle_texture = sparkle
	custom_minimum_size = Vector2(0, 112)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	card_style = UiTheme.make_panel_style(bg, 18, color.lightened(0.25), 2, 1)
	add_theme_stylebox_override("panel", card_style)

	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	add_child(row)

	var icon := TextureRect.new()
	icon.texture = icon_texture
	icon.custom_minimum_size = Vector2(76, 76)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(icon)

	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	details.add_theme_constant_override("separation", 10)
	row.add_child(details)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	details.add_child(top)

	var name_label := _label(title, 25, Color("#4a2f1c"), HORIZONTAL_ALIGNMENT_LEFT)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(name_label)

	value_label = _label("", 20, color, HORIZONTAL_ALIGNMENT_RIGHT)
	value_label.custom_minimum_size = Vector2(70, 0)
	top.add_child(value_label)

	bar = ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 100
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 28)
	bar.add_theme_stylebox_override("background", UiTheme.make_panel_style(Color(1, 1, 1, 0.72), 12, Color(0, 0, 0, 0), 0))
	details.add_child(bar)


func update_value(value: float) -> void:
	var rounded := int(value)
	var color := _status_color(value)
	bar.value = rounded
	value_label.text = "%d%%" % rounded
	value_label.add_theme_color_override("font_color", color)

	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(12)
	bar.add_theme_stylebox_override("fill", fill)

	if card_style is StyleBoxFlat:
		card_style.border_color = color.lightened(0.25)
		card_style.shadow_color = Color(0.56, 0.24, 0.12, 0.16 if value < 40.0 else 0.06)
		card_style.shadow_size = 4 if value < 40.0 else 1


func _draw() -> void:
	if sparkle_texture != null:
		draw_texture_rect(sparkle_texture, Rect2(size.x - 44, 8, 34, 34), false)
	else:
		var c := Vector2(size.x - 22, 22)
		var color := accent.lightened(0.35)
		draw_polygon(DrawIcons.sparkle_points(c, 9.0, 0.26), PackedColorArray([color, color, color, color, color, color, color, color]))


func _status_color(value: float) -> Color:
	if value < 40.0:
		return Color("#e85d5d")
	if value < 70.0:
		return Color("#f0a84f")
	return base_color


func _label(text: String, font_size: int, color: Color, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
