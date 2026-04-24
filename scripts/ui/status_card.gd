class_name StatusCard
extends PanelContainer

const UiTheme := preload("res://scripts/ui/ui_theme_helper.gd")
const DrawIcons := preload("res://scripts/ui/draw_icons.gd")

var accent := Color("#f47c62")
var base_color := Color("#f47c62")
var value_label: Label
var bar: ProgressBar
var card_style: StyleBoxFlat


func setup(title: String, icon_kind: String, color: Color, bg: Color) -> void:
	base_color = color
	accent = color
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	card_style = UiTheme.make_panel_style(bg, 18, color.lightened(0.25), 2, 1)
	add_theme_stylebox_override("panel", card_style)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	add_child(row)

	var icon := DrawIcons.StatusIcon.new()
	icon.kind = icon_kind
	icon.tint = color
	icon.custom_minimum_size = Vector2(78, 78)
	row.add_child(icon)

	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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

	card_style.border_color = color.lightened(0.25)
	card_style.shadow_color = Color(0.56, 0.24, 0.12, 0.16 if value < 40.0 else 0.06)
	card_style.shadow_size = 4 if value < 40.0 else 1


func _draw() -> void:
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
