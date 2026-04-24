class_name StatusPanel
extends PanelContainer

const UiTheme := preload("res://scripts/ui/ui_theme_helper.gd")
const StatusCardScene := preload("res://scripts/ui/status_card.gd")

var cards := {}


func _ready() -> void:
	if get_child_count() == 0:
		_build()


func update_values(hunger: float, mood: float, energy: float, clean: float) -> void:
	if cards.is_empty():
		_build()

	cards["hunger"].update_value(hunger)
	cards["mood"].update_value(mood)
	cards["energy"].update_value(energy)
	cards["clean"].update_value(clean)


func _build() -> void:
	custom_minimum_size = Vector2(0, 260)
	add_theme_stylebox_override("panel", UiTheme.make_panel_style(UiTheme.COLOR_PANEL_LIGHT, 28, UiTheme.COLOR_BORDER, 3, 5))

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	add_child(grid)

	_add_status_card(grid, "hunger", "饱食", "hunger", UiTheme.COLOR_HUNGER, Color("#ffe9dc"))
	_add_status_card(grid, "mood", "开心", "mood", UiTheme.COLOR_HAPPY, Color("#ffe8f0"))
	_add_status_card(grid, "energy", "精力", "energy", UiTheme.COLOR_ENERGY, Color("#eeeaff"))
	_add_status_card(grid, "clean", "清洁", "clean", UiTheme.COLOR_CLEAN, Color("#e7fbff"))


func _add_status_card(parent: GridContainer, id: String, title: String, icon_kind: String, color: Color, bg: Color) -> void:
	var card = StatusCardScene.new()
	card.setup(title, icon_kind, color, bg)
	parent.add_child(card)
	cards[id] = card
