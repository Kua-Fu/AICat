extends Control

const SAVE_PATH := "user://ai_cat_save.cfg"
const CAT_NAME := "年糕"
const ICON_FEED := preload("res://assets/icon_feed.svg")
const ICON_PLAY := preload("res://assets/icon_play.svg")
const ICON_PET := preload("res://assets/icon_pet.svg")
const ICON_CLEAN := preload("res://assets/icon_clean.svg")
const ICON_SLEEP := preload("res://assets/icon_sleep.svg")
const ICON_COIN := preload("res://assets/icon_coin.svg")
const STATE_TICK_SECONDS := 60.0

class SkyBackdrop:
	extends Control

	var night_amount := 0.0

	func _draw() -> void:
		var top := Color("#8fd3ff").lerp(Color("#182342"), night_amount)
		var bottom := Color("#fff0bf").lerp(Color("#394766"), night_amount)
		for i in range(28):
			var t := float(i) / 27.0
			var band := Rect2(0.0, size.y * t, size.x, (size.y / 27.0) + 2.0)
			draw_rect(band, top.lerp(bottom, t))

		var sun_pos := Vector2(size.x * 0.82, size.y * 0.18).lerp(Vector2(size.x * 0.18, size.y * 0.2), night_amount)
		var sun_color := Color("#ffd35b").lerp(Color("#dfe8ff"), night_amount)
		draw_circle(sun_pos, 44.0, sun_color)
		if night_amount > 0.35:
			draw_circle(sun_pos + Vector2(18, -9), 39.0, Color("#25304f"))
			for p in [Vector2(0.62, 0.16), Vector2(0.72, 0.28), Vector2(0.48, 0.22), Vector2(0.86, 0.33), Vector2(0.29, 0.14)]:
				draw_circle(Vector2(size.x * p.x, size.y * p.y), 2.5, Color("#fff6bf"))

		var floor_y := size.y * 0.72
		draw_rect(Rect2(0, floor_y, size.x, size.y - floor_y), Color("#f4d39a").lerp(Color("#756276"), night_amount))
		for i in range(10):
			var x := size.x * float(i) / 9.0
			draw_line(Vector2(x, floor_y), Vector2(x - 70.0, size.y), Color(1, 1, 1, 0.16), 2.0)

		var rug_center := Vector2(size.x * 0.5, floor_y + 95.0)
		draw_oval(rug_center, 115.0, Vector2(1.8, 0.38), Color("#f27f63").lerp(Color("#9a6972"), night_amount))
		draw_oval(rug_center, 88.0, Vector2(1.6, 0.28), Color("#ffd886").lerp(Color("#c9a66f"), night_amount))

	func draw_oval(center: Vector2, radius: float, scale: Vector2, color: Color) -> void:
		draw_set_transform(center, 0.0, scale)
		draw_circle(Vector2.ZERO, radius, color)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


