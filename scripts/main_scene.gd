extends Control

const UiTheme := preload("res://scripts/ui/ui_theme_helper.gd")
const CatScene := preload("res://scenes/Cat.tscn")
const ICON_FEED := preload("res://assets/icon_feed.svg")
const ICON_PLAY := preload("res://assets/icon_play.svg")
const ICON_PET := preload("res://assets/icon_pet.svg")
const ICON_CLEAN := preload("res://assets/icon_clean.svg")
const ICON_SLEEP := preload("res://assets/icon_sleep.svg")

var room_backdrop: RoomBackdrop
var cat: Node2D
var cat_name_label: Label
var top_time_label: Label
var day_night_icon: DayNightIcon
var level_label: Label
var coin_label: Label
var room_title_label: Label
var speech_label: Label
var bottom_tip_label: Label
var feed_button: Button
var touch_button: Button
var play_button: Button
var clean_button: Button
var sleep_button: Button
var save_timer := 0.0
var transient_message := ""
var status_bars := {}
var status_value_labels := {}
var status_card_styles := {}
var status_base_colors := {}


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	if not GameData.load_game():
		get_tree().change_scene_to_file.call_deferred("res://scenes/StartScene.tscn")
		return

	_build_ui()
	refresh_ui()


func _process(delta: float) -> void:
	GameData.tick_online(delta)
	save_timer += delta
	if save_timer >= 8.0 and not GameData.is_outside:
		save_timer = 0.0
		GameData.save_game()

	refresh_ui()

	if GameData.is_trip_finished():
		var result := GameData.finish_trip()
		TripResultStore.result = result
		get_tree().change_scene_to_file("res://scenes/TripResultScene.tscn")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		GameData.save_game()
		get_tree().quit()


func _build_ui() -> void:
	room_backdrop = RoomBackdrop.new()
	room_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	room_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(room_backdrop)

	var room_layer := Node2D.new()
	room_layer.name = "RoomLayer"
	add_child(room_layer)

	cat = CatScene.instantiate()
	cat.name = "Cat"
	room_layer.add_child(cat)
	_layout_cat()

	var ui := MarginContainer.new()
	ui.name = "UI"
	ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.add_theme_constant_override("margin_left", 22)
	ui.add_theme_constant_override("margin_right", 22)
	ui.add_theme_constant_override("margin_top", 22)
	ui.add_theme_constant_override("margin_bottom", 24)
	add_child(ui)

	var page := VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 14)
	ui.add_child(page)

	page.add_child(_build_top_bar())
	page.add_child(_build_cat_room())
	page.add_child(_build_status_panel())
	page.add_child(_build_action_panel())
	page.add_child(_build_bottom_tip_bar())


