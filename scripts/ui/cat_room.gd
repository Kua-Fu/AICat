class_name CatRoom
extends Control

const UiTheme := preload("res://scripts/ui/ui_theme_helper.gd")
const DrawIcons := preload("res://scripts/ui/draw_icons.gd")
const CatScene := preload("res://scenes/Cat.tscn")

const WALL_NIGHT := preload("res://assets/room/room_wall_night.png")
const WINDOW_NIGHT := preload("res://assets/room/window_night.png")
const CURTAIN := preload("res://assets/room/curtain.png")
const PLANT := preload("res://assets/room/plant.png")
const FLOOR := preload("res://assets/room/room_floor.png")
const RUG := preload("res://assets/room/rug_soft.png")
const CAT_BED := preload("res://assets/room/cat_bed_sleep.png")
const SCRATCHER := preload("res://assets/room/scratcher.png")
const FOOD_BOWL := preload("res://assets/room/food_bowl.png")
const YARN_BALL := preload("res://assets/room/yarn_ball.png")

var wall_layer: Control
var floor_layer: Control
var cat_layer: Node2D
var ui_layer: Control
var effect_layer: Control
var cat: Node2D
var room_title_label: Label
var speech_label: Label
var floating_text: Label
var night_amount := 0.0
var room_assets := []


func _ready() -> void:
	if get_child_count() == 0:
		_build()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_room_assets()
		_layout_cat()


func set_texts(title_text: String, speech_text: String) -> void:
	if room_title_label == null:
		_build()

	room_title_label.text = title_text
	speech_label.text = speech_text


func set_night_amount(value: float) -> void:
	night_amount = value
	if wall_layer != null:
		wall_layer.modulate = Color(1.07, 1.03, 0.94, 1.0).lerp(Color(0.83, 0.86, 1.0, 1.0), night_amount)


func get_cat() -> Node2D:
	if cat == null:
		_build()
	return cat


func _build() -> void:
	custom_minimum_size = Vector2(0, 570)
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS
	clip_contents = true

	_build_wall_layer()
	_build_floor_layer()
	_build_cat_layer()
	_build_ui_layer()
	_build_effect_layer()
	_layout_room_assets()
	_layout_cat()


func _build_wall_layer() -> void:
	wall_layer = Control.new()
	wall_layer.name = "WallLayer"
	wall_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	wall_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(wall_layer)

	var wall := _make_texture_rect("WallBackground", WALL_NIGHT, TextureRect.STRETCH_KEEP_ASPECT_COVERED)
	wall.set_anchors_preset(Control.PRESET_FULL_RECT)
	wall_layer.add_child(wall)

	_add_room_asset(wall_layer, "WindowNight", WINDOW_NIGHT, Vector2(0.20, 0.26), 0.32)
	_add_room_asset(wall_layer, "Curtain", CURTAIN, Vector2(0.20, 0.30), 0.30)

	var shelf := Control.new()
	shelf.name = "Shelf"
	shelf.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shelf.custom_minimum_size = Vector2(1, 1)
	wall_layer.add_child(shelf)

	_add_room_asset(wall_layer, "Plant", PLANT, Vector2(0.82, 0.40), 0.18)


func _build_floor_layer() -> void:
	floor_layer = Control.new()
	floor_layer.name = "FloorLayer"
	floor_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	floor_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(floor_layer)

	var floor := _make_texture_rect("Floor", FLOOR, TextureRect.STRETCH_SCALE)
	floor.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	floor.offset_top = -265
	floor.offset_bottom = 0
	floor_layer.add_child(floor)

	_add_room_asset(floor_layer, "Rug", RUG, Vector2(0.50, 0.70), 0.78)
	_add_room_asset(floor_layer, "CatBed", CAT_BED, Vector2(0.50, 0.60), 0.42)
	_add_room_asset(floor_layer, "Scratcher", SCRATCHER, Vector2(0.12, 0.54), 0.23)
	_add_room_asset(floor_layer, "FoodBowl", FOOD_BOWL, Vector2(0.84, 0.78), 0.18)
	_add_room_asset(floor_layer, "YarnBall", YARN_BALL, Vector2(0.16, 0.78), 0.14)


func _build_cat_layer() -> void:
	cat_layer = Node2D.new()
	cat_layer.name = "CatLayer"
	add_child(cat_layer)

	cat = CatScene.instantiate()
	cat.name = "CatSprite"
	cat_layer.add_child(cat)