class CatPortrait:
	extends Control

	var mood := "cozy"
	var sleeping := false
	var pulse := 0.0
	var blink_timer := 0.0
	var blink := false

	func _process(delta: float) -> void:
		if pulse > 0.0:
			pulse = maxf(0.0, pulse - delta * 2.2)
		blink_timer += delta
		if blink_timer > 3.8:
			blink = true
		if blink_timer > 3.95:
			blink = false
			blink_timer = 0.0
		queue_redraw()

	func celebrate() -> void:
		pulse = 1.0

	func _draw() -> void:
		var min_side := minf(size.x, size.y)
		var center := Vector2(size.x * 0.5, size.y * 0.56)
		var bob := sin(Time.get_ticks_msec() / 360.0) * 4.0
		if sleeping:
			bob = sin(Time.get_ticks_msec() / 720.0) * 2.0
		center.y += bob - pulse * 8.0

		var scale := min_side / 420.0
		var fur := Color("#f6a457")
		var fur_dark := Color("#c77238")
		var fur_light := Color("#ffd19b")
		var line := Color("#3d2f2a")
		var blush := Color(1.0, 0.48, 0.52, 0.45)

		draw_oval(center + Vector2(0, 86) * scale, 132.0 * scale, Vector2(1.12, 0.78), Color(0, 0, 0, 0.12))
		draw_oval(center + Vector2(0, 80) * scale, 116.0 * scale, Vector2(1.08, 0.86), fur)

		var tail_base := center + Vector2(94, 58) * scale
		draw_arc(tail_base, 58.0 * scale, -1.55, 1.65, 40, fur_dark, 22.0 * scale, true)
		draw_arc(tail_base, 36.0 * scale, -1.45, 1.25, 34, fur, 18.0 * scale, true)

		var head := center + Vector2(0, -48) * scale
		var left_ear := PackedVector2Array([
			head + Vector2(-80, -30) * scale,
			head + Vector2(-44, -120) * scale,
			head + Vector2(-10, -34) * scale,
		])
		var right_ear := PackedVector2Array([
			head + Vector2(80, -30) * scale,
			head + Vector2(44, -120) * scale,
			head + Vector2(10, -34) * scale,
		])
		draw_polygon(left_ear, PackedColorArray([fur, fur, fur]))
		draw_polygon(right_ear, PackedColorArray([fur, fur, fur]))
		draw_polygon(PackedVector2Array([
			head + Vector2(-57, -42) * scale,
			head + Vector2(-43, -84) * scale,
			head + Vector2(-24, -40) * scale,
		]), PackedColorArray([fur_light, fur_light, fur_light]))
		draw_polygon(PackedVector2Array([
			head + Vector2(57, -42) * scale,
			head + Vector2(43, -84) * scale,
			head + Vector2(24, -40) * scale,
		]), PackedColorArray([fur_light, fur_light, fur_light]))

		draw_oval(head, 100.0 * scale, Vector2(1.0, 0.88), fur)
		draw_oval(head + Vector2(0, 10) * scale, 54.0 * scale, Vector2(1.22, 0.72), fur_light)
		for stripe_x in [-34.0, 0.0, 34.0]:
			draw_line(head + Vector2(stripe_x, -80) * scale, head + Vector2(stripe_x * 0.48, -40) * scale, fur_dark, 8.0 * scale)

		var eye_y := head.y - 14.0 * scale
		var left_eye := Vector2(head.x - 36.0 * scale, eye_y)
		var right_eye := Vector2(head.x + 36.0 * scale, eye_y)
		if sleeping or blink:
			draw_arc(left_eye, 18.0 * scale, 0.1, PI - 0.1, 20, line, 5.0 * scale, true)
			draw_arc(right_eye, 18.0 * scale, 0.1, PI - 0.1, 20, line, 5.0 * scale, true)
		elif mood == "happy":
			draw_arc(left_eye, 18.0 * scale, 0.0, PI, 20, line, 5.0 * scale, true)
			draw_arc(right_eye, 18.0 * scale, 0.0, PI, 20, line, 5.0 * scale, true)
		elif mood == "sad":
			draw_oval(left_eye, 10.0 * scale, Vector2(0.72, 1.25), line)
			draw_oval(right_eye, 10.0 * scale, Vector2(0.72, 1.25), line)
			draw_line(left_eye + Vector2(-18, -18) * scale, left_eye + Vector2(8, -9) * scale, line, 4.0 * scale)
			draw_line(right_eye + Vector2(18, -18) * scale, right_eye + Vector2(-8, -9) * scale, line, 4.0 * scale)
		else:
			draw_oval(left_eye, 11.0 * scale, Vector2(0.82, 1.14), line)
			draw_oval(right_eye, 11.0 * scale, Vector2(0.82, 1.14), line)

		draw_circle(head + Vector2(0, 18) * scale, 7.0 * scale, Color("#6d3f3a"))
		var mouth_y := head.y + 32.0 * scale
		if mood == "sad":
			draw_arc(Vector2(head.x, mouth_y + 18.0 * scale), 18.0 * scale, PI + 0.15, TAU - 0.15, 24, line, 4.0 * scale, true)
		else:
			draw_arc(Vector2(head.x - 10.0 * scale, mouth_y), 12.0 * scale, 0.0, PI, 16, line, 4.0 * scale, true)
			draw_arc(Vector2(head.x + 10.0 * scale, mouth_y), 12.0 * scale, 0.0, PI, 16, line, 4.0 * scale, true)

		draw_oval(head + Vector2(-58, 18) * scale, 16.0 * scale, Vector2(1.35, 0.72), blush)
		draw_oval(head + Vector2(58, 18) * scale, 16.0 * scale, Vector2(1.35, 0.72), blush)
		for side in [-1.0, 1.0]:
			var whisker_from := head + Vector2(18.0 * side, 20.0) * scale
			draw_line(whisker_from, head + Vector2(74.0 * side, 6.0) * scale, line, 3.0 * scale)
			draw_line(whisker_from, head + Vector2(78.0 * side, 25.0) * scale, line, 3.0 * scale)

		draw_oval(center + Vector2(-52, 142) * scale, 30.0 * scale, Vector2(1.25, 0.68), fur_light)
		draw_oval(center + Vector2(52, 142) * scale, 30.0 * scale, Vector2(1.25, 0.68), fur_light)

	func draw_oval(center: Vector2, radius: float, scale: Vector2, color: Color) -> void:
		draw_set_transform(center, 0.0, scale)
		draw_circle(Vector2.ZERO, radius, color)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


