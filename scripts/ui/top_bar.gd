class_name TopBar
extends PanelContainer

const UiTheme := preload("res://scripts/ui/ui_theme_helper.gd")
const DrawIcons := preload("res://scripts/ui/draw_icons.gd")

var cat_name_label: Label
var top_time_label: Label
var day_night_icon: Control
var level_label: Label
var coin_label: Label


func _ready() -> void:
	if get_child_count() == 0:
		_build()


func set_data(cat_name: String, time_text: String, night_amount: float, level: int, coin: int) -> void:
	if cat_name_label == null:
		_build()

	cat_name_label.text = "%s的小屋" % cat_name
	top_time_label.text = time_text
	level_label.text = "Lv.%d" % level
	coin_label.text = "%d" % coin
	day_night_icon.night_amount = night_amount
	day_night_icon.queue_redraw()


func _build() -> void:
	custom_minimum_size = Vector2(0, 112)
	add_theme_stylebox_override("panel", UiTheme.make_panel_style(UiTheme.COLOR_PANEL, 30, UiTheme.COLOR_BORDER, 3, 8))

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	add_child(header)

	var title_box := HBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", 12)
	header.add_child(title_box)

	var home_icon := DrawIcons.HomeIcon.new()
	home_icon.custom_minimum_size = Vector2(56, 56)
	title_box.add_child(home_icon)

	cat_name_label = Label.new()
	cat_name_label.name = "CatNameLabel"
	cat_name_label.clip_text = true
	cat_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cat_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cat_name_label.add_theme_font_size_override("font_size", 34)
	cat_name_label.add_theme_color_override("font_color", UiTheme.COLOR_TEXT)
	title_box.add_child(cat_name_label)

	top_time_label = Label.new()
	top_time_label.name = "TopTimeLabel"
	top_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top_time_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_time_label.custom_minimum_size = Vector2(124, 0)
	top_time_label.add_theme_font_size_override("font_size", 22)
	top_time_label.add_theme_color_override("font_color", Color("#5f3d24"))
	header.add_child(top_time_label)

	day_night_icon = DrawIcons.DayNightIcon.new()
	day_night_icon.custom_minimum_size = Vector2(42, 42)
	header.add_child(day_night_icon)

	var level_pill := _make_pill(Color("#fff8ea"), Color("#eabf79"), 84, 52)
	level_label = _label("", 22, UiTheme.COLOR_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	level_pill.add_child(level_label)
	header.add_child(level_pill)

	var coin_pill := _make_pill(Color("#fff0c2"), Color("#eabf79"), 126, 52)
	var coin_box := HBoxContainer.new()
	coin_box.add_theme_constant_override("separation", 8)
	coin_pill.add_child(coin_box)

	var coin_icon := DrawIcons.CoinIcon.new()
	coin_icon.custom_minimum_size = Vector2(36, 36)
	coin_box.add_child(coin_icon)

	coin_label = _label("", 22, UiTheme.COLOR_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	coin_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	coin_box.add_child(coin_label)
	header.add_child(coin_pill)


func _make_pill(bg: Color, border: Color, width: float, height: float) -> PanelContainer:
	var pill := PanelContainer.new()
	pill.custom_minimum_size = Vector2(width, height)
	pill.add_theme_stylebox_override("panel", UiTheme.make_panel_style(bg, int(height * 0.5), border, 2, 1))
	return pill


func _label(text: String, font_size: int, color: Color, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
