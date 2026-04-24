extends Node2D

var action_lock := false
var current_anim := "idle"
var anim_time := 0.0
var leave_offset := 0.0
var draw_origin := Vector2.ZERO
var draw_scale := 1.0


func _ready() -> void:
	refresh_visual_state()


func _process(delta: float) -> void:
	anim_time += delta
	if GameData.is_outside:
		visible = false
		return

	visible = true

	if current_anim == "leave":
		leave_offset = minf(leave_offset + delta * 430.0, 680.0)
	else:
		leave_offset = lerpf(leave_offset, 0.0, delta * 8.0)

	if not action_lock:
		refresh_visual_state()

	queue_redraw()


func _draw() -> void:
	draw_origin = Vector2(leave_offset, _bob_offset())
	draw_scale = _anim_scale()
	draw_set_transform(draw_origin, 0.0, Vector2(draw_scale, draw_scale))
	if current_anim == "sleep":
		_draw_sleeping_cat()
	else:
		_draw_shadow()
		_draw_body()
		_draw_head()
	_draw_effects()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func refresh_visual_state() -> void:
	var state := GameData.resolve_state()
	if state in ["sleeping", "sleepy"]:
		play_anim("sleep")
	elif state in ["very_hungry", "hungry"]:
		play_anim("hungry")
	elif state == "dirty":
		play_anim("dirty")
	elif state in ["happy", "playful", "want_go_out"]:
		play_anim("happy")
	else:
		play_anim("idle")


func play_anim(name: String) -> void:
	if current_anim != name:
		current_anim = name
		anim_time = 0.0
		queue_redraw()


func feed() -> Dictionary:
	if GameData.is_outside:
		return {"ok": false, "message": ""}

	action_lock = true
	play_anim("eat")
	var result: Dictionary = GameData.feed()

	await get_tree().create_timer(1.2).timeout
	play_anim("happy")
	await get_tree().create_timer(0.8).timeout
	action_lock = false
	refresh_visual_state()
	return result


func touch_cat() -> Dictionary:
	if GameData.is_outside:
		return {"ok": false, "message": ""}

	action_lock = true
	play_anim("touch")
	var result: Dictionary = GameData.touch_cat()

	await get_tree().create_timer(1.2).timeout
	action_lock = false
	refresh_visual_state()
	return result


func play_cat() -> Dictionary:
	if GameData.is_outside:
		return {"ok": false, "message": ""}

	var result := GameData.play()
	if not bool(result.get("ok", false)):
		return result

	action_lock = true
	play_anim("happy")
	await get_tree().create_timer(1.2).timeout
	action_lock = false
	refresh_visual_state()
	return result


func clean_cat() -> Dictionary:
	if GameData.is_outside:
		return {"ok": false, "message": ""}

	action_lock = true
	play_anim("happy")
	var result: Dictionary = GameData.clean_cat()

	await get_tree().create_timer(1.1).timeout
	action_lock = false
	refresh_visual_state()
	return result


func leave_home() -> void:
	if GameData.is_outside:
		return

	action_lock = true
	play_anim("leave")
	await get_tree().create_timer(1.2).timeout
	action_lock = false


func _base_color() -> Color:
	match GameData.selected_cat_id:
		"gray":
			return Color("#9da4ad")
		"calico":
			return Color("#fff8e9")
		_:
			return Color("#f4a259")


func _stripe_color() -> Color:
	match GameData.selected_cat_id:
		"gray":
			return Color("#6f7680")
		"calico":
			return Color("#4a403a")
		_:
			return Color("#c46d28")


func _bob_offset() -> float:
	if current_anim == "sleep":
		return 20.0 + sin(anim_time * 2.0) * 2.0
	if current_anim == "happy":
		return -absf(sin(anim_time * 8.0)) * 26.0
	if current_anim == "eat":
		return sin(anim_time * 24.0) * 4.0
	if current_anim == "hungry":
		return 14.0
	return sin(anim_time * 3.0) * 4.0


func _anim_scale() -> float:
	if current_anim == "sleep":
		return 0.92
	if current_anim == "touch":
		return 1.03 + sin(anim_time * 10.0) * 0.02
	return 1.0


func _draw_shadow() -> void:
	draw_oval(Vector2(0, 145), 95.0, Vector2(1.5, 0.32), Color(0, 0, 0, 0.14))