var stats := {
	"fullness": 76.0,
	"happiness": 72.0,
	"energy": 78.0,
	"cleanliness": 82.0,
	"social": 25.0,
	"curiosity": 34.0,
}
var coins := 12
var level := 1
var xp := 0.0
var sleeping := false
var elapsed_day := 0.18
var save_timer := 0.0
var passive_coin_meter := 0.0
var state_tick_accumulator := 0.0

var backdrop: SkyBackdrop
var cat_view: CatPortrait
var coin_label: Label
var level_label: Label
var time_label: Label
var mood_label: Label
var thought_label: Label
var action_hint_label: Label
var log_label: Label
var sleep_button: Button
var bars := {}
var log_lines: Array[String] = []
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	_load_game()
	_build_ui()
	_update_all()
	_log("欢迎回家，%s已经在门口等你了。" % CAT_NAME)


func _process(delta: float) -> void:
	_tick_stats(delta)
	elapsed_day = fposmod(elapsed_day + delta / 240.0, 1.0)
	save_timer += delta
	if save_timer >= 8.0:
		save_timer = 0.0
		_save_game()
	_update_all()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_game()
		get_tree().quit()


func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop = SkyBackdrop.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 10)
	margin.add_child(page)

	page.add_child(_build_header())

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	page.add_child(body)

	body.add_child(_build_stats_panel())
	body.add_child(_build_cat_panel())

	page.add_child(_build_action_bar())
	page.add_child(_build_log_panel())


func _build_header() -> Control:
	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 54)
	header.add_theme_constant_override("separation", 12)

	var title := Label.new()
	title.text = "云养猫小屋"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#2f2a26"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	time_label = Label.new()
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	time_label.add_theme_font_size_override("font_size", 19)
	time_label.add_theme_color_override("font_color", Color("#3f4856"))
	time_label.custom_minimum_size = Vector2(130, 0)
	header.add_child(time_label)

	level_label = _make_badge("Lv.1")
	header.add_child(level_label)

	var coin_box := HBoxContainer.new()
	coin_box.custom_minimum_size = Vector2(116, 46)
	coin_box.add_theme_constant_override("separation", 8)
	var coin_icon := TextureRect.new()
	coin_icon.texture = ICON_COIN
	coin_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin_icon.custom_minimum_size = Vector2(38, 38)
	coin_box.add_child(coin_icon)
	coin_label = _make_badge("12")
	coin_label.custom_minimum_size = Vector2(62, 42)
	coin_box.add_child(coin_label)
	header.add_child(coin_box)

	return header


