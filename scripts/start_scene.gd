extends Control

var desc_label: Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	if GameData.load_game():
		get_tree().change_scene_to_file.call_deferred("res://scenes/MainScene.tscn")
		return

	_build_ui()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color("#f8efe3")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var page := VBoxContainer.new()
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	page.offset_left = 28
	page.offset_right = -28
	page.offset_top = 58
	page.offset_bottom = -42
	page.add_theme_constant_override("separation", 18)
	add_child(page)

	var title := Label.new()
	title.text = "云养猫小屋"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 46)
	title.add_theme_color_override("font_color", Color("#332820"))
	page.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "选择一只猫咪，开始今天的小屋生活"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 22)
	subtitle.add_theme_color_override("font_color", Color("#6d5b4c"))
	page.add_child(subtitle)

	var cat_list := VBoxContainer.new()
	cat_list.name = "CatList"
	cat_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cat_list.add_theme_constant_override("separation", 14)
	page.add_child(cat_list)

	_add_cat_button(cat_list, "orange", Color("#f4a259"))
	_add_cat_button(cat_list, "calico", Color("#fff7eb"))
	_add_cat_button(cat_list, "gray", Color("#9ea4ad"))

	desc_label = Label.new()
	desc_label.name = "DescLabel"
	desc_label.text = "第一次见面，要好好选。"
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size = Vector2(0, 54)
	desc_label.add_theme_font_size_override("font_size", 19)
	desc_label.add_theme_color_override("font_color", Color("#49372d"))
	page.add_child(desc_label)


func _add_cat_button(parent: VBoxContainer, cat_id: String, color: Color) -> void:
	var cat: Dictionary = GameData.cats[cat_id]
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style(Color("#fffdf7"), Color("#dec49b")))
	parent.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)

	var portrait := CatChip.new()
	portrait.cat_id = cat_id
	portrait.base_color = color
	portrait.custom_minimum_size = Vector2(0, 100)
	portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(portrait)

	var name_label := Label.new()
	name_label.text = "%s · %s" % [cat["name"], cat["type"]]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 24)
	name_label.add_theme_color_override("font_color", Color("#332820"))
	box.add_child(name_label)

	var desc := Label.new()
	desc.text = "%s · %s" % [cat["personality"], cat["desc"]]
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 16)
	desc.add_theme_color_override("font_color", Color("#6d5b4c"))
	desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(desc)

	var button := Button.new()
	button.text = "领养%s" % cat["name"]
	button.custom_minimum_size = Vector2(0, 54)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_stylebox_override("normal", _style(Color("#ffe5b4"), Color("#c98a3a")))
	button.add_theme_stylebox_override("hover", _style(Color("#fff2cc"), Color("#bd7b27")))
	button.pressed.connect(func() -> void: select_cat(cat_id))
	button.mouse_entered.connect(func() -> void: desc_label.text = cat["desc"])
	box.add_child(button)


func select_cat(cat_id: String) -> void:
	GameData.adopt_cat(cat_id)
	get_tree().change_scene_to_file("res://scenes/MainScene.tscn")


func _style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	return style


class CatChip:
	extends Control

	var cat_id := "orange"
	var base_color := Color("#f4a259")

	func _draw() -> void:
		var center := Vector2(size.x * 0.5, size.y * 0.58)
		var radius := minf(size.x, size.y) * 0.28
		draw_circle(center, radius, base_color)
		draw_polygon(PackedVector2Array([
			center + Vector2(-radius * 0.9, -radius * 0.45),
			center + Vector2(-radius * 0.48, -radius * 1.26),
			center + Vector2(-radius * 0.12, -radius * 0.52)
		]), PackedColorArray([base_color, base_color, base_color]))
		draw_polygon(PackedVector2Array([
			center + Vector2(radius * 0.9, -radius * 0.45),
			center + Vector2(radius * 0.48, -radius * 1.26),
			center + Vector2(radius * 0.12, -radius * 0.52)
		]), PackedColorArray([base_color, base_color, base_color]))

		if cat_id == "calico":
			draw_circle(center + Vector2(-radius * 0.35, -radius * 0.28), radius * 0.34, Color("#f0a044"))
			draw_circle(center + Vector2(radius * 0.32, -radius * 0.08), radius * 0.26, Color("#4d4038"))
		elif cat_id == "orange":
			for x in [-0.45, 0.0, 0.45]:
				draw_line(center + Vector2(radius * x, -radius * 0.88), center + Vector2(radius * x * 0.45, -radius * 0.38), Color("#c46d28"), 5.0)

		var line := Color("#2f2924")
		draw_circle(center + Vector2(-radius * 0.33, -radius * 0.04), 4.0, line)
		draw_circle(center + Vector2(radius * 0.33, -radius * 0.04), 4.0, line)
		draw_circle(center + Vector2(0, radius * 0.16), 4.0, Color("#74433d"))
		draw_arc(center + Vector2(-6, radius * 0.28), 8.0, 0.1, PI - 0.1, 14, line, 2.5)
		draw_arc(center + Vector2(6, radius * 0.28), 8.0, 0.1, PI - 0.1, 14, line, 2.5)
