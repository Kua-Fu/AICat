extends Control

const TopBarScene := preload("res://scripts/ui/top_bar.gd")
const CatRoomScene := preload("res://scripts/ui/cat_room.gd")
const StatusPanelScene := preload("res://scripts/ui/status_panel.gd")
const ActionPanelScene := preload("res://scripts/ui/action_panel.gd")
const BottomTipBarScene := preload("res://scripts/ui/bottom_tip_bar.gd")

var cat: Node2D
var top_bar
var cat_room
var status_panel
var action_panel
var bottom_tip_bar
var save_timer := 0.0
var transient_message := ""


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
	var background := ColorRect.new()
	background.name = "PageBackground"
	background.color = Color("#fff7ea")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var ui := MarginContainer.new()
	ui.name = "UI"
	ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.add_theme_constant_override("margin_left", 18)
	ui.add_theme_constant_override("margin_right", 18)
	ui.add_theme_constant_override("margin_top", 18)
	ui.add_theme_constant_override("margin_bottom", 24)
	add_child(ui)

	var page := VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 12)
	ui.add_child(page)

	top_bar = TopBarScene.new()
	page.add_child(top_bar)

	cat_room = CatRoomScene.new()
	page.add_child(cat_room)
	cat = cat_room.get_cat()

	status_panel = StatusPanelScene.new()
	page.add_child(status_panel)

	action_panel = ActionPanelScene.new()
	action_panel.action_requested.connect(_on_action_requested)
	page.add_child(action_panel)

	bottom_tip_bar = BottomTipBarScene.new()
	page.add_child(bottom_tip_bar)


func refresh_ui() -> void:
	if top_bar == null:
		return

	var night_amount := _night_amount()

	top_bar.set_data(GameData.selected_cat_name, _time_text(), night_amount, _display_level(), GameData.coin)
	cat_room.set_night_amount(night_amount)
	cat_room.set_texts(_state_title_text(), _speech_text())
	status_panel.update_values(GameData.hunger, GameData.mood, GameData.energy, GameData.clean)
	bottom_tip_bar.set_tip(_bottom_tip_text())
	action_panel.update_availability(GameData.is_outside, GameData.is_sleeping)


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


func _on_action_requested(action: String, button: Button) -> void:
	_play_press_anim(button)
	if action == "sleep":
		_toggle_sleep()
		return

	var result: Dictionary = {}
	match action:
		"feed":
			result = await cat.feed()
		"touch":
			result = await cat.touch_cat()
		"play":
			result = await cat.play_cat()
		"clean":
			result = await cat.clean_cat()
		_:
			return

	transient_message = result.get("message", "")
	refresh_ui()


func _toggle_sleep() -> void:
	if GameData.is_outside:
		return

	if GameData.is_sleeping:
		GameData.wake_up()
		transient_message = "%s伸了个懒腰，醒来啦。" % GameData.selected_cat_name
		if cat != null and cat.has_method("play_wake"):
			cat.play_wake()
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