func _build_stats_panel() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(270, 0)
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style(Color(0.98, 0.95, 0.87, 0.86), Color("#e3bc78")))

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.add_theme_constant_override("margin_left", 12)
	panel.add_child(box)

	var title := Label.new()
	title.text = "%s的状态" % CAT_NAME
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("#3d2f2a"))
	box.add_child(title)

	_add_stat_row(box, "fullness", "饱食", Color("#f27f63"))
	_add_stat_row(box, "happiness", "开心", Color("#f59bb4"))
	_add_stat_row(box, "energy", "精力", Color("#6d72d9"))
	_add_stat_row(box, "cleanliness", "清洁", Color("#56b6c9"))

	var tip := Label.new()
	tip.text = "照顾得越好，金币来得越快。低状态会让猫咪闹小脾气。"
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.add_theme_font_size_override("font_size", 15)
	tip.add_theme_color_override("font_color", Color("#66564b"))
	tip.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(tip)

	action_hint_label = Label.new()
	action_hint_label.text = ""
	action_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	action_hint_label.add_theme_font_size_override("font_size", 16)
	action_hint_label.add_theme_color_override("font_color", Color("#3d2f2a"))
	box.add_child(action_hint_label)

	return panel


func _build_cat_panel() -> Control:
	var wrap := PanelContainer.new()
	wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	wrap.add_theme_stylebox_override("panel", _style(Color(1, 1, 1, 0.30), Color(1, 1, 1, 0.42)))

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	wrap.add_child(stack)

	mood_label = Label.new()
	mood_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mood_label.add_theme_font_size_override("font_size", 22)
	mood_label.add_theme_color_override("font_color", Color("#2f2a26"))
	stack.add_child(mood_label)

	cat_view = CatPortrait.new()
	cat_view.custom_minimum_size = Vector2(420, 275)
	cat_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cat_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(cat_view)

	thought_label = Label.new()
	thought_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	thought_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	thought_label.add_theme_font_size_override("font_size", 18)
	thought_label.add_theme_color_override("font_color", Color("#3d2f2a"))
	thought_label.custom_minimum_size = Vector2(0, 34)
	stack.add_child(thought_label)

	return wrap


func _build_action_bar() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 72)
	panel.add_theme_stylebox_override("panel", _style(Color(0.98, 0.98, 0.95, 0.88), Color("#d7c6a2")))

	var actions := GridContainer.new()
	actions.columns = 5
	actions.add_theme_constant_override("h_separation", 10)
	actions.add_theme_constant_override("v_separation", 10)
	panel.add_child(actions)

	actions.add_child(_make_action_button("喂食", ICON_FEED, "花 1 金币，让饱食上升。", Callable(self, "_on_feed")))
	actions.add_child(_make_action_button("玩耍", ICON_PLAY, "消耗精力，获得开心和金币。", Callable(self, "_on_play")))
	actions.add_child(_make_action_button("抚摸", ICON_PET, "稳定提升开心，几乎没有副作用。", Callable(self, "_on_pet")))
	actions.add_child(_make_action_button("洗澡", ICON_CLEAN, "恢复清洁，猫咪会稍微不满。", Callable(self, "_on_clean")))
	sleep_button = _make_action_button("睡觉", ICON_SLEEP, "切换睡眠，快速恢复精力。", Callable(self, "_on_sleep"))
	actions.add_child(sleep_button)

	return panel


func _build_log_panel() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 58)
	panel.add_theme_stylebox_override("panel", _style(Color(0.20, 0.18, 0.16, 0.70), Color(1, 1, 1, 0.18)))
	var label := Label.new()
	label.name = "LogLabel"
	log_label = label
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color("#fff7e2"))
	panel.add_child(label)
	return panel


