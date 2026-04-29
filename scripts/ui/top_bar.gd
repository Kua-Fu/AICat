class_name TopBar
extends PanelContainer

const UiTheme := preload("res://scripts/ui/ui_theme_helper.gd")

const HOME_ICON := preload("res://assets/icons/topbar/home_topbar.png")
const SUN_ICON := preload("res://assets/icons/topbar/sun_small.png")
const MOON_ICON := preload("res://assets/icons/topbar/moon_small.png")
const COIN_ICON := preload("res://assets/icons/topbar/coin_small.png")
const LEVEL_PILL_BG := preload("res://assets/ui/topbar/level_pill_bg.png")
const COIN_PILL_BG := preload("res://assets/ui/topbar/coin_pill_bg.png")

var cat_name_label: Label
var top_time_label: Label
var day_night_icon: TextureRect
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
	day_night_icon.texture = MOON_ICON if night_amount > 0.65 else SUN_ICON


func _build() -> void:
	custom_minimum_size = Vector2(0, 98)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_stylebox_override("panel", UiTheme.make_panel_style(Color("#fff6e5"), 28, Color("#e3bf78"), 3, 6))

	var root_margin := MarginContainer.new()
	root_margin.add_theme_constant_override("margin_left", 18)
	root_margin.add_theme_constant_override("margin_right", 18)
	root_margin.add_theme_constant_override("margin_top", 10)
	root_margin.add_theme_constant_override("margin_bottom", 10)
	add_child(root_margin)

	var header := HBoxContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.size_flags_vertical = Control.SIZE_EXPAND_FILL
	header.add_theme_constant_override("separation", 14)
	root_margin.add_child(header)

	var left_group := HBoxContainer.new()
	left_group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_group.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_group.add_theme_constant_override("separation", 12)
	header.add_child(left_group)

	var home_icon := _make_icon(HOME_ICON, Vector2(48, 48))
	left_group.add_child(home_icon)

	cat_name_label = Label.new()
	cat_name_label.name = "CatNameLabel"
	cat_name_label.clip_text = true
	cat_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cat_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cat_name_label.add_theme_font_size_override("font_size", 30)
	cat_name_label.add_theme_color_override("font_color", UiTheme.COLOR_TEXT)
	left_group.add_child(cat_name_label)

	var center_group := HBoxContainer.new()
	center_group.custom_minimum_size = Vector2(168, 0)
	center_group.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_group.add_theme_constant_override("separation", 8)
	header.add_child(center_group)

	top_time_label = Label.new()
	top_time_label.name = "TopTimeLabel"
	top_time_label.custom_minimum_size = Vector2(118, 0)
	top_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top_time_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_time_label.add_theme_font_size_override("font_size", 20)
	top_time_label.add_theme_color_override("font_color", Color("#6a4a31"))
	center_group.add_child(top_time_label)

	day_night_icon = _make_icon(SUN_ICON, Vector2(34, 34))
	center_group.add_child(day_night_icon)

	var right_group := HBoxContainer.new()
	right_group.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_group.add_theme_constant_override("separation", 10)
	header.add_child(right_group)

	var level_pill := _make_texture_pill(LEVEL_PILL_BG, Vector2(96, 48))
	level_label = _label("", 20, UiTheme.COLOR_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	level_pill.add_child(_centered(level_label))
	right_group.add_child(level_pill)

	var coin_pill := _make_texture_pill(COIN_PILL_BG, Vector2(128, 48))
	var coin_margin := MarginContainer.new()
	_fill_parent(coin_margin)
	coin_margin.add_theme_constant_override("margin_left", 14)
	coin_margin.add_theme_constant_override("margin_right", 14)
	coin_margin.add_theme_constant_override("margin_top", 6)
	coin_margin.add_theme_constant_override("margin_bottom", 6)
	coin_pill.add_child(coin_margin)

	var coin_box := HBoxContainer.new()
	coin_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	coin_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	coin_box.add_theme_constant_override("separation", 8)
	coin_margin.add_child(coin_box)

	var coin_icon := _make_icon(COIN_ICON, Vector2(28, 28))
	coin_box.add_child(coin_icon)

	coin_label = _label("", 20, UiTheme.COLOR_TEXT, HORIZONTAL_ALIGNMENT_LEFT)
	coin_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	coin_box.add_child(coin_label)
	right_group.add_child(coin_pill)


func _make_icon(texture: Texture2D, icon_size: Vector2) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = texture
	icon.custom_minimum_size = icon_size
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon


func _make_texture_pill(texture: Texture2D, pill_size: Vector2) -> Control:
	var root := Control.new()
	root.custom_minimum_size = pill_size
	root.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var bg := TextureRect.new()
	bg.texture = texture
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fill_parent(bg)
	root.add_child(bg)
	return root


func _label(text: String, font_size: int, color: Color, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _centered(node: Control) -> CenterContainer:
	var center := CenterContainer.new()
	_fill_parent(center)
	center.add_child(node)
	return center


func _fill_parent(node: Control) -> void:
	node.set_anchors_preset(Control.PRESET_FULL_RECT)
	node.offset_left = 0
	node.offset_top = 0
	node.offset_right = 0
	node.offset_bottom = 0