func _build_ui_layer() -> void:
	ui_layer = Control.new()
	ui_layer.name = "UILayer"
	ui_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui_layer)

	room_title_label = Label.new()
	room_title_label.name = "RoomTitle"
	room_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	room_title_label.add_theme_font_size_override("font_size", 38)
	room_title_label.add_theme_color_override("font_color", Color("#5a3217"))
	room_title_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	room_title_label.offset_top = 50
	room_title_label.offset_bottom = 100
	ui_layer.add_child(room_title_label)

	var left_sparkle := DrawIcons.SparkleIcon.new()
	left_sparkle.tint = Color("#ffc04b")
	left_sparkle.set_anchors_preset(Control.PRESET_TOP_WIDE)
	left_sparkle.offset_left = 210
	left_sparkle.offset_right = -496
	left_sparkle.offset_top = 58
	left_sparkle.offset_bottom = 94
	ui_layer.add_child(left_sparkle)

	var right_sparkle := DrawIcons.SparkleIcon.new()
	right_sparkle.tint = Color("#ffc04b")
	right_sparkle.set_anchors_preset(Control.PRESET_TOP_WIDE)
	right_sparkle.offset_left = 500
	right_sparkle.offset_right = -206
	right_sparkle.offset_top = 58
	right_sparkle.offset_bottom = 94
	ui_layer.add_child(right_sparkle)

	var underline := DrawIcons.DoodleUnderline.new()
	underline.set_anchors_preset(Control.PRESET_TOP_WIDE)
	underline.offset_left = 206
	underline.offset_right = -206
	underline.offset_top = 104
	underline.offset_bottom = 132
	ui_layer.add_child(underline)

	var bubble := PanelContainer.new()
	bubble.name = "SpeechBubble"
	bubble.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	bubble.offset_left = -284
	bubble.offset_right = -22
	bubble.offset_top = 172
	bubble.offset_bottom = 264
	bubble.add_theme_stylebox_override("panel", UiTheme.make_panel_style(Color(1, 0.98, 0.92, 0.92), 34, Color("#dcb785"), 2, 3))
	ui_layer.add_child(bubble)

	speech_label = Label.new()
	speech_label.name = "SpeechLabel"
	speech_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	speech_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	speech_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	speech_label.add_theme_font_size_override("font_size", 22)
	speech_label.add_theme_color_override("font_color", Color("#4a2f1c"))
	bubble.add_child(speech_label)

	var bubble_tail := DrawIcons.BubbleTail.new()
	bubble_tail.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	bubble_tail.offset_left = -274
	bubble_tail.offset_right = -222
	bubble_tail.offset_top = 250
	bubble_tail.offset_bottom = 304
	ui_layer.add_child(bubble_tail)


func _build_effect_layer() -> void:
	effect_layer = Control.new()
	effect_layer.name = "EffectLayer"
	effect_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	effect_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(effect_layer)

	floating_text = Label.new()
	floating_text.name = "FloatingText"
	floating_text.visible = false
	floating_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	floating_text.add_theme_font_size_override("font_size", 24)
	floating_text.add_theme_color_override("font_color", Color("#7a5638"))
	floating_text.set_anchors_preset(Control.PRESET_CENTER)
	floating_text.offset_left = -120
	floating_text.offset_right = 120
	floating_text.offset_top = -180
	floating_text.offset_bottom = -130
	effect_layer.add_child(floating_text)


func _add_room_asset(parent: Control, node_name: String, texture: Texture2D, center_ratio: Vector2, width_ratio: float) -> TextureRect:
	var rect := _make_texture_rect(node_name, texture, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	parent.add_child(rect)
	room_assets.append({
		"node": rect,
		"center_ratio": center_ratio,
		"width_ratio": width_ratio
	})
	return rect


func _make_texture_rect(node_name: String, texture: Texture2D, stretch_mode: TextureRect.StretchMode) -> TextureRect:
	var rect := TextureRect.new()
	rect.name = node_name
	rect.texture = texture
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = stretch_mode
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect


func _layout_room_assets() -> void:
	for item in room_assets:
		var rect: TextureRect = item["node"]
		var center_ratio: Vector2 = item["center_ratio"]
		var width_ratio: float = item["width_ratio"]
		var texture_size := rect.texture.get_size()
		var draw_width := size.x * width_ratio
		var draw_size := Vector2(draw_width, draw_width * texture_size.y / texture_size.x)
		rect.position = size * center_ratio - draw_size * 0.5
		rect.size = draw_size


func _layout_cat() -> void:
	if cat == null:
		return

	var cat_scale := clampf(size.x / 520.0, 1.12, 1.48)
	cat.scale = Vector2.ONE * cat_scale
	cat.position = Vector2(size.x * 0.50, clampf(size.y * 0.72, 360.0, 430.0))
