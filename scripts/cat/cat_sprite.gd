class_name CatSprite
extends Node2D

const CAT_IDLE_01 := preload("res://assets/cat/cat_idle_01.png")
const CAT_IDLE_02 := preload("res://assets/cat/cat_idle_02.png")
const CAT_SLEEP_01 := preload("res://assets/cat/cat_sleep_01.png")
const CAT_SLEEP_02 := preload("res://assets/cat/cat_sleep_02.png")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shadow: Polygon2D = $Shadow
@onready var zzz_effect: Label = $ZzzEffect
@onready var emotion_effect: Label = $EmotionEffect

var current_anim := "idle"
var anim_time := 0.0
var base_scale := 0.42


func _ready() -> void:
	_setup_frames()
	_setup_shadow()
	play_anim("idle")


func _process(delta: float) -> void:
	anim_time += delta
	_update_pose()
	_update_effects()


func play_anim(anim_name: String) -> void:
	current_anim = anim_name
	anim_time = 0.0

	var frame_anim := "sleep" if anim_name == "sleep" else "idle"
	if animated_sprite.animation != frame_anim:
		animated_sprite.play(frame_anim)
	animated_sprite.speed_scale = 0.82 if frame_anim == "sleep" else 1.0
	_update_effects()


func _setup_frames() -> void:
	var frames := SpriteFrames.new()
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 2.0)
	frames.add_frame("idle", CAT_IDLE_01)
	frames.add_frame("idle", CAT_IDLE_02)

	frames.add_animation("sleep")
	frames.set_animation_loop("sleep", true)
	frames.set_animation_speed("sleep", 1.6)
	frames.add_frame("sleep", CAT_SLEEP_01)
	frames.add_frame("sleep", CAT_SLEEP_02)

	animated_sprite.sprite_frames = frames
	animated_sprite.centered = true


func _setup_shadow() -> void:
	var points := PackedVector2Array()
	for i in range(36):
		var angle := TAU * float(i) / 36.0
		points.append(Vector2(cos(angle) * 124.0, sin(angle) * 30.0))
	shadow.polygon = points
	shadow.position = Vector2(0, 158)
	shadow.color = Color(0, 0, 0, 0.16)


func _update_pose() -> void:
	var bob := _bob_offset()
	var squash := _squash_scale()
	animated_sprite.position = Vector2(0, bob)
	animated_sprite.scale = Vector2(base_scale * squash.x, base_scale * squash.y)
	animated_sprite.rotation = _rotation_amount()

	shadow.scale = Vector2(_shadow_scale(), 1.0)
	shadow.modulate.a = 0.12 if current_anim == "sleep" else 0.16


func _update_effects() -> void:
	zzz_effect.visible = current_anim == "sleep"
	zzz_effect.position = Vector2(92, -250 + sin(anim_time * 2.2) * 8.0)
	zzz_effect.modulate.a = 0.62 + sin(anim_time * 2.2) * 0.22

	match current_anim:
		"eat":
			_show_emotion("鱼", Vector2(-150, 88), Color("#f7a84e"))
		"pet":
			_show_emotion("♡", Vector2(120, -168), Color("#f4939d"))
		"play":
			_show_emotion("!", Vector2(118, -184), Color("#ffd35b"))
		"bath":
			_show_emotion("✦", Vector2(-138, -130), Color("#68bd8a"))
		"wake":
			_show_emotion("♪", Vector2(118, -170), Color("#9c6ce8"))
		"sad":
			_show_emotion("…", Vector2(118, -170), Color("#7e6754"))
		_:
			emotion_effect.visible = false


func _show_emotion(text: String, pos: Vector2, color: Color) -> void:
	emotion_effect.visible = true
	emotion_effect.text = text
	emotion_effect.position = pos + Vector2(0, -absf(sin(anim_time * 5.0)) * 12.0)
	emotion_effect.modulate = color


func _bob_offset() -> float:
	match current_anim:
		"sleep":
			return 14.0 + sin(anim_time * 1.8) * 2.5
		"play":
			return -absf(sin(anim_time * 8.0)) * 24.0
		"eat":
			return sin(anim_time * 18.0) * 5.0
		"pet":
			return sin(anim_time * 8.0) * 3.0
		"sad":
			return 16.0
		_:
			return sin(anim_time * 2.4) * 4.0


func _squash_scale() -> Vector2:
	match current_anim:
		"sleep":
			return Vector2(1.05, 0.97)
		"pet":
			return Vector2(1.03 + sin(anim_time * 8.0) * 0.02, 1.0)
		"play":
			return Vector2(1.0, 1.0 + absf(sin(anim_time * 8.0)) * 0.04)
		_:
			return Vector2.ONE


func _rotation_amount() -> float:
	if current_anim == "play":
		return sin(anim_time * 7.5) * 0.045
	if current_anim == "wake":
		return sin(anim_time * 6.0) * 0.028
	return 0.0


func _shadow_scale() -> float:
	if current_anim == "play":
		return 0.88 + absf(sin(anim_time * 8.0)) * 0.18
	if current_anim == "sleep":
		return 1.16
	return 1.0
