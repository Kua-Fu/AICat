class_name BottomTipBar
extends PanelContainer

const UiTheme := preload("res://scripts/ui/ui_theme_helper.gd")
const DrawIcons := preload("res://scripts/ui/draw_icons.gd")

var bottom_tip_label: Label


func _ready() -> void:
	if get_child_count() == 0:
		_build()


func set_tip(text: String) -> void:
	if bottom_tip_label == null:
		_build()
	bottom_tip_label.text = text


func _build() -> void:
	custom_minimum_size = Vector2(0, 78)
	add_theme_stylebox_override("panel", UiTheme.make_panel_style(UiTheme.COLOR_PANEL, 24, UiTheme.COLOR_BORDER, 3, 4))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	add_child(row)

	var icon := DrawIcons.HomeIcon.new()
	icon.custom_minimum_size = Vector2(54, 54)
	row.add_child(icon)

	bottom_tip_label = _label("", 22, Color("#7a5638"), HORIZONTAL_ALIGNMENT_LEFT)
	bottom_tip_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bottom_tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bottom_tip_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(bottom_tip_label)

	var heart := DrawIcons.HeartIcon.new()
	heart.custom_minimum_size = Vector2(48, 48)
	row.add_child(heart)


func _label(text: String, font_size: int, color: Color, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