func _build_top_bar() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 112)
	panel.add_theme_stylebox_override("panel", _style(UiTheme.COLOR_PANEL, UiTheme.COLOR_BORDER, 30, 3, 8))

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	panel.add_child(header)

	var title_box := HBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_box.add_theme_constant_override("separation", 12)
	header.add_child(title_box)

	var home_icon := HomeIcon.new()
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

	day_night_icon = DayNightIcon.new()
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

	var coin_icon := CoinIcon.new()
	coin_icon.custom_minimum_size = Vector2(36, 36)
	coin_box.add_child(coin_icon)

	coin_label = _label("", 22, UiTheme.COLOR_TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	coin_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	coin_box.add_child(coin_label)
	header.add_child(coin_pill)

	return panel


func _build_cat_room() -> Control:
	var room := Control.new()
	room.custom_minimum_size = Vector2(0, 570)
	room.size_flags_vertical = Control.SIZE_EXPAND_FILL
	room.mouse_filter = Control.MOUSE_FILTER_IGNORE

	room_title_label = Label.new()
	room_title_label.name = "RoomTitleLabel"
	room_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	room_title_label.add_theme_font_size_override("font_size", 38)
	room_title_label.add_theme_color_override("font_color", Color("#5a3217"))
	room_title_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	room_title_label.offset_top = 50
	room_title_label.offset_bottom = 100
	room.add_child(room_title_label)

	var left_sparkle := SparkleIcon.new()
	left_sparkle.tint = Color("#ffc04b")
	left_sparkle.set_anchors_preset(Control.PRESET_TOP_WIDE)
	left_sparkle.offset_left = 210
	left_sparkle.offset_right = -496
	left_sparkle.offset_top = 58
	left_sparkle.offset_bottom = 94
	room.add_child(left_sparkle)

	var right_sparkle := SparkleIcon.new()
	right_sparkle.tint = Color("#ffc04b")
	right_sparkle.set_anchors_preset(Control.PRESET_TOP_WIDE)
	right_sparkle.offset_left = 500
	right_sparkle.offset_right = -206
	right_sparkle.offset_top = 58
	right_sparkle.offset_bottom = 94
	room.add_child(right_sparkle)

	var underline := DoodleUnderline.new()
	underline.set_anchors_preset(Control.PRESET_TOP_WIDE)
	underline.offset_left = 206
	underline.offset_right = -206
	underline.offset_top = 104
	underline.offset_bottom = 132
	room.add_child(underline)

	var bubble := PanelContainer.new()
	bubble.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	bubble.offset_left = -284
	bubble.offset_right = -22
	bubble.offset_top = 172
	bubble.offset_bottom = 264
	bubble.add_theme_stylebox_override("panel", _style(Color(1, 0.98, 0.92, 0.92), Color("#dcb785"), 34, 2, 3))
	room.add_child(bubble)

	speech_label = Label.new()
	speech_label.name = "SpeechLabel"
	speech_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	speech_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	speech_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	speech_label.add_theme_font_size_override("font_size", 22)
	speech_label.add_theme_color_override("font_color", Color("#4a2f1c"))
	bubble.add_child(speech_label)

	var bubble_tail := BubbleTail.new()
	bubble_tail.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	bubble_tail.offset_left = -274
	bubble_tail.offset_right = -222
	bubble_tail.offset_top = 250
	bubble_tail.offset_bottom = 304
	room.add_child(bubble_tail)

	return room


func _build_status_panel() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 260)
	panel.add_theme_stylebox_override("panel", _style(UiTheme.COLOR_PANEL_LIGHT, UiTheme.COLOR_BORDER, 28, 3, 5))

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	panel.add_child(grid)

	_add_status_card(grid, "hunger", "饱食", "hunger", UiTheme.COLOR_HUNGER, Color("#ffe9dc"))
	_add_status_card(grid, "mood", "开心", "mood", UiTheme.COLOR_HAPPY, Color("#ffe8f0"))
	_add_status_card(grid, "energy", "精力", "energy", UiTheme.COLOR_ENERGY, Color("#eeeaff"))
	_add_status_card(grid, "clean", "清洁", "clean", UiTheme.COLOR_CLEAN, Color("#e7fbff"))
	return panel


func _add_status_card(parent: GridContainer, id: String, title: String, icon_kind: String, color: Color, bg: Color) -> void:
	status_base_colors[id] = color
	var card := StatusCardPanel.new()
	card.accent = color
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var card_style := _style(bg, color.lightened(0.25), 18, 2, 1)
	card.add_theme_stylebox_override("panel", card_style)
	status_card_styles[id] = card_style
	parent.add_child(card)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	card.add_child(row)

	var icon := StatusIcon.new()
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

	var value_label := _label("", 20, color, HORIZONTAL_ALIGNMENT_RIGHT)
	value_label.custom_minimum_size = Vector2(70, 0)
	top.add_child(value_label)
	status_value_labels[id] = value_label

	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 100
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 28)
	bar.add_theme_stylebox_override("background", _style(Color(1, 1, 1, 0.72), Color(0, 0, 0, 0), 12, 0))
	details.add_child(bar)
	status_bars[id] = bar


func _build_action_panel() -> Control:
	var actions := HBoxContainer.new()
	actions.custom_minimum_size = Vector2(0, 158)
	actions.add_theme_constant_override("separation", 14)

	feed_button = _make_action_button("喂食", ICON_FEED, "恢复饱腹，稍微增加心情", UiTheme.COLOR_BTN_FEED, Color("#e7a84e"), Callable(self, "_on_feed_button_pressed"))
	actions.add_child(feed_button)

	play_button = _make_action_button("玩耍", ICON_PLAY, "消耗精力，降低好奇心，提升心情", UiTheme.COLOR_BTN_PLAY, Color("#68b6d5"), Callable(self, "_on_play_button_pressed"))
	actions.add_child(play_button)

	touch_button = _make_action_button("抚摸", ICON_PET, "增加心情和亲密", UiTheme.COLOR_BTN_PET, Color("#ef8b83"), Callable(self, "_on_touch_button_pressed"))
	actions.add_child(touch_button)

	clean_button = _make_action_button("洗澡", ICON_CLEAN, "把干净值恢复到满", UiTheme.COLOR_BTN_BATH, Color("#68bd8a"), Callable(self, "_on_clean_button_pressed"))
	actions.add_child(clean_button)

	sleep_button = _make_action_button("睡觉", ICON_SLEEP, "睡觉或叫醒猫咪", UiTheme.COLOR_BTN_SLEEP, Color("#9c6ce8"), Callable(self, "_on_sleep_button_pressed"))
	actions.add_child(sleep_button)

	return actions


