class_name ActionPanel
extends HBoxContainer

const UiTheme := preload("res://scripts/ui/ui_theme_helper.gd")
const ActionButtonScene := preload("res://scripts/ui/action_button.gd")
const ICON_FEED := preload("res://assets/icons/actions/action_feed.png")
const ICON_PLAY := preload("res://assets/icons/actions/action_play.png")
const ICON_PET := preload("res://assets/icons/actions/action_pet.png")
const ICON_CLEAN := preload("res://assets/icons/actions/action_bath.png")
const ICON_SLEEP := preload("res://assets/icons/actions/action_sleep.png")
const BG_FEED := preload("res://assets/ui/actions/action_button_feed_bg.png")
const BG_PLAY := preload("res://assets/ui/actions/action_button_play_bg.png")
const BG_PET := preload("res://assets/ui/actions/action_button_pet_bg.png")
const BG_CLEAN := preload("res://assets/ui/actions/action_button_bath_bg.png")
const BG_SLEEP := preload("res://assets/ui/actions/action_button_sleep_bg.png")
const SPARKLE_GOLD := preload("res://assets/icons/common/sparkle_gold.png")
const SPARKLE_BLUE := preload("res://assets/icons/common/sparkle_blue.png")
const SPARKLE_PINK := preload("res://assets/icons/common/sparkle_pink.png")
const SPARKLE_GREEN := preload("res://assets/icons/common/sparkle_green.png")
const SPARKLE_PURPLE := preload("res://assets/icons/common/sparkle_purple.png")

signal action_requested(action: String, button: Button)

var feed_button
var touch_button
var play_button
var clean_button
var sleep_button


func _ready() -> void:
	if get_child_count() == 0:
		_build()


func update_availability(is_outside: bool, is_sleeping: bool) -> void:
	if feed_button == null:
		_build()

	if is_outside:
		sleep_button.set_title("外出中")
		sleep_button.disabled = true
		feed_button.disabled = true
		touch_button.disabled = true
		play_button.disabled = true
		clean_button.disabled = true
	else:
		sleep_button.set_title("叫醒" if is_sleeping else "睡觉")
		sleep_button.disabled = false
		feed_button.disabled = false
		touch_button.disabled = false
		play_button.disabled = false
		clean_button.disabled = false
	sleep_button.queue_redraw()


func _build() -> void:
	custom_minimum_size = Vector2(0, 166)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	add_theme_constant_override("separation", 14)

	feed_button = _make_action_button("喂食", ICON_FEED, BG_FEED, SPARKLE_GOLD, "恢复饱腹，稍微增加心情", UiTheme.COLOR_BTN_FEED, Color("#e7a84e"), "feed")
	add_child(feed_button)

	play_button = _make_action_button("玩耍", ICON_PLAY, BG_PLAY, SPARKLE_BLUE, "消耗精力，降低好奇心，提升心情", UiTheme.COLOR_BTN_PLAY, Color("#68b6d5"), "play")
	add_child(play_button)

	touch_button = _make_action_button("抚摸", ICON_PET, BG_PET, SPARKLE_PINK, "增加心情和亲密", UiTheme.COLOR_BTN_PET, Color("#ef8b83"), "touch")
	add_child(touch_button)

	clean_button = _make_action_button("洗澡", ICON_CLEAN, BG_CLEAN, SPARKLE_GREEN, "把干净值恢复到满", UiTheme.COLOR_BTN_BATH, Color("#68bd8a"), "clean")
	add_child(clean_button)

	sleep_button = _make_action_button("睡觉", ICON_SLEEP, BG_SLEEP, SPARKLE_PURPLE, "睡觉或叫醒猫咪", UiTheme.COLOR_BTN_SLEEP, Color("#9c6ce8"), "sleep")
	add_child(sleep_button)


func _make_action_button(label: String, icon_texture: Texture2D, bg_texture: Texture2D, sparkle_texture: Texture2D, tooltip: String, bg: Color, border: Color, action: String) -> Button:
	var button = ActionButtonScene.new()
	button.setup(label, icon_texture, tooltip, bg, border, bg_texture, sparkle_texture)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.pressed.connect(func() -> void:
		action_requested.emit(action, button)
	)
	return button