func _add_stat_row(parent: VBoxContainer, id: String, label_text: String, color: Color) -> void:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 2)
	parent.add_child(row)

	var name := Label.new()
	name.text = label_text
	name.add_theme_font_size_override("font_size", 16)
	name.add_theme_color_override("font_color", Color("#3d2f2a"))
	row.add_child(name)

	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 100
	bar.show_percentage = true
	bar.custom_minimum_size = Vector2(0, 20)
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(6)
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", _style(Color(1, 1, 1, 0.62), Color(0, 0, 0, 0)))
	row.add_child(bar)
	bars[id] = bar


func _make_action_button(text: String, icon: Texture2D, tooltip: String, target: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.icon = icon
	button.expand_icon = true
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	button.tooltip_text = tooltip
	button.custom_minimum_size = Vector2(126, 52)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color("#302a25"))
	button.add_theme_stylebox_override("normal", _style(Color("#fff7df"), Color("#d5ab63")))
	button.add_theme_stylebox_override("hover", _style(Color("#ffffff"), Color("#c88f3f")))
	button.add_theme_stylebox_override("pressed", _style(Color("#f0dfbd"), Color("#b57d36")))
	button.pressed.connect(target)
	return button


func _make_badge(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(76, 42)
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color("#302a25"))
	label.add_theme_stylebox_override("normal", _style(Color("#fff7df"), Color("#d5ab63")))
	return label


func _style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _tick_stats(delta: float) -> void:
	# 真实感算法不再每帧扣数值，而是每 60 秒做一次状态结算。
	# 这样猫咪状态更像“缓慢变化的生活节律”，不会因为帧率不同导致体验不同。
	state_tick_accumulator += delta
	if state_tick_accumulator < STATE_TICK_SECONDS:
		return

	var minute_count := int(state_tick_accumulator / STATE_TICK_SECONDS)
	state_tick_accumulator = fmod(state_tick_accumulator, STATE_TICK_SECONDS)
	for i in range(minute_count):
		_apply_realistic_minute()


func _apply_realistic_minute() -> void:
	var behavior_state := _resolved_behavior_state()
	var period_mul := _current_period_multipliers()
	var state_mul := _behavior_state_multipliers(behavior_state)

	if sleeping:
		# 睡眠期间主要恢复精力，其他消耗降到很低；饿到一定程度会自然醒来。
		stats["energy"] = clampf(stats["energy"] + 0.8 * period_mul["energy"], 0.0, 100.0)
		stats["happiness"] = clampf(stats["happiness"] + 0.05, 0.0, 100.0)
		stats["fullness"] = clampf(stats["fullness"] - 0.05 * period_mul["hunger"], 0.0, 100.0)
		stats["social"] = clampf(stats["social"] + 0.03, 0.0, 100.0)
		if stats["energy"] >= 85.0 or stats["fullness"] < 25.0:
			sleeping = false
	else:
		# 旧界面只有一只固定猫，按“橘子”的轻微贪吃/好奇倾向处理。
		stats["fullness"] = clampf(stats["fullness"] - 0.35 * period_mul["hunger"] * 1.25 * state_mul["hunger"], 0.0, 100.0)
		stats["energy"] = clampf(stats["energy"] - 0.25 * period_mul["energy"] * state_mul["energy"], 0.0, 100.0)
		stats["happiness"] = clampf(stats["happiness"] - 0.12 * 0.9 * state_mul["mood"], 0.0, 100.0)
		stats["cleanliness"] = clampf(stats["cleanliness"] - 0.08 * state_mul["clean"], 0.0, 100.0)
		stats["social"] = clampf(stats["social"] + 0.18 * period_mul["social"] * 0.9 * state_mul["social"], 0.0, 100.0)
		stats["curiosity"] = clampf(stats["curiosity"] + 0.15 * period_mul["curiosity"] * 1.2 * state_mul["curiosity"], 0.0, 100.0)

	var care_quality := _average_stat()
	if care_quality >= 72.0 and not sleeping:
		passive_coin_meter += 60.0 * (care_quality / 100.0)
		if passive_coin_meter >= 10.0:
			passive_coin_meter = 0.0
			coins += 1
			xp += 2.0
			_maybe_level_up()


