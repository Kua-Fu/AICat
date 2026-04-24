class_name RoomBackdrop
extends Control

const WALL_NIGHT := preload("res://assets/room/room_wall_night.png")
const FLOOR := preload("res://assets/room/room_floor.png")
const RUG := preload("res://assets/room/rug_soft.png")
const BED_SLEEP := preload("res://assets/room/cat_bed_sleep.png")
const SCRATCHER := preload("res://assets/room/scratcher.png")
const FOOD_BOWL := preload("res://assets/room/food_bowl.png")
const YARN_BALL := preload("res://assets/room/yarn_ball.png")
const PLANT := preload("res://assets/room/plant.png")

var night_amount := 0.0


func _draw() -> void:
	_draw_cover(WALL_NIGHT, Rect2(Vector2.ZERO, size), _wall_tint())

	var floor_y := size.y * 0.54
	draw_texture_rect(FLOOR, Rect2(0, floor_y, size.x, size.y - floor_y), false, Color(1, 1, 1, 0.96))

	_draw_centered(RUG, Vector2(size.x * 0.50, size.y * 0.61), size.x * 0.86)
	_draw_centered(BED_SLEEP, Vector2(size.x * 0.50, size.y * 0.54), size.x * 0.46, Color(1, 1, 1, 0.96))
	_draw_centered(SCRATCHER, Vector2(size.x * 0.14, size.y * 0.45), size.x * 0.26)
	_draw_centered(PLANT, Vector2(size.x * 0.79, size.y * 0.39), size.x * 0.22)
	_draw_centered(YARN_BALL, Vector2(size.x * 0.16, size.y * 0.72), size.x * 0.16)
	_draw_centered(FOOD_BOWL, Vector2(size.x * 0.82, size.y * 0.72), size.x * 0.20)


func _draw_cover(texture: Texture2D, rect: Rect2, modulate: Color = Color.WHITE) -> void:
	var texture_size := texture.get_size()
	var scale := maxf(rect.size.x / texture_size.x, rect.size.y / texture_size.y)
	var draw_size := texture_size * scale
	var draw_pos := rect.position + (rect.size - draw_size) * 0.5
	draw_texture_rect(texture, Rect2(draw_pos, draw_size), false, modulate)


func _draw_centered(texture: Texture2D, center: Vector2, width: float, modulate: Color = Color.WHITE) -> void:
	var texture_size := texture.get_size()
	var draw_size := Vector2(width, width * texture_size.y / texture_size.x)
	draw_texture_rect(texture, Rect2(center - draw_size * 0.5, draw_size), false, modulate)


func _wall_tint() -> Color:
	return Color(1.07, 1.03, 0.94, 1.0).lerp(Color(0.83, 0.86, 1.0, 1.0), night_amount)
