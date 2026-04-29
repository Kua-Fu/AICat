class_name StatusPanel
extends PanelContainer

const UiTheme := preload("res://scripts/ui/ui_theme_helper.gd")
const StatusCardScene := preload("res://scripts/ui/status_card.gd")
const ICON_STATUS_HUNGER := preload("res://assets/icons/status/status_hunger.png")
const ICON_STATUS_MOOD := preload("res://assets/icons/status/status_mood.png")
const ICON_STATUS_ENERGY := preload("res://assets/icons/status/status_energy.png")
const ICON_STATUS_CLEAN := preload("res://assets/icons/status/status_clean.png")
const BG_STATUS_HUNGER := preload("res://assets/ui/status/status_card_hunger_bg.png")
const BG_STATUS_MOOD := preload("res://assets/ui/status/status_card_mood_bg.png")
const BG_STATUS_ENERGY := preload("res://assets/ui/status/status_card_energy_bg.png")
const BG_STATUS_CLEAN := preload("res://assets/ui/status/status_card_clean_bg.png")
const SPARKLE_GOLD := preload("res://assets/icons/common/sparkle_gold.png")
const SPARKLE_PINK := preload("res://assets/icons/common/sparkle_pink.png")
const SPARKLE_PURPLE := preload("res://assets/icons/common/sparkle_purple.png")
const SPARKLE_BLUE := preload("res://assets/icons/common/sparkle_blue.png")

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
	custom_minimum_size = Vector2(0, 288)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_theme_stylebox_override("panel", UiTheme.make_panel_style(UiTheme.COLOR_PANEL_LIGHT, 28, UiTheme.COLOR_BORDER, 3, 5))

	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	add_child(grid)

	_add_status_card(grid, "hunger", "饱食", ICON_STATUS_HUNGER, UiTheme.COLOR_HUNGER, Color("#ffe9dc"), BG_STATUS_HUNGER, SPARKLE_GOLD)
	_add_status_card(grid, "mood", "开心", ICON_STATUS_MOOD, UiTheme.COLOR_HAPPY, Color("#ffe8f0"), BG_STATUS_MOOD, SPARKLE_PINK)
	_add_status_card(grid, "energy", "精力", ICON_STATUS_ENERGY, UiTheme.COLOR_ENERGY, Color("#eeeaff"), BG_STATUS_ENERGY, SPARKLE_PURPLE)
	_add_status_card(grid, "clean", "清洁", ICON_STATUS_CLEAN, UiTheme.COLOR_CLEAN, Color("#e7fbff"), BG_STATUS_CLEAN, SPARKLE_BLUE)


func _add_status_card(parent: GridContainer, id: String, title: String, icon_texture: Texture2D, color: Color, bg: Color, bg_texture: Texture2D, sparkle_texture: Texture2D) -> void:
	var card = StatusCardScene.new()
	card.setup(title, icon_texture, color, bg, bg_texture, sparkle_texture)
	parent.add_child(card)
	cards[id] = card
