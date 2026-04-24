extends Control

var title_label: Label
var place_label: Label
var event_label: Label
var diary_label: Label
var reward_label: Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_show_result()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#edf2f6")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -360
	panel.offset_right = 360
	panel.offset_top = -240
	panel.offset_bottom = 240
	panel.add_theme_stylebox_override("panel", _style(Color("#fffdf7"), Color("#c6a46c")))
	add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)

	title_label = _make_label(34, Color("#302720"), HORIZONTAL_ALIGNMENT_CENTER)
	title_label.name = "TitleLabel"
	box.add_child(title_label)

	place_label = _make_label(22, Color("#5b493d"), HORIZONTAL_ALIGNMENT_CENTER)
	place_label.name = "PlaceLabel"
	box.add_child(place_label)

	event_label = _make_label(22, Color("#5b493d"), HORIZONTAL_ALIGNMENT_CENTER)
	event_label.name = "EventLabel"
	event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(event_label)

	diary_label = _make_label(21, Color("#302720"), HORIZONTAL_ALIGNMENT_CENTER)
	diary_label.name = "DiaryLabel"
	diary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	diary_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(diary_label)

	reward_label = _make_label(24, Color("#8a5729"), HORIZONTAL_ALIGNMENT_CENTER)
	reward_label.name = "RewardLabel"
	box.add_child(reward_label)

	var back_button := Button.new()
	back_button.name = "BackButton"
	back_button.text = "回到小屋"
	back_button.custom_minimum_size = Vector2(0, 54)
	back_button.add_theme_font_size_override("font_size", 20)
	back_button.add_theme_stylebox_override("normal", _style(Color("#fff3cf"), Color("#d39b4a")))
	back_button.add_theme_stylebox_override("hover", _style(Color("#fff9e6"), Color("#bc7e2e")))
	back_button.pressed.connect(_on_back_button_pressed)
	box.add_child(back_button)


func _show_result() -> void:
	var result := TripResultStore.result
	title_label.text = "%s 回来了！" % result.get("cat_name", "猫咪")
	place_label.text = "地点：%s" % result.get("place", "外面")
	event_label.text = "事件：%s" % result.get("event", "出去玩了一圈")
	diary_label.text = result.get("diary", "猫咪今天过得不错。")
	reward_label.text = "获得金币：%d" % int(result.get("reward_coin", 0))


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainScene.tscn")


func _make_label(font_size: int, color: Color, align: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.horizontal_alignment = align
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 24
	style.content_margin_bottom = 24
	return style