func _on_feed() -> void:
	if sleeping:
		_log("%s睡得正香，先别把饭盆推过去。" % CAT_NAME)
		return
	if coins <= 0:
		_log("金币不够买罐头了。陪%s玩一会儿可以赚回来。" % CAT_NAME)
		return
	coins -= 1
	# 喂食：饱腹大幅恢复；亲近需求会下降一点，清洁略降，模拟吃完饭弄脏毛和饭盆。
	var feed_gain := 26.0 * 1.15
	if stats["fullness"] > 80.0:
		feed_gain = 3.0
	_change_stats({"fullness": feed_gain, "happiness": 5.0, "cleanliness": -1.0, "social": -5.0})
	xp += 4.0
	_cat_react("happy", "%s把饭盆舔得锃亮。-1 金币" % CAT_NAME)


func _on_play() -> void:
	if sleeping:
		_log("%s正在补觉，玩具先放一边。" % CAT_NAME)
		return
	if stats["energy"] < 18.0:
		_cat_react("sad", "%s有点困，玩不动逗猫球了。" % CAT_NAME)
		return
	# 玩耍：消耗精力和饱腹，明显降低好奇心；无聊时玩耍收益更好。
	var mood_gain := 28.0 if _resolved_behavior_state() == "bored" else 18.0
	_change_stats({"happiness": mood_gain, "energy": -18.0, "fullness": -5.0, "cleanliness": -3.0, "curiosity": -20.0})
	coins += 2
	xp += 8.0
	_cat_react("happy", "%s追着毛线球绕了三圈。+2 金币" % CAT_NAME)


func _on_pet() -> void:
	if sleeping:
		_change_stats({"happiness": 4.0, "energy": 4.0})
		_cat_react("cozy", "%s在梦里轻轻打呼噜。" % CAT_NAME)
		return
	# 抚摸：主要满足陪伴需求；越孤单，心情恢复越明显。
	var touch_gain := 19.0 if _resolved_behavior_state() == "lonely" else 14.0
	_change_stats({"happiness": touch_gain, "energy": 3.0, "social": -25.0})
	xp += 3.0
	_cat_react("happy", "%s把脑袋贴到你的手心。" % CAT_NAME)


func _on_clean() -> void:
	if sleeping:
		_log("洗澡会把%s吵醒，还是等它醒来吧。" % CAT_NAME)
		return
	# 清洁：脏的时候收益好且不扣心情；不脏时强行洗澡会让猫有点不满。
	var mood_delta := 0.0 if _resolved_behavior_state() == "dirty" else -5.0
	_change_stats({"cleanliness": 50.0, "happiness": mood_delta, "energy": -4.0})
	xp += 5.0
	_cat_react("cozy", "%s甩了甩水，毛又蓬起来了。" % CAT_NAME)


func _on_sleep() -> void:
	sleeping = not sleeping
	if sleeping:
		_cat_react("cozy", "%s钻进软垫，进入省电模式。" % CAT_NAME)
	else:
		_cat_react("happy", "%s伸了个懒腰，醒来啦。" % CAT_NAME)


func _change_stats(delta_map: Dictionary) -> void:
	for key in delta_map.keys():
		stats[key] = clampf(stats[key] + float(delta_map[key]), 0.0, 100.0)
	_maybe_level_up()


func _cat_react(new_mood: String, message: String) -> void:
	cat_view.mood = new_mood
	cat_view.celebrate()
	_log(message)
	_maybe_level_up()
	_save_game()


func _maybe_level_up() -> void:
	var needed := 24.0 + float(level) * 9.0
	while xp >= needed:
		xp -= needed
		level += 1
		coins += 4
		_log("%s更亲近你了，升到 Lv.%d。+4 金币" % [CAT_NAME, level])
		needed = 24.0 + float(level) * 9.0


