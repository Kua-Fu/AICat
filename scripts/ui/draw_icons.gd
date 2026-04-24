class_name UIDrawIcons
extends RefCounted


static func sparkle_points(center: Vector2, radius: float, pinch: float = 0.28) -> PackedVector2Array:
	return PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius * pinch, -radius * pinch),
		center + Vector2(radius, 0),
		center + Vector2(radius * pinch, radius * pinch),
		center + Vector2(0, radius),
		center + Vector2(-radius * pinch, radius * pinch),
		center + Vector2(-radius, 0),
		center + Vector2(-radius * pinch, -radius * pinch)
	])


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
		draw_polygon(UIDrawIcons.sparkle_points(c, r), PackedColorArray([tint, tint, tint, tint, tint, tint, tint, tint]))
		draw_circle(c + Vector2(r * 0.84, -r * 0.72), r * 0.13, tint.lightened(0.15))


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

	func _draw_bowl(c: Vector2, _r: float) -> void:
		draw_oval(c + Vector2(0, 11), 27.0, Vector2(1.28, 0.48), Color("#f16a43"))
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

	func _draw_bolt(c: Vector2, _r: float) -> void:
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

	func _draw_drop(c: Vector2, _r: float) -> void:
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