func _draw_sleeping_cat() -> void:
	var fur := _base_color()
	var dark := _stripe_color()
	var fur_light := Color("#ffe0b7").lerp(fur, 0.25)
	var line := Color("#302822")

	draw_oval(Vector2(8, 146), 112.0, Vector2(1.72, 0.30), Color(0, 0, 0, 0.14))
	draw_oval(Vector2(38, 72), 116.0, Vector2(1.22, 0.82), fur)
	draw_oval(Vector2(44, 82), 74.0, Vector2(1.28, 0.58), fur.lightened(0.08))

	draw_arc(Vector2(72, 70), 92.0, -1.45, 2.05, 52, dark, 24.0)
	draw_arc(Vector2(72, 70), 70.0, -1.45, 2.00, 52, fur, 18.0)
	for angle in [-0.86, -0.35, 0.16, 0.64]:
		var a := Vector2(72, 70) + Vector2(cos(angle), sin(angle)) * 88.0
		var b := Vector2(72, 70) + Vector2(cos(angle), sin(angle)) * 112.0
		draw_line(a, b, dark, 7.0)

	var head := Vector2(-82, 28)
	draw_polygon(PackedVector2Array([head + Vector2(-70, -20), head + Vector2(-42, -92), head + Vector2(-10, -26)]), PackedColorArray([fur, fur, fur]))
	draw_polygon(PackedVector2Array([head + Vector2(70, -20), head + Vector2(38, -92), head + Vector2(10, -26)]), PackedColorArray([fur, fur, fur]))
	draw_polygon(PackedVector2Array([head + Vector2(-48, -32), head + Vector2(-38, -62), head + Vector2(-22, -30)]), PackedColorArray([Color("#ffcfa0"), Color("#ffcfa0"), Color("#ffcfa0")]))
	draw_polygon(PackedVector2Array([head + Vector2(48, -32), head + Vector2(36, -62), head + Vector2(22, -30)]), PackedColorArray([Color("#ffcfa0"), Color("#ffcfa0"), Color("#ffcfa0")]))
	draw_oval(head, 78.0, Vector2(1.08, 0.88), fur)

	if GameData.selected_cat_id == "calico":
		draw_circle(head + Vector2(-28, -30), 28.0, Color("#efa04c"))
		draw_circle(head + Vector2(32, -18), 23.0, Color("#463d37"))
	else:
		for x in [-30.0, 0.0, 30.0]:
			draw_line(head + Vector2(x, -70), head + Vector2(x * 0.42, -34), dark, 7.0)

	draw_oval(head + Vector2(0, 17), 44.0, Vector2(1.18, 0.66), fur_light)
	draw_arc(head + Vector2(-30, -8), 14.0, 0.1, PI - 0.1, 18, line, 4.0)
	draw_arc(head + Vector2(30, -8), 14.0, 0.1, PI - 0.1, 18, line, 4.0)
	draw_circle(head + Vector2(0, 17), 6.0, Color("#70413b"))
	draw_arc(head + Vector2(-8, 29), 10.0, 0.0, PI, 14, line, 3.4)
	draw_arc(head + Vector2(8, 29), 10.0, 0.0, PI, 14, line, 3.4)
	draw_oval(head + Vector2(-45, 17), 12.0, Vector2(1.35, 0.70), Color(1.0, 0.45, 0.50, 0.44))
	draw_oval(head + Vector2(45, 17), 12.0, Vector2(1.35, 0.70), Color(1.0, 0.45, 0.50, 0.44))

	for side in [-1.0, 1.0]:
		var start := head + Vector2(15.0 * side, 18.0)
		draw_line(start, head + Vector2(68.0 * side, 6.0), line, 2.5)
		draw_line(start, head + Vector2(70.0 * side, 24.0), line, 2.5)

	draw_oval(Vector2(-42, 126), 25.0, Vector2(1.25, 0.62), fur_light)
	draw_oval(Vector2(12, 130), 24.0, Vector2(1.22, 0.60), fur_light)


func _draw_body() -> void:
	var fur := _base_color()
	var dark := _stripe_color()
	var body_y := 55.0 if current_anim != "sleep" else 82.0
	draw_oval(Vector2(0, body_y), 98.0, Vector2(1.1, 0.86), fur)
	draw_arc(Vector2(90, body_y - 12.0), 58.0, -1.6, 1.55, 36, dark, 22.0)
	draw_arc(Vector2(88, body_y - 12.0), 38.0, -1.5, 1.22, 28, fur, 17.0)
	draw_oval(Vector2(-45, body_y + 68), 25.0, Vector2(1.3, 0.62), Color("#ffe0b7").lerp(fur, 0.35))
	draw_oval(Vector2(45, body_y + 68), 25.0, Vector2(1.3, 0.62), Color("#ffe0b7").lerp(fur, 0.35))