func _build_bottom_tip_bar() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 78)
	panel.add_theme_stylebox_override("panel", _style(UiTheme.COLOR_PANEL, UiTheme.COLOR_BORDER, 24, 3, 4))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	panel.add_child(row)

	var icon := HomeIcon.new()
	icon.custom_minimum_size = Vector2(54, 54)
	row.add_child(icon)

	bottom_tip_label = _label("", 22, Color("#7a5638"), HORIZONTAL_ALIGNMENT_LEFT)
	bottom_tip_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bottom_tip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bottom_tip_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(bottom_tip_label)

	var heart := HeartIcon.new()
	heart.custom_minimum_size = Vector2(48, 48)
	row.add_child(heart)
	return panel


func refresh_ui() -> void:
	if cat_name_label == null:
		return

	_layout_cat()
	var night_amount := _night_amount()
	if room_backdrop != null:
		room_backdrop.night_amount = night_amount
		room_backdrop.queue_redraw()
	if day_night_icon != null:
		day_night_icon.night_amount = night_amount
		day_night_icon.queue_redraw()

	cat_name_label.text = "%s的小屋" % GameData.selected_cat_name
	top_time_label.text = _time_text()
	level_label.text = "Lv.%d" % _display_level()
	coin_label.text = "%d" % GameData.coin
	room_title_label.text = _state_title_text()
	speech_label.text = _speech_text()
	bottom_tip_label.text = _bottom_tip_text()
	_update_status_card("hunger", GameData.hunger)
	_update_status_card("mood", GameData.mood)
	_update_status_card("energy", GameData.energy)
	_update_status_card("clean", GameData.clean)

	if GameData.is_outside:
		sleep_button.text = "外出中"
		sleep_button.disabled = true
		feed_button.disabled = true
		touch_button.disabled = true
		play_button.disabled = true
		clean_button.disabled = true
	else:
		sleep_button.text = "叫醒" if GameData.is_sleeping else "睡觉"
		sleep_button.disabled = false
		feed_button.disabled = false
		touch_button.disabled = false
		play_button.disabled = false
		clean_button.disabled = false


func _layout_cat() -> void:
	if cat == null:
		return

	var viewport_size := get_viewport_rect().size
	var cat_scale := clampf(viewport_size.x / 520.0, 1.12, 1.48)
	cat.scale = Vector2.ONE * cat_scale
	cat.position = Vector2(viewport_size.x * 0.50, clampf(viewport_size.y * 0.455, 520.0, 640.0))


func _display_level() -> int:
	return maxi(1, int(GameData.favor / 12) + 1)


func _time_text() -> String:
	var dt := Time.get_datetime_dict_from_system()
	var hour := int(dt["hour"])
	var minute := int(dt["minute"])
	var period := "上午"
	if hour >= 18:
		period = "夜晚"
	elif hour >= 12:
		period = "下午"
	return "%s %02d:%02d" % [period, hour, minute]


func _night_amount() -> float:
	var hour := int(Time.get_datetime_dict_from_system()["hour"])
	if hour >= 19 or hour < 6:
		return 1.0
	if hour >= 17:
		return 0.42
	if hour < 8:
		return 0.25
	return 0.0


func _state_title_text() -> String:
	if GameData.is_outside:
		return "%s正在外出" % GameData.selected_cat_name
	if GameData.is_sleeping:
		return "%s正在睡觉" % GameData.selected_cat_name
	if GameData.hunger < 35.0:
		return "%s有点饿了" % GameData.selected_cat_name
	if GameData.energy < 30.0:
		return "%s想打盹" % GameData.selected_cat_name
	if GameData.clean < 35.0:
		return "%s想整理毛毛" % GameData.selected_cat_name
	if GameData.mood < 45.0:
		return "%s想被陪陪" % GameData.selected_cat_name
	return "%s在小屋里休息" % GameData.selected_cat_name


func _speech_text() -> String:
	if GameData.is_outside:
		return "我去外面看看，马上回来。"
	if GameData.is_sleeping:
		return "Zzz...\n精力正在恢复"
	if GameData.hunger < 30.0:
		return "饭碗好像空了喵……"
	if GameData.mood < 30.0:
		return "今天还没人陪我玩。"
	if GameData.energy < 30.0:
		return "眼睛快睁不开了……"
	if GameData.clean < 30.0:
		return "毛毛有点乱啦。"
	return "喵～今天想贴贴你。"


func _bottom_tip_text() -> String:
	if GameData.is_outside:
		var remain: int = maxi(GameData.trip_end_time - int(Time.get_unix_time_from_system()), 0)
		return "%s出门探索中，还剩 %d 秒。" % [GameData.selected_cat_name, remain]
	if transient_message != "":
		return transient_message
	if GameData.offline_summary != "":
		return GameData.offline_summary
	if GameData.last_event_text != "":
		return GameData.last_event_text
	if GameData.is_sleeping:
		return "欢迎回家，%s已经在软窝里睡着了。" % GameData.selected_cat_name
	return "欢迎回家，%s已经在门口等你了。" % GameData.selected_cat_name