func _resolved_behavior_state() -> String:
	# 旧界面的状态优先级与设计文档保持一致，只是把 hunger/mood/clean 映射到旧字段名。
	if stats["fullness"] < 15.0:
		return "very_hungry"
	if sleeping:
		return "sleeping"
	if stats["energy"] < 30.0:
		return "sleepy"
	if stats["cleanliness"] < 35.0:
		return "dirty"
	if stats["fullness"] < 35.0:
		return "hungry"
	if stats["social"] > 70.0:
		return "lonely"
	if stats["happiness"] < 45.0 and stats["curiosity"] > 60.0:
		return "bored"
	if stats["curiosity"] > 75.0 and stats["energy"] > 45.0:
		return "want_go_out"
	if stats["energy"] > 50.0 and stats["happiness"] > 50.0 and stats["curiosity"] > 50.0:
		return "playful"
	if stats["happiness"] > 75.0 and stats["fullness"] > 50.0:
		return "happy"
	return "idle"


func _current_period_multipliers() -> Dictionary:
	# 猫偏晨昏活动：清晨/傍晚更活跃，白天更懒散，夜里温和变化。
	var hour := elapsed_day * 24.0
	if hour >= 5.0 and hour < 8.0:
		return {"hunger": 1.2, "energy": 1.1, "curiosity": 1.3, "social": 1.0}
	if hour >= 8.0 and hour < 16.0:
		return {"hunger": 0.8, "energy": 0.6, "curiosity": 0.7, "social": 0.8}
	if hour >= 16.0 and hour < 22.0:
		return {"hunger": 1.1, "energy": 1.2, "curiosity": 1.2, "social": 1.3}
	return {"hunger": 0.9, "energy": 0.8, "curiosity": 1.0, "social": 0.6}


func _behavior_state_multipliers(state: String) -> Dictionary:
	# 状态倍率表达“当前处境会改变下一分钟的变化速度”，例如饿会更容易掉心情。
	var mul := {"hunger": 1.0, "energy": 1.0, "mood": 1.0, "clean": 1.0, "social": 1.0, "curiosity": 1.0}
	match state:
		"hungry":
			mul["mood"] = 1.5
		"very_hungry":
			mul["mood"] = 2.0
			mul["social"] = 1.4
		"dirty":
			mul["mood"] = 1.35
		"lonely":
			mul["mood"] = 1.35
			mul["social"] = 0.0
		"bored":
			mul["mood"] = 1.2
			mul["curiosity"] = 1.4
		"playful":
			mul["energy"] = 1.2
		"happy":
			mul["mood"] = 0.6
	return mul


func _update_all() -> void:
	for key in bars.keys():
		bars[key].value = stats[key]
	coin_label.text = str(coins)
	level_label.text = "Lv.%d" % level
	time_label.text = _time_text()
	backdrop.night_amount = _night_amount()
	backdrop.queue_redraw()

	var mood := _current_mood()
	cat_view.sleeping = sleeping
	if not sleeping:
		cat_view.mood = mood
	mood_label.text = _mood_title(mood)
	thought_label.text = _thought_text(mood)
	action_hint_label.text = _hint_text()
	if is_instance_valid(sleep_button):
		sleep_button.text = "叫醒" if sleeping else "睡觉"

	if log_label != null:
		log_label.text = "\n".join(log_lines)


func _current_mood() -> String:
	var behavior_state := _resolved_behavior_state()
	if behavior_state == "sleeping":
		return "sleep"
	if behavior_state in ["very_hungry", "sleepy", "dirty", "hungry", "lonely", "bored"]:
		return "sad"
	if behavior_state in ["happy", "playful"]:
		return "happy"
	return "cozy"


func _mood_title(mood: String) -> String:
	match mood:
		"sleep":
			return "%s正在睡觉" % CAT_NAME
		"happy":
			return "%s今天很黏人" % CAT_NAME
		"sad":
			return "%s需要照顾" % CAT_NAME
		_:
			return "%s在小屋里放松" % CAT_NAME


