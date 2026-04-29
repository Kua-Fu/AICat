class_name BottomTipBar
extends PanelContainer

const UiTheme := preload("res://scripts/ui/ui_theme_helper.gd")
const DrawIcons := preload("res://scripts/ui/draw_icons.gd")
const TIP_BAR_BG_PATH := "res://images/bottombar_tip_bar_bg.png"
const HOME_ICON_PATH := "res://images/bottombar_home_tip_badge.png"
const HEART_DECOR_PATH := "res://images/bottombar_heart_tip_group.png"

var bottom_tip_label: Label
var tip_bar_bg: Texture2D
var home_icon: Texture2D
var heart_decor: Texture2D


func _ready() -> void:
	if get_child_count() == 0:
		_build()


func set_tip(text: String) -> void:
	if bottom_tip_label == null:
		_build()
	bottom_tip_label.text = text


func _build() -> void:
	custom_minimum_size = Vector2(0, 84)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_load_textures()
	if tip_bar_bg == null:
		add_theme_stylebox_override("panel", UiTheme.make_panel_style(UiTheme.COLOR_PANEL, 24, UiTheme.COLOR_BORDER, 3, 4))
	else:
		add_theme_stylebox_override("panel", StyleBoxEmpty.new())

	var root := Control.new()
	root.name = "BottomTipContent"
	root.custom_minimum_size = Vector2(0, 84)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	if tip_bar_bg != null:
		var bg := _make_background()
		root.add_child(bg)

	var margin := MarginContainer.new()
	_fill_parent(margin)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 10)
	root.add_child(margin)

	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 16)
	margin.add_child(row)

	var left_wrap := CenterContainer.new()
	left_wrap.custom_minimum_size = Vector2(68, 0)
	left_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left_wrap.add_child(_make_icon(home_icon, Vector2(62, 58), "home"))
	row.add_child(left_wrap)

	bottom_tip_label = _label("", 22, Color("#7a5638"), HORIZONTAL_ALIGNMENT_LEFT)
	bottom_tip_label.name = "TipLabel"
	bottom_tip_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bottom_tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bottom_tip_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_tip_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_child(bottom_tip_label)

	var right_wrap := CenterContainer.new()
	right_wrap.custom_minimum_size = Vector2(76, 0)
	right_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_wrap.add_child(_make_icon(heart_decor, Vector2(68, 52), "heart"))
	row.add_child(right_wrap)


func _make_background() -> TextureRect:
	var bg := TextureRect.new()
	bg.name = "TipBarBackground"
	bg.texture = tip_bar_bg
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fill_parent(bg)
	return bg


func _make_icon(texture: Texture2D, icon_size: Vector2, fallback_kind: String) -> Control:
	if texture == null:
		var fallback: Control = DrawIcons.HomeIcon.new() if fallback_kind == "home" else DrawIcons.HeartIcon.new()
		fallback.custom_minimum_size = icon_size
		fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return fallback

	var icon := TextureRect.new()
	icon.texture = texture
	icon.custom_minimum_size = icon_size
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon


func _load_textures() -> void:
	if tip_bar_bg == null and ResourceLoader.exists(TIP_BAR_BG_PATH):
		tip_bar_bg = load(TIP_BAR_BG_PATH)
	if home_icon == null and ResourceLoader.exists(HOME_ICON_PATH):
		home_icon = load(HOME_ICON_PATH)
	if heart_decor == null and ResourceLoader.exists(HEART_DECOR_PATH):
		heart_decor = load(HEART_DECOR_PATH)


func _label(text: String, font_size: int, color: Color, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _fill_parent(node: Control) -> void:
	node.set_anchors_preset(Control.PRESET_FULL_RECT)
	node.offset_left = 0
	node.offset_top = 0
	node.offset_right = 0
	node.offset_bottom = 0