func _update_status_card(id: String, value: float) -> void:
	var rounded := int(value)
	status_bars[id].value = rounded
	status_value_labels[id].text = "%d%%" % rounded
	status_value_labels[id].add_theme_color_override("font_color", _status_color(status_base_colors[id], value))
	var fill := StyleBoxFlat.new()
	fill.bg_color = _status_color(status_base_colors[id], value)
	fill.set_corner_radius_all(12)
	status_bars[id].add_theme_stylebox_override("fill", fill)

	var style: StyleBoxFlat = status_card_styles[id]
	style.border_color = _status_color(status_base_colors[id], value).lightened(0.25)
	style.shadow_color = Color(0.56, 0.24, 0.12, 0.16 if value < 40.0 else 0.06)
	style.shadow_size = 4 if value < 40.0 else 1


func _status_color(base: Color, value: float) -> Color:
	if value < 40.0:
		return Color("#e85d5d")
	if value < 70.0:
		return Color("#f0a84f")
	return base


func _on_feed_button_pressed() -> void:
	_play_press_anim(feed_button)
	var result: Dictionary = await cat.feed()
	transient_message = result.get("message", "")
	refresh_ui()


func _on_touch_button_pressed() -> void:
	_play_press_anim(touch_button)
	var result: Dictionary = await cat.touch_cat()
	transient_message = result.get("message", "")
	refresh_ui()


func _on_play_button_pressed() -> void:
	_play_press_anim(play_button)
	var result: Dictionary = await cat.play_cat()
	transient_message = result.get("message", "")
	refresh_ui()


func _on_clean_button_pressed() -> void:
	_play_press_anim(clean_button)
	var result: Dictionary = await cat.clean_cat()
	transient_message = result.get("message", "")
	refresh_ui()


func _on_sleep_button_pressed() -> void:
	_play_press_anim(sleep_button)
	if GameData.is_outside:
		return

	if GameData.is_sleeping:
		GameData.wake_up()
		transient_message = "%s伸了个懒腰，醒来啦。" % GameData.selected_cat_name
	else:
		GameData.start_sleep()
		transient_message = "%s钻进软窝，开始补觉。" % GameData.selected_cat_name
	if cat != null:
		cat.refresh_visual_state()
	refresh_ui()


func _play_press_anim(button: Control) -> void:
	if button == null:
		return
	button.pivot_offset = button.size * 0.5
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(0.94, 0.94), 0.06)
	tween.tween_property(button, "scale", Vector2.ONE, 0.08)


func _make_action_button(text: String, icon: Texture2D, tooltip: String, bg: Color, border: Color, target: Callable) -> Button:
	var button := CuteActionButton.new()
	button.sparkle_color = border.lightened(0.25)
	button.text = text
	button.icon = icon
	button.expand_icon = true
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.tooltip_text = tooltip
	button.custom_minimum_size = Vector2(126, 148)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", Color("#4a2f1c"))
	button.add_theme_stylebox_override("normal", _style(bg, border, 22, 3, 4))
	button.add_theme_stylebox_override("hover", _style(bg.lightened(0.18), border, 22, 3, 4))
	button.add_theme_stylebox_override("pressed", _style(bg.darkened(0.05), border.darkened(0.08), 22, 3, 2))
	button.pressed.connect(target)
	return button


func _make_pill(bg: Color, border: Color, width: float, height: float) -> PanelContainer:
	var pill := PanelContainer.new()
	pill.custom_minimum_size = Vector2(width, height)
	pill.add_theme_stylebox_override("panel", _style(bg, border, int(height * 0.5), 2, 1))
	return pill


