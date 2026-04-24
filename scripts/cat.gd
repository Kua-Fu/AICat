extends Node2D

const CatSpriteScene := preload("res://scenes/cat/CatSprite.tscn")

var action_lock := false
var current_anim := "idle"
var leave_offset := 0.0
var cat_sprite


func _ready() -> void:
	_ensure_cat_sprite()
	refresh_visual_state()


func _process(delta: float) -> void:
	if GameData.is_outside:
		visible = false
		return

	visible = true
	if current_anim == "leave":
		leave_offset = minf(leave_offset + delta * 430.0, 680.0)
	else:
		leave_offset = lerpf(leave_offset, 0.0, delta * 8.0)

	if cat_sprite != null:
		cat_sprite.position.x = leave_offset

	if not action_lock:
		refresh_visual_state()


func refresh_visual_state() -> void:
	var state := GameData.resolve_state()
	if state in ["sleeping", "sleepy"]:
		play_anim("sleep")
	elif state in ["very_hungry", "hungry", "dirty"]:
		play_anim("sad")
	else:
		play_anim("idle")


func play_anim(name: String) -> void:
	if current_anim == name:
		return

	current_anim = name
	if cat_sprite != null:
		cat_sprite.play_anim(name)


func feed() -> Dictionary:
	if GameData.is_outside:
		return {"ok": false, "message": ""}

	action_lock = true
	play_anim("eat")
	var result: Dictionary = GameData.feed()

	await get_tree().create_timer(1.2).timeout
	play_anim("idle")
	await get_tree().create_timer(0.5).timeout
	action_lock = false
	refresh_visual_state()
	return result


func touch_cat() -> Dictionary:
	if GameData.is_outside:
		return {"ok": false, "message": ""}

	action_lock = true
	play_anim("pet")
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
	play_anim("play")
	await get_tree().create_timer(1.2).timeout
	action_lock = false
	refresh_visual_state()
	return result


func clean_cat() -> Dictionary:
	if GameData.is_outside:
		return {"ok": false, "message": ""}

	action_lock = true
	play_anim("bath")
	var result: Dictionary = GameData.clean_cat()

	await get_tree().create_timer(1.1).timeout
	action_lock = false
	refresh_visual_state()
	return result


func play_wake() -> void:
	action_lock = true
	play_anim("wake")
	await get_tree().create_timer(0.7).timeout
	action_lock = false
	refresh_visual_state()


func leave_home() -> void:
	if GameData.is_outside:
		return

	action_lock = true
	play_anim("leave")
	await get_tree().create_timer(1.2).timeout
	action_lock = false


func _ensure_cat_sprite() -> void:
	cat_sprite = get_node_or_null("Visual")
	if cat_sprite != null:
		return

	cat_sprite = CatSpriteScene.instantiate()
	cat_sprite.name = "Visual"
	add_child(cat_sprite)