func _draw_head() -> void:
	var fur := _base_color()
	var dark := _stripe_color()
	var line := Color("#302822")
	var head := Vector2(0, -40)
	if current_anim == "sleep":
		head = Vector2(-18, 25)
	elif current_anim == "hungry":
		head.y = -22

	draw_polygon(PackedVector2Array([head + Vector2(-76, -28), head + Vector2(-42, -108), head + Vector2(-12, -31)]), PackedColorArray([fur, fur, fur]))
	draw_polygon(PackedVector2Array([head + Vector2(76, -28), head + Vector2(42, -108), head + Vector2(12, -31)]), PackedColorArray([fur, fur, fur]))
	draw_polygon(PackedVector2Array([head + Vector2(-54, -43), head + Vector2(-42, -76), head + Vector2(-26, -41)]), PackedColorArray([Color("#ffcfa0"), Color("#ffcfa0"), Color("#ffcfa0")]))
	draw_polygon(PackedVector2Array([head + Vector2(54, -43), head + Vector2(42, -76), head + Vector2(26, -41)]), PackedColorArray([Color("#ffcfa0"), Color("#ffcfa0"), Color("#ffcfa0")]))
	draw_oval(head, 86.0, Vector2(1.05, 0.9), fur)

	if GameData.selected_cat_id == "calico":
		draw_circle(head + Vector2(-30, -34), 30.0, Color("#efa04c"))
		draw_circle(head + Vector2(34, -20), 25.0, Color("#463d37"))
	else:
		for x in [-32.0, 0.0, 32.0]:
			draw_line(head + Vector2(x, -78), head + Vector2(x * 0.42, -38), dark, 7.0)

	draw_oval(head + Vector2(0, 15), 48.0, Vector2(1.18, 0.68), Color("#ffe0b7").lerp(fur, 0.3))

	var left_eye := head + Vector2(-33, -10)
	var right_eye := head + Vector2(33, -10)
	if current_anim in ["sleep", "touch", "happy"]:
		draw_arc(left_eye, 15.0, 0.05, PI - 0.05, 18, line, 4.0)
		draw_arc(right_eye, 15.0, 0.05, PI - 0.05, 18, line, 4.0)
	else:
		draw_oval(left_eye, 9.0, Vector2(0.8, 1.16), line)
		draw_oval(right_eye, 9.0, Vector2(0.8, 1.16), line)

	draw_circle(head + Vector2(0, 18), 6.0, Color("#70413b"))
	if current_anim == "hungry":
		draw_arc(head + Vector2(0, 49), 16.0, PI + 0.15, TAU - 0.15, 18, line, 4.0)
	else:
		draw_arc(head + Vector2(-8, 30), 10.0, 0.0, PI, 14, line, 3.5)
		draw_arc(head + Vector2(8, 30), 10.0, 0.0, PI, 14, line, 3.5)

	for side in [-1.0, 1.0]:
		var start := head + Vector2(16.0 * side, 19.0)
		draw_line(start, head + Vector2(72.0 * side, 8.0), line, 2.5)
		draw_line(start, head + Vector2(76.0 * side, 25.0), line, 2.5)


func _draw_effects() -> void:
	if current_anim == "dirty":
		for point in [Vector2(-70, -70), Vector2(76, -24), Vector2(-54, 44), Vector2(38, 66)]:
			draw_circle(point, 8.0, Color(0.25, 0.25, 0.25, 0.32))
	if current_anim == "sleep":
		draw_string(ThemeDB.fallback_font, Vector2(72, -104), "Zzz", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#5f6572"))
	if current_anim == "eat":
		draw_oval(Vector2(-120, 122), 28.0, Vector2(1.45, 0.42), Color("#9b6a48"))
		draw_circle(Vector2(-120, 110), 14.0, Color("#f7c46a"))


func draw_oval(center: Vector2, radius: float, oval_scale: Vector2, color: Color) -> void:
	draw_set_transform(draw_origin + center * draw_scale, 0.0, oval_scale * draw_scale)
	draw_circle(Vector2.ZERO, radius, color)
	draw_set_transform(draw_origin, 0.0, Vector2(draw_scale, draw_scale))