func _label(text: String, font_size: int, color: Color, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _style(bg: Color, border: Color, radius: int = 8, border_width: int = 2, shadow_size: int = 0) -> StyleBoxFlat:
	return UiTheme.make_panel_style(bg, radius, border, border_width, shadow_size)


class HomeIcon:
	extends Control

	func _draw() -> void:
		var c := size * 0.5
		var s := minf(size.x, size.y) / 58.0
		var roof := PackedVector2Array([
			c + Vector2(-22, -4) * s,
			c + Vector2(0, -24) * s,
			c + Vector2(22, -4) * s
		])
		draw_polyline(roof, Color("#d36e45"), 6.0 * s, true)
		draw_rect(Rect2(c + Vector2(-16, -4) * s, Vector2(32, 28) * s), Color("#fff4d8"))
		draw_rect(Rect2(c + Vector2(-16, -4) * s, Vector2(32, 28) * s), Color("#8d6849"), false, 3.0 * s)
		draw_rect(Rect2(c + Vector2(-7, 9) * s, Vector2(14, 15) * s), Color("#75bfc6"))
		draw_circle(c + Vector2(0, -1) * s, 4.2 * s, Color("#b47a4d"))
		for p in [Vector2(-8, -5), Vector2(-3, -9), Vector2(3, -9), Vector2(8, -5)]:
			draw_circle(c + p * s, 2.4 * s, Color("#b47a4d"))


class DayNightIcon:
	extends Control

	var night_amount := 0.0

	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * 0.22
		if night_amount > 0.65:
			draw_circle(c, r * 1.18, Color("#6d65d9"))
			draw_circle(c + Vector2(8, -6), r * 1.02, Color("#e9ddff"))
			draw_circle(c + Vector2(16, -9), r * 0.94, Color("#fff8ea"))
			for p in [Vector2(-15, 11), Vector2(14, 14), Vector2(-5, -18)]:
				draw_circle(c + p, 2.2, Color("#ffd35b"))
		else:
			for i in range(10):
				var angle := TAU * float(i) / 10.0
				var a := c + Vector2(cos(angle), sin(angle)) * r * 1.65
				var b := c + Vector2(cos(angle), sin(angle)) * r * 2.2
				draw_line(a, b, Color("#f5aa28"), 3.0)
			draw_circle(c, r, Color("#ffbd45"))
			draw_circle(c + Vector2(-4, -4), r * 0.45, Color(1, 1, 1, 0.28))


class SparkleIcon:
	extends Control

	var tint := Color("#ffc04b")

	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * 0.38
		var pts := PackedVector2Array([
			c + Vector2(0, -r),
			c + Vector2(r * 0.28, -r * 0.28),
			c + Vector2(r, 0),
			c + Vector2(r * 0.28, r * 0.28),
			c + Vector2(0, r),
			c + Vector2(-r * 0.28, r * 0.28),
			c + Vector2(-r, 0),
			c + Vector2(-r * 0.28, -r * 0.28)
		])
		draw_polygon(pts, PackedColorArray([tint, tint, tint, tint, tint, tint, tint, tint]))
		draw_circle(c + Vector2(r * 0.84, -r * 0.72), r * 0.13, tint.lightened(0.15))


class CuteActionButton:
	extends Button

	var sparkle_color := Color("#ffd35b")

	func _draw() -> void:
		var p := Vector2(size.x - 22, 18)
		_draw_sparkle(p, 10.0)
		if text == "叫醒":
			_draw_sparkle(Vector2(22, 32), 8.0)

	func _draw_sparkle(c: Vector2, r: float) -> void:
		var pts := PackedVector2Array([
			c + Vector2(0, -r),
			c + Vector2(r * 0.28, -r * 0.28),
			c + Vector2(r, 0),
			c + Vector2(r * 0.28, r * 0.28),
			c + Vector2(0, r),
			c + Vector2(-r * 0.28, r * 0.28),
			c + Vector2(-r, 0),
			c + Vector2(-r * 0.28, -r * 0.28)
		])
		draw_polygon(pts, PackedColorArray([sparkle_color, sparkle_color, sparkle_color, sparkle_color, sparkle_color, sparkle_color, sparkle_color, sparkle_color]))


class StatusCardPanel:
	extends PanelContainer

	var accent := Color("#f47c62")

	func _draw() -> void:
		var c := Vector2(size.x - 22, 22)
		var r := 9.0
		var pts := PackedVector2Array([
			c + Vector2(0, -r),
			c + Vector2(r * 0.26, -r * 0.26),
			c + Vector2(r, 0),
			c + Vector2(r * 0.26, r * 0.26),
			c + Vector2(0, r),
			c + Vector2(-r * 0.26, r * 0.26),
			c + Vector2(-r, 0),
			c + Vector2(-r * 0.26, -r * 0.26)
		])
		var color := accent.lightened(0.35)
		draw_polygon(pts, PackedColorArray([color, color, color, color, color, color, color, color]))


class CoinIcon:
	extends Control

	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * 0.42
		draw_circle(c, r, Color("#f7a71d"))
		draw_circle(c, r * 0.78, Color("#ffd45f"))
		draw_arc(c, r * 0.55, 0.0, TAU, 40, Color("#c87911"), 3.0)
		draw_string(ThemeDB.fallback_font, c + Vector2(-8, 10), "$", HORIZONTAL_ALIGNMENT_CENTER, 16, 22, Color("#9f640d"))


class HeartIcon:
	extends Control

	func _draw() -> void:
		var c := size * 0.5
		var color := Color("#f4939d")
		draw_circle(c + Vector2(-8, -5), 10.0, color)
		draw_circle(c + Vector2(8, -5), 10.0, color)
		draw_polygon(PackedVector2Array([
			c + Vector2(-18, -2),
			c + Vector2(18, -2),
			c + Vector2(0, 20)
		]), PackedColorArray([color, color, color]))
		draw_circle(c + Vector2(11, -15), 3.0, Color("#ffd35b"))
		draw_circle(c + Vector2(19, -5), 2.2, Color("#ffd35b"))


class DoodleUnderline:
	extends Control

	func _draw() -> void:
		var color := Color("#f4b13f")
		var y := size.y * 0.42
		var last := Vector2(0, y)
		for i in range(1, 18):
			var x := size.x * float(i) / 17.0
			var p := Vector2(x, y + sin(float(i) * 0.9) * 5.0)
			draw_line(last, p, color, 3.0)
			last = p
		draw_circle(Vector2(2, y), 3.0, color)
		draw_circle(Vector2(size.x - 2, last.y), 3.0, color)


class BubbleTail:
	extends Control

	func _draw() -> void:
		var outline := Color("#dcb785")
		var fill := Color(1, 0.98, 0.92, 0.92)
		draw_circle(Vector2(16, 18), 10.0, fill)
		draw_circle(Vector2(16, 18), 10.0, outline, false, 2.0)
		draw_circle(Vector2(36, 34), 6.0, fill)
		draw_circle(Vector2(36, 34), 6.0, outline, false, 2.0)


class StatusIcon:
	extends Control

	var kind := "hunger"
	var tint := Color("#f97355")

	func _draw() -> void:
		var c := size * 0.5
		var r := minf(size.x, size.y) * 0.44
		draw_circle(c, r, tint.lightened(0.48))
		draw_circle(c, r * 0.78, tint.lightened(0.18))
		match kind:
			"hunger":
				_draw_bowl(c, r)
			"mood":
				_draw_smile(c, r)
			"energy":
				_draw_bolt(c, r)
			_:
				_draw_drop(c, r)

	func _draw_bowl(c: Vector2, r: float) -> void:
		draw_oval(c + Vector2(0, 11), r * 0.62, Vector2(1.28, 0.48), Color("#f16a43"))
		draw_rect(Rect2(c + Vector2(-22, 2), Vector2(44, 16)), Color("#f97355"))
		for x in [-13.0, -4.0, 6.0, 15.0]:
			draw_circle(c + Vector2(x, -7), 5.5, Color("#b66d2a"))
		draw_circle(c + Vector2(0, 12), 5.0, Color("#fff4dc"))

	func _draw_smile(c: Vector2, r: float) -> void:
		draw_circle(c, r * 0.55, Color("#ff6ea3"))
		draw_circle(c + Vector2(-11, -7), 4.0, Color("#4a2f1c"))
		draw_circle(c + Vector2(11, -7), 4.0, Color("#4a2f1c"))
		draw_arc(c + Vector2(0, 0), 16.0, 0.15, PI - 0.15, 18, Color("#4a2f1c"), 3.0)
		draw_circle(c + Vector2(-16, 5), 4.5, Color("#ffadc9"))
		draw_circle(c + Vector2(16, 5), 4.5, Color("#ffadc9"))

	func _draw_bolt(c: Vector2, r: float) -> void:
		var pts := PackedVector2Array([
			c + Vector2(2, -26),
			c + Vector2(-17, 3),
			c + Vector2(-2, 3),
			c + Vector2(-9, 27),
			c + Vector2(18, -8),
			c + Vector2(3, -8)
		])
		draw_polygon(pts, PackedColorArray([Color("#675ae5"), Color("#675ae5"), Color("#675ae5"), Color("#675ae5"), Color("#675ae5"), Color("#675ae5")]))
		draw_polyline(pts, Color("#ffffff"), 2.4, true)

	func _draw_drop(c: Vector2, r: float) -> void:
		var pts := PackedVector2Array([
			c + Vector2(0, -28),
			c + Vector2(-22, 2),
			c + Vector2(-12, 23),
			c + Vector2(11, 24),
			c + Vector2(23, 2)
		])
		draw_polygon(pts, PackedColorArray([Color("#42b7c9"), Color("#42b7c9"), Color("#42b7c9"), Color("#42b7c9"), Color("#42b7c9")]))
		draw_circle(c + Vector2(-3, 7), 17.0, Color("#42b7c9"))
		draw_arc(c + Vector2(2, 7), 12.0, 0.2, PI * 0.9, 18, Color("#eaffff"), 3.0)
		draw_circle(c + Vector2(17, -16), 4.5, Color("#eaffff"))

	func draw_oval(center: Vector2, radius: float, oval_scale: Vector2, color: Color) -> void:
		draw_set_transform(center, 0.0, oval_scale)
		draw_circle(Vector2.ZERO, radius, color)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


class RoomBackdrop:
	extends Control

	var night_amount := 0.0

	func _draw() -> void:
		var top := Color("#fff0cf").lerp(Color("#3c355f"), night_amount)
		var bottom := Color("#ffe0b5").lerp(Color("#6a5670"), night_amount)
		for i in range(36):
			var t := float(i) / 35.0
			draw_rect(Rect2(0, size.y * t, size.x, size.y / 35.0 + 2.0), top.lerp(bottom, t))

		var floor_y := size.y * 0.50
		draw_rect(Rect2(0, floor_y, size.x, size.y - floor_y), Color("#e9bd7b").lerp(Color("#9e7a6b"), night_amount))
		for i in range(13):
			var x := size.x * float(i) / 12.0
			draw_line(Vector2(x, floor_y), Vector2(x - 82.0, size.y), Color(1, 1, 1, 0.20), 2.0)

		_draw_window(Vector2(size.x * 0.08, size.y * 0.12))
		_draw_curtain(Vector2(size.x * 0.20, size.y * 0.12))
		_draw_shelf(Vector2(size.x * 0.72, size.y * 0.19))
		_draw_scratcher(Vector2(size.x * 0.085, size.y * 0.40))
		_draw_cat_house(Vector2(size.x * 0.83, size.y * 0.43))
		_draw_rug(Vector2(size.x * 0.5, size.y * 0.58))
		_draw_soft_bed(Vector2(size.x * 0.50, size.y * 0.52))
		_draw_yarn(Vector2(size.x * 0.12, size.y * 0.64))
		_draw_bowl(Vector2(size.x * 0.84, size.y * 0.64))

	func _draw_window(pos: Vector2) -> void:
		var rect := Rect2(pos, Vector2(154, 170))
		draw_rect(rect, Color("#bfeaff").lerp(Color("#1c2e57"), night_amount))
		if night_amount > 0.65:
			draw_circle(pos + Vector2(114, 36), 26.0, Color("#f3edbf"))
			draw_circle(pos + Vector2(125, 28), 24.0, Color("#1c2e57"))
			for p in [Vector2(28, 34), Vector2(64, 54), Vector2(38, 104), Vector2(118, 120), Vector2(94, 82)]:
				draw_circle(pos + p, 2.6, Color("#fff0aa"))
		else:
			draw_circle(pos + Vector2(126, 32), 28.0, Color(1, 1, 1, 0.72))
			draw_circle(pos + Vector2(28, 118), 48.0, Color(1, 1, 1, 0.65))
		draw_rect(rect, Color("#e8b976"), false, 5.0)
		draw_line(Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y), Vector2(rect.position.x + rect.size.x * 0.5, rect.end.y), Color("#e8b976"), 4.0)
		draw_line(Vector2(rect.position.x, rect.position.y + rect.size.y * 0.5), Vector2(rect.end.x, rect.position.y + rect.size.y * 0.5), Color("#e8b976"), 4.0)
		draw_rect(Rect2(pos + Vector2(-10, 170), Vector2(178, 12)), Color("#e8b976"))
		_draw_plant(pos + Vector2(58, 146))

	func _draw_curtain(pos: Vector2) -> void:
		draw_polygon(PackedVector2Array([
			pos + Vector2(0, 0),
			pos + Vector2(72, 0),
			pos + Vector2(58, 306),
			pos + Vector2(10, 306)
		]), PackedColorArray([Color("#fff0c9"), Color("#fff0c9"), Color("#fff0c9"), Color("#fff0c9")]))
		for i in range(4):
			var x := pos.x + 12.0 + i * 14.0
			draw_line(Vector2(x, pos.y + 8), Vector2(x - 8.0, pos.y + 300), Color(1, 1, 1, 0.28), 3.0)
		draw_oval(pos + Vector2(34, 132), 22.0, Vector2(1.35, 0.62), Color("#f2c988"))

	func _draw_shelf(pos: Vector2) -> void:
		draw_rect(Rect2(pos + Vector2(-30, 70), Vector2(190, 14)), Color("#c98442"))
		draw_rect(Rect2(pos + Vector2(0, 84), Vector2(18, 42)), Color("#b87438"))
		draw_rect(Rect2(pos + Vector2(118, 84), Vector2(18, 42)), Color("#b87438"))
		draw_rect(Rect2(pos + Vector2(12, 0), Vector2(80, 70)), Color("#f4d1a8"))
		draw_rect(Rect2(pos + Vector2(12, 0), Vector2(80, 70)), Color("#c98442"), false, 5.0)
		draw_circle(pos + Vector2(52, 36), 22.0, Color("#ffe3bd"))
		draw_circle(pos + Vector2(136, 30), 18.0, Color("#79ad4d"))
		draw_rect(Rect2(pos + Vector2(120, 46), Vector2(34, 32)), Color("#d49243"))
		for p in [Vector2(154, 54), Vector2(170, 74), Vector2(164, 96), Vector2(146, 116), Vector2(176, 118)]:
			draw_circle(pos + p, 13.0, Color("#6ca449"))

	func _draw_scratcher(pos: Vector2) -> void:
		draw_oval(pos + Vector2(34, 172), 38.0, Vector2(1.22, 0.38), Color("#c88a4c"))
		draw_rect(Rect2(pos + Vector2(20, 46), Vector2(28, 124)), Color("#d3a468"))
		for y in range(54, 160, 12):
			draw_line(pos + Vector2(20, y), pos + Vector2(48, y - 8), Color("#b9814d"), 2.0)
		draw_oval(pos + Vector2(34, 42), 42.0, Vector2(1.55, 0.34), Color("#dfb178"))
		draw_line(pos + Vector2(56, 56), pos + Vector2(66, 106), Color("#d59b57"), 2.0)
		draw_circle(pos + Vector2(66, 114), 10.0, Color("#f4b84a"))

	func _draw_cat_house(pos: Vector2) -> void:
		draw_oval(pos + Vector2(56, 90), 64.0, Vector2(0.98, 0.92), Color("#f1c48f"))
		draw_oval(pos + Vector2(56, 96), 38.0, Vector2(0.92, 0.96), Color("#7b4b2b"))
		draw_oval(pos + Vector2(56, 118), 32.0, Vector2(1.2, 0.34), Color("#f1d363"))
		draw_circle(pos + Vector2(78, 24), 22.0, Color("#ffd4ad"))
		draw_circle(pos + Vector2(34, 24), 22.0, Color("#ffd4ad"))
		draw_circle(pos + Vector2(56, 18), 18.0, Color("#ffd4ad"))

	func _draw_rug(center: Vector2) -> void:
		draw_oval(center + Vector2(0, 54), 142.0, Vector2(2.22, 0.42), Color("#f5c458"))
		draw_oval(center + Vector2(0, 54), 118.0, Vector2(2.12, 0.32), Color("#ffd87a"))
		for i in range(14):
			var x := center.x - 250.0 + i * 38.0
			draw_circle(Vector2(x, center.y + 58.0 + sin(float(i)) * 8.0), 4.0, Color("#fff0bb"))

	func _draw_soft_bed(center: Vector2) -> void:
		draw_oval(center + Vector2(0, 86), 118.0, Vector2(1.95, 0.45), Color("#f1d9ad"))
		draw_oval(center + Vector2(0, 70), 136.0, Vector2(1.86, 0.42), Color("#fff4da"))
		draw_oval(center + Vector2(0, 68), 94.0, Vector2(1.72, 0.30), Color("#ffe2a3"))

	func _draw_yarn(pos: Vector2) -> void:
		draw_circle(pos, 28.0, Color("#86cfe1"))
		for angle in [0.2, 0.9, 1.6, 2.4]:
			draw_arc(pos, 24.0, angle, angle + PI * 0.92, 22, Color("#4ca3ba"), 2.0)
		draw_line(pos + Vector2(-4, 24), pos + Vector2(-42, 38), Color("#4ca3ba"), 3.0)

	func _draw_bowl(pos: Vector2) -> void:
		draw_oval(pos + Vector2(0, 26), 42.0, Vector2(1.45, 0.44), Color("#ef8a56"))
		draw_rect(Rect2(pos + Vector2(-42, 8), Vector2(84, 28)), Color("#f6a46f"))
		for i in range(10):
			draw_circle(pos + Vector2(-28 + i * 6.0, 4 + sin(float(i)) * 5.0), 5.0, Color("#9c5b1f"))

	func _draw_plant(pos: Vector2) -> void:
		draw_rect(Rect2(pos + Vector2(-18, 14), Vector2(36, 30)), Color("#d77b38"))
		for p in [Vector2(-28, -18), Vector2(-10, -28), Vector2(12, -24), Vector2(30, -12), Vector2(0, -8)]:
			draw_oval(pos + p, 14.0, Vector2(0.72, 1.25), Color("#82b84d"))
		draw_line(pos + Vector2(0, 16), pos + Vector2(0, -28), Color("#5f9f3d"), 3.0)

	func draw_oval(center: Vector2, radius: float, oval_scale: Vector2, color: Color) -> void:
		draw_set_transform(center, 0.0, oval_scale)
		draw_circle(Vector2.ZERO, radius, color)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