func _thought_text(mood: String) -> String:
	match mood:
		"sleep":
			return "Zzz... 精力正在恢复。"
		"happy":
			return "喵。这个家可以续住。"
		"sad":
			if stats["fullness"] < 22.0:
				return "饭盆空空，猫猫心里也空空。"
			if stats["energy"] < 16.0:
				return "眼皮开始打架了。"
			if stats["social"] > 70.0:
				return "它在门口绕了一圈，像是在等你。"
			if stats["curiosity"] > 75.0:
				return "它一直看着门口，可能想探索。"
			return "毛毛有点乱，需要清洁。"
		_:
			return "窗台不错，阳光也不错。"


func _hint_text() -> String:
	if stats["social"] > 70.0:
		return "推荐：抚摸。亲近需求高时，陪伴的收益更好。"
	if stats["curiosity"] > 75.0 and stats["energy"] > 45.0:
		return "推荐：玩耍或外出。好奇心高时，它会想探索新东西。"
	if stats["fullness"] < 35.0:
		return "推荐：喂食。饱食太低会让开心下降更快。"
	if stats["cleanliness"] < 35.0:
		return "推荐：洗澡。清洁度太低时，%s会开始嫌弃地板。" % CAT_NAME
	if stats["energy"] < 30.0:
		return "推荐：睡觉。精力恢复后再玩，收益更好。"
	if stats["happiness"] < 45.0:
		return "推荐：抚摸或玩耍。开心会影响金币产出。"
	return "状态不错。维持照顾，金币会慢慢增加。"


func _time_text() -> String:
	var hour := int(elapsed_day * 24.0)
	if hour < 6:
		return "凌晨 %02d:00" % hour
	if hour < 12:
		return "上午 %02d:00" % hour
	if hour < 18:
		return "下午 %02d:00" % hour
	return "夜晚 %02d:00" % hour


func _night_amount() -> float:
	var hour := elapsed_day * 24.0
	if hour >= 19.0:
		return clampf((hour - 19.0) / 4.0, 0.0, 1.0)
	if hour < 6.0:
		return clampf(1.0 - (hour / 6.0), 0.0, 1.0)
	return 0.0


func _average_stat() -> float:
	return (stats["fullness"] + stats["happiness"] + stats["energy"] + stats["cleanliness"]) / 4.0


func _log(message: String) -> void:
	log_lines.push_front(message)
	while log_lines.size() > 3:
		log_lines.pop_back()


func _save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("cat", "fullness", stats["fullness"])
	cfg.set_value("cat", "happiness", stats["happiness"])
	cfg.set_value("cat", "energy", stats["energy"])
	cfg.set_value("cat", "cleanliness", stats["cleanliness"])
	cfg.set_value("cat", "social", stats["social"])
	cfg.set_value("cat", "curiosity", stats["curiosity"])
	cfg.set_value("cat", "coins", coins)
	cfg.set_value("cat", "level", level)
	cfg.set_value("cat", "xp", xp)
	cfg.set_value("cat", "sleeping", sleeping)
	cfg.set_value("world", "elapsed_day", elapsed_day)
	cfg.save(SAVE_PATH)


func _load_game() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	stats["fullness"] = float(cfg.get_value("cat", "fullness", stats["fullness"]))
	stats["happiness"] = float(cfg.get_value("cat", "happiness", stats["happiness"]))
	stats["energy"] = float(cfg.get_value("cat", "energy", stats["energy"]))
	stats["cleanliness"] = float(cfg.get_value("cat", "cleanliness", stats["cleanliness"]))
	stats["social"] = float(cfg.get_value("cat", "social", stats["social"]))
	stats["curiosity"] = float(cfg.get_value("cat", "curiosity", stats["curiosity"]))
	coins = int(cfg.get_value("cat", "coins", coins))
	level = int(cfg.get_value("cat", "level", level))
	xp = float(cfg.get_value("cat", "xp", xp))
	sleeping = bool(cfg.get_value("cat", "sleeping", sleeping))
	elapsed_day = float(cfg.get_value("world", "elapsed_day", elapsed_day))
