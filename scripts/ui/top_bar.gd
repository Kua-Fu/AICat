class_name TopBar
extends PanelContainer

const UiTheme := preload("res://scripts/ui/ui_theme_helper.gd")

const HOME_ICON := preload("res://assets/icons/topbar/home_topbar.png")
const SUN_ICON := preload("res://assets/icons/topbar/sun_small.png")
const MOON_ICON := preload("res://assets/icons/topbar/moon_small.png")
const COIN_ICON := preload("res://assets/icons/topbar/coin_small.png")
const LEVEL_PILL_BG := preload("res://assets/ui/topbar/level_pill_bg.png")
const COIN_PILL_BG := preload("res://assets/ui/topbar/coin_pill_bg.png")

const BAR_HEIGHT := 100.0
const BAR_RADIUS := 28
const BAR_BORDER_WIDTH := 3
const BAR_SHADOW_SIZE := 6

const INNER_MARGIN_X := 18
const INNER_MARGIN_Y := 8
const HEADER_GAP := 14
const LEFT_GAP := 12
const CENTER_GAP := 8
const RIGHT_GAP := 10

const HOME_ICON_SIZE := Vector2(46, 46)
const DAY_NIGHT_ICON_SIZE := Vector2(32, 32)
const LEVEL_PILL_SIZE := Vector2(92, 46)
const COIN_PILL_SIZE := Vector2(124, 46)
const COIN_ICON_SIZE := Vector2(28, 28)

const CAT_NAME_FONT_SIZE := 29
const META_FONT_SIZE := 20
const TIME_MIN_WIDTH := 112.0
const CENTER_MIN_WIDTH := 154.0

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
	custom_minimum_size = Vector2(0, BAR_HEIGHT)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_stylebox_override("panel", UiTheme.make_panel_style(Color("#fff6e5"), BAR_RADIUS, Color("#e3bf78"), BAR_BORDER_WIDTH, BAR_SHADOW_SIZE))

	var root_margin := MarginContainer.new()
	root_margin.add_theme_constant_override("margin_left", INNER_MARGIN_X)
	root_margin.add_theme_constant_override("margin_right", INNER_MARGIN_X)
	root_margin.add_theme_constant_override("margin_top", INNER_MARGIN_Y)
	root_margin.add_theme_constant_override("margin_bottom", INNER_MARGIN_Y)
	add_child(root_margin)

	var header := HBoxContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.size_flags_vertical = Control.SIZE_EXPAND_FILL
	header.add_theme_constant_override("separation", HEADER_GAP)
	root_margin.add_child(header)

	var left_group := HBoxContainer.new()
	left_group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_group.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_group.add_theme_constant_override("separation", LEFT_GAP)
	header.add_child(left_group)

	var home_icon := _make_icon(HOME_ICON, HOME_ICON_SIZE)
	left_group.add_child(home_icon)

	cat_name_label = Label.new()
	cat_name_label.name = "CatNameLabel"
	cat_name_label.clip_text = true
	cat_name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	cat_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cat_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cat_name_label.add_theme_font_size_override("font_size", CAT_NAME_FONT_SIZE)
	cat_name_label.add_theme_color_override("font_color", UiTheme.COLOR_TEXT)
	left_group.add_child(cat_name_label)

	var center_group := HBoxContainer.new()
	center_group.custom_minimum_size = Vector2(CENTER_MIN_WIDTH, 0)
	center_group.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	center_group.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_group.add_theme_constant_override("separation", CENTER_GAP)
	header.add_child(center_group)

	top_time_label = Label.new()
	top_time_label.name = "TopTimeLabel"
	top_time_label.custom_minimum_size = Vector2(TIME_MIN_WIDTH, 0)
	top_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top_time_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_time_label.add_theme_font_size_override("font_size", META_FONT_SIZE)
	top_time_label.add_theme_color_override("font_color", Color("#6a4a31"))
	center_group.add_child(top_time_label)

	day_night_icon = _make_icon(SUN_ICON, DAY_NIGHT_ICON_SIZE)
	center_group.add_child(day_night_icon)

	var right_group := HBoxContainer.new()
	right_group.size_flags_horizontal = Control.SIZE_SHRINK_END
	right_group.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_group.add_theme_constant_override("separation", RIGHT_GAP)
	header.add_child(right_group)

	var level_pill := _make_texture_pill(LEVEL_PILL_BG, LEVEL_PILL_SIZE)
	level_label = _label("", META_FONT_SIZE, UiTheme.COLOR_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	level_pill.add_child(_centered(level_label))
	right_group.add_child(level_pill)

	var coin_pill := _make_texture_pill(COIN_PILL_BG, COIN_PILL_SIZE)
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

	var coin_icon := _make_icon(COIN_ICON, COIN_ICON_SIZE)
	coin_box.add_child(coin_icon)

	coin_label = _label("", META_FONT_SIZE, UiTheme.COLOR_TEXT, HORIZONTAL_ALIGNMENT_LEFT)
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
