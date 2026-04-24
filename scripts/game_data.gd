extends Node

# 真实感状态算法的核心数据放在 AutoLoad 中，避免 UI、猫咪绘制脚本各自维护一套状态。
# 数值约定：除 favor / coin 外，基础属性都限制在 0 - 100。

const SAVE_PATH := "user://save_game.json"
const MAX_OFFLINE_SECONDS := 8 * 60 * 60
const ONLINE_TICK_SECONDS := 60.0
const AUTO_SAVE_TICKS := 5
const EVENT_TICKS := 10

var selected_cat_id: String = ""
var selected_cat_name: String = ""
var selected_cat_type: String = ""
var selected_cat_personality: String = ""

var hunger: float = 100.0
var mood: float = 100.0
var clean: float = 100.0
var energy: float = 100.0
var social: float = 25.0
var curiosity: float = 30.0
var favor: int = 0
var coin: int = 0

var is_outside: bool = false
var is_sleeping: bool = false
var action_state: String = ""
var display_state: String = "idle"
var last_state: String = "idle"
var last_event_text: String = ""
var offline_summary: String = ""

var trip_start_time: int = 0
var trip_end_time: int = 0
var current_trip_event: Dictionary = {}
var last_save_time: int = 0
var online_tick_accumulator := 0.0
var ticks_since_save := 0
var ticks_since_event := 0
var long_offline_touch_bonus := false
var long_offline_feed_bonus := false

var cats := {
	"orange": {
		"id": "orange",
		"name": "橘子",
		"type": "橘猫",
		"personality": "贪吃、调皮、搞笑",
		"desc": "一只永远在寻找下一顿饭的猫。"
	},
	"calico": {
		"id": "calico",
		"name": "小花",
		"type": "三花猫",
		"personality": "傲娇、爱漂亮、戏精",
		"desc": "它不是不理你，只是在等你主动。"
	},
	"gray": {
		"id": "gray",
		"name": "灰灰",
		"type": "灰猫",
		"personality": "佛系、安静、爱睡觉",
		"desc": "它的人生目标是找一个阳光刚好的地方。"
	}
}

var trip_events := [
	{"place": "便利店", "event": "去便利店门口蹭空调", "type": "funny"},
	{"place": "屋顶", "event": "在屋顶看夕阳", "type": "warm"},
	{"place": "快递站", "event": "钻进纸箱出不来", "type": "funny"},
	{"place": "奶茶店", "event": "在奶茶店门口当招财猫", "type": "funny"},
	{"place": "公园", "event": "躲在花丛里睡午觉", "type": "warm"},
	{"place": "小巷", "event": "和路边狗对视了十分钟", "type": "funny"},
	{"place": "窗台", "event": "在窗台外看家的方向", "type": "warm"}
]

var state_texts := {
	"idle": ["它正在发呆。", "它看起来很淡定。"],
	"hungry": ["它好像有点饿了。", "它盯着饭碗很久了。"],
	"very_hungry": ["它真的饿了，正在认真看你。"],
	"sleepy": ["它开始犯困了。", "它的眼睛快睁不开了。"],
	"sleeping": ["它睡着了，还在轻轻打呼。"],
	"dirty": ["它身上有点脏，但它假装没有。"],
	"lonely": ["它好像想让你陪陪它。"],
	"bored": ["它有点无聊，正在寻找新目标。"],
	"want_go_out": ["它一直看着门口，可能想出去走走。"],
	"playful": ["它看起来很想玩。"],
	"happy": ["它现在心情很好。"],
	"outside": ["它出门探索去了。"]
}


func _ready() -> void:
	randomize()


func adopt_cat(cat_id: String) -> void:
	if not cats.has(cat_id):
		return

	var cat: Dictionary = cats[cat_id]
	selected_cat_id = cat["id"]
	selected_cat_name = cat["name"]
	selected_cat_type = cat["type"]
	selected_cat_personality = cat["personality"]

	# 领养时给猫一个轻松的初始状态：不满值拉满，需求值从中低位开始慢慢增长。
	hunger = 100.0
	mood = 100.0
	clean = 100.0
	energy = 100.0
	social = 25.0
	curiosity = 30.0
	favor = 0
	coin = 0

	is_outside = false
	is_sleeping = false
	action_state = ""
	display_state = "idle"
	last_state = "idle"
	last_event_text = ""
	offline_summary = ""
	trip_start_time = 0
	trip_end_time = 0
	current_trip_event = {}
	last_save_time = int(Time.get_unix_time_from_system())
	long_offline_touch_bonus = false
	long_offline_feed_bonus = false

	save_game()


func tick_online(delta: float) -> void:
	if selected_cat_id == "" or is_outside:
		return

	online_tick_accumulator += delta
	while online_tick_accumulator >= ONLINE_TICK_SECONDS:
		online_tick_accumulator -= ONLINE_TICK_SECONDS
		_apply_online_minute()


func _apply_online_minute() -> void:
	# 在线状态每分钟结算一次，而不是每帧扣数值。这样数值更稳定，也方便解释和调试。
	var period := get_time_period()
	var state := resolve_state()
	var period_mul := _period_multipliers(period)
	var personality_mul := _personality_multipliers()
	var state_mul := _state_multipliers(state)

	if state == "sleeping":
		# 睡眠是特殊行为：主要恢复精力，同时轻微消耗饱腹并略微增加亲近需求。
		energy += 0.8 * period_mul["energy"] * personality_mul["energy"]
		mood += 0.05
		hunger -= 0.05 * period_mul["hunger"] * personality_mul["hunger"]
		social += 0.03 * personality_mul["social"]
	else:
		hunger -= 0.35 * period_mul["hunger"] * personality_mul["hunger"] * state_mul["hunger"]
		energy -= 0.25 * period_mul["energy"] * personality_mul["energy"] * state_mul["energy"]
		mood -= 0.12 * personality_mul["mood"] * state_mul["mood"]
		clean -= 0.08 * personality_mul["clean"] * state_mul["clean"]
		social += 0.18 * period_mul["social"] * personality_mul["social"] * state_mul["social"]
		curiosity += 0.15 * period_mul["curiosity"] * personality_mul["curiosity"] * state_mul["curiosity"]

	# 极度饥饿会叫醒猫，避免一直睡到低血糖式崩坏。
	if is_sleeping and (energy >= 85.0 or hunger < 25.0):
		is_sleeping = false

	_clamp_stats()
	display_state = resolve_state()
	_maybe_trigger_small_event()
	_save_periodically()


func apply_offline_progress() -> void:
	if selected_cat_id == "" or last_save_time <= 0:
		return

	var now := int(Time.get_unix_time_from_system())
	var offline_seconds: int = maxi(now - last_save_time, 0)
	if offline_seconds < 60:
		return

	# 离线最多只结算 8 小时，避免一天没上线就把猫养崩。
	var effective_seconds: int = mini(offline_seconds, MAX_OFFLINE_SECONDS)
	var hours := float(effective_seconds) / 3600.0
	var before := {
		"hunger": hunger,
		"energy": energy,
		"mood": mood,
		"clean": clean,
		"social": social,
		"curiosity": curiosity
	}

	if is_outside and now >= trip_end_time:
		finish_trip()

	# 离线按小时粒度模拟，只保留温和变化和最低保护。
	hunger = maxf(hunger - 5.0 * hours, 10.0)
	mood = maxf(mood - 2.0 * hours, 20.0)
	clean = maxf(clean - 1.5 * hours, 15.0)
	social = minf(social + 4.0 * hours, 100.0)
	curiosity = minf(curiosity + 3.0 * hours, 100.0)

	var period := get_time_period()
	if period == "daytime" or is_sleeping:
		energy = minf(energy + 6.0 * hours, 100.0)
	else:
		energy = maxf(energy - 1.0 * hours, 10.0)

	long_offline_touch_bonus = offline_seconds >= 4 * 60 * 60
	long_offline_feed_bonus = offline_seconds >= 8 * 60 * 60
	offline_summary = _build_offline_summary(before)
	_clamp_stats()
	display_state = resolve_state()
	save_game()


func resolve_state() -> String:
	# 状态优先级严格按设计文档排列：外出和玩家动作最高，其次才是生理/情绪倾向。
	if is_outside:
		return "outside"
	if action_state != "":
		return action_state
	if hunger < 15.0:
		return "very_hungry"
	if is_sleeping:
		return "sleeping"
	if energy < 30.0:
		return "sleepy"
	if clean < 35.0:
		return "dirty"
	if hunger < 35.0:
		return "hungry"
	if social > 70.0:
		return "lonely"
	if mood < 45.0 and curiosity > 60.0:
		return "bored"
	if curiosity > 75.0 and energy > 45.0:
		return "want_go_out"
	if energy > 50.0 and mood > 50.0 and curiosity > 50.0:
		return "playful"
	if mood > 75.0 and hunger > 50.0:
		return "happy"
	return "idle"


func get_state_text() -> String:
	var state := resolve_state()
	var texts: Array = state_texts.get(state, state_texts["idle"])
	return texts[0]


func get_time_period() -> String:
	var hour := int(Time.get_datetime_dict_from_system()["hour"])
	if hour >= 5 and hour < 8:
		return "early_morning"
	if hour >= 8 and hour < 16:
		return "daytime"
	if hour >= 16 and hour < 22:
		return "evening"
	return "night"


func feed() -> Dictionary:
	var state := resolve_state()
	var msg := ""
	action_state = "eating"
	is_sleeping = false

	if hunger > 80.0:
		mood += 2.0
		msg = "%s已经不太饿了，只礼貌地闻了闻。" % selected_cat_name
	else:
		var gain := 35.0
		if selected_cat_id == "orange":
			gain *= 1.15
		hunger += gain
		mood += 5.0
		social -= 5.0
		clean -= 1.0
		favor += 2
		if state == "very_hungry" or long_offline_feed_bonus:
			favor += 1
		msg = "%s认真吃完了这顿饭。" % selected_cat_name

	long_offline_feed_bonus = false
	_finish_action()
	return {"ok": true, "message": msg}


func touch_cat() -> Dictionary:
	action_state = "being_touched"
	var state := resolve_state()
	var gain := 15.0
	var msg := "%s把脑袋贴到你的手心。" % selected_cat_name

	if state == "lonely":
		gain *= 1.3
	if selected_cat_id == "calico":
		gain *= 1.2
	if is_sleeping and selected_cat_id == "gray" and randf() < 0.5:
		gain = -5.0
		msg = "%s睡得正香，被摸醒后有点不开心。" % selected_cat_name
	elif is_sleeping:
		gain = -5.0
		msg = "%s被摸醒了，眯着眼看了你一下。" % selected_cat_name
	if long_offline_touch_bonus:
		gain += 5.0
		long_offline_touch_bonus = false

	mood += gain
	social -= 25.0
	favor += 1
	_finish_action()
	return {"ok": true, "message": msg}


func play() -> Dictionary:
	if energy < 25.0:
		return {"ok": false, "message": "%s现在只想睡觉。" % selected_cat_name}

	action_state = "playing"
	var state := resolve_state()
	mood += 18.0
	energy -= 18.0
	curiosity -= 20.0
	hunger -= 5.0
	favor += 2

	if state == "bored":
		mood += 10.0
	if selected_cat_id == "orange":
		curiosity += 12.0

	_finish_action()
	return {"ok": true, "message": "%s玩得很投入，尾巴都甩出了节奏。" % selected_cat_name}


func clean_cat() -> Dictionary:
	action_state = "cleaning"
	var state := resolve_state()
	var msg := "%s甩了甩水，毛又蓬起来了。" % selected_cat_name

	if clean > 80.0:
		mood -= 10.0
		msg = "%s觉得自己明明很干净，不太想再洗。" % selected_cat_name
	elif state == "dirty":
		clean += 50.0
		favor += 2
	else:
		clean += 50.0
		mood -= 5.0
		favor += 1

	if selected_cat_id == "calico":
		clean += 10.0
		mood += 5.0

	_finish_action()
	return {"ok": true, "message": msg}


func start_sleep() -> void:
	is_sleeping = true
	action_state = ""
	display_state = "sleeping"
	save_game()


func wake_up() -> void:
	is_sleeping = false
	display_state = resolve_state()
	save_game()


func can_start_trip() -> Dictionary:
	if energy < 40.0:
		return {"ok": false, "message": "%s现在精力不够，不想出门。" % selected_cat_name}
	if hunger < 35.0:
		return {"ok": false, "message": "%s有点饿，先吃点东西再出门吧。" % selected_cat_name}
	if mood < 35.0:
		return {"ok": false, "message": "%s心情一般，暂时不想出门。" % selected_cat_name}
	return {"ok": true, "message": ""}


func start_trip(duration_sec: int = 30) -> Dictionary:
	var allowed: Dictionary = can_start_trip()
	if not bool(allowed["ok"]):
		return allowed

	is_sleeping = false
	is_outside = true
	action_state = ""
	energy -= 15.0
	hunger -= 10.0
	curiosity -= 40.0
	mood += 5.0
	_clamp_stats()

	trip_start_time = int(Time.get_unix_time_from_system())
	trip_end_time = trip_start_time + duration_sec
	current_trip_event = trip_events.pick_random()
	save_game()
	return {"ok": true, "message": "%s出门探索去了。" % selected_cat_name}


func is_trip_finished() -> bool:
	if not is_outside:
		return false
	return int(Time.get_unix_time_from_system()) >= trip_end_time


func finish_trip() -> Dictionary:
	is_outside = false

	var reward_coin := randi_range(10, 30)
	var clean_loss := randf_range(5.0, 15.0)
	var hunger_loss := randf_range(10.0, 25.0)
	coin += reward_coin
	favor += 5
	mood = minf(mood + 10.0, 100.0)
	clean = maxf(clean - clean_loss, 0.0)
	hunger = maxf(hunger - hunger_loss, 0.0)

	var result := {
		"cat_name": selected_cat_name,
		"place": current_trip_event.get("place", "外面"),
		"event": current_trip_event.get("event", "出去玩了一圈"),
		"reward_coin": reward_coin,
		"diary": generate_local_diary(current_trip_event)
	}

	current_trip_event = {}
	display_state = resolve_state()
	save_game()
	return result


func generate_local_diary(event_data: Dictionary) -> String:
	var event_text: String = event_data.get("event", "出去玩了一圈")
	var templates := [
		"%s今天%s，回来时一脸淡定，好像什么都没发生。",
		"%s今天%s。它说这是猫咪的正常社交活动。",
		"%s今天%s，看起来心情不错，就是有点饿。",
		"%s今天%s，并决定暂时不解释原因。"
	]
	return templates.pick_random() % [selected_cat_name, event_text]


func save_game() -> void:
	last_save_time = int(Time.get_unix_time_from_system())
	var data := {
		"selected_cat_id": selected_cat_id,
		"selected_cat_name": selected_cat_name,
		"selected_cat_type": selected_cat_type,
		"selected_cat_personality": selected_cat_personality,
		"hunger": hunger,
		"mood": mood,
		"clean": clean,
		"energy": energy,
		"social": social,
		"curiosity": curiosity,
		"favor": favor,
		"coin": coin,
		"is_outside": is_outside,
		"is_sleeping": is_sleeping,
		"display_state": resolve_state(),
		"trip_start_time": trip_start_time,
		"trip_end_time": trip_end_time,
		"current_trip_event": current_trip_event,
		"last_save_time": last_save_time,
		"long_offline_touch_bonus": long_offline_touch_bonus,
		"long_offline_feed_bonus": long_offline_feed_bonus
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false

	var data = JSON.parse_string(file.get_as_text())
	if data == null:
		return false

	selected_cat_id = data.get("selected_cat_id", "")
	selected_cat_name = data.get("selected_cat_name", "")
	selected_cat_type = data.get("selected_cat_type", "")
	selected_cat_personality = data.get("selected_cat_personality", "")
	hunger = float(data.get("hunger", 100.0))
	mood = float(data.get("mood", 100.0))
	clean = float(data.get("clean", 100.0))
	energy = float(data.get("energy", 100.0))
	social = float(data.get("social", 25.0))
	curiosity = float(data.get("curiosity", 30.0))
	favor = int(data.get("favor", 0))
	coin = int(data.get("coin", 0))
	is_outside = bool(data.get("is_outside", false))
	is_sleeping = bool(data.get("is_sleeping", false))
	display_state = data.get("display_state", "idle")
	trip_start_time = int(data.get("trip_start_time", 0))
	trip_end_time = int(data.get("trip_end_time", 0))
	current_trip_event = data.get("current_trip_event", {})
	last_save_time = int(data.get("last_save_time", 0))
	long_offline_touch_bonus = bool(data.get("long_offline_touch_bonus", false))
	long_offline_feed_bonus = bool(data.get("long_offline_feed_bonus", false))

	apply_offline_progress()
	display_state = resolve_state()
	return selected_cat_id != ""


func _finish_action() -> void:
	action_state = ""
	_clamp_stats()
	display_state = resolve_state()
	save_game()


func _period_multipliers(period: String) -> Dictionary:
	match period:
		"early_morning":
			return {"hunger": 1.2, "energy": 1.1, "curiosity": 1.3, "social": 1.0}
		"daytime":
			return {"hunger": 0.8, "energy": 0.6, "curiosity": 0.7, "social": 0.8}
		"evening":
			return {"hunger": 1.1, "energy": 1.2, "curiosity": 1.2, "social": 1.3}
		_:
			return {"hunger": 0.9, "energy": 0.8, "curiosity": 1.0, "social": 0.6}


func _personality_multipliers() -> Dictionary:
	var mul := {"hunger": 1.0, "energy": 1.0, "mood": 1.0, "clean": 1.0, "social": 1.0, "curiosity": 1.0}
	match selected_cat_id:
		"orange":
			mul["hunger"] = 1.25
			mul["mood"] = 0.9
			mul["curiosity"] = 1.2
			mul["social"] = 0.9
		"calico":
			mul["mood"] = 1.2
			mul["clean"] = 1.15
			mul["social"] = 1.3
		"gray":
			mul["hunger"] = 0.9
			mul["energy"] = 0.8
			mul["curiosity"] = 0.7
			mul["social"] = 0.8
	return mul


func _state_multipliers(state: String) -> Dictionary:
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


func _maybe_trigger_small_event() -> void:
	ticks_since_event += 1
	if ticks_since_event < EVENT_TICKS:
		return

	ticks_since_event = 0
	var state := resolve_state()
	var probability := 0.15
	match state:
		"bored":
			probability += 0.20
		"playful":
			probability += 0.15
		"lonely":
			probability += 0.10
		"happy":
			probability += 0.05
		"sleeping":
			probability -= 0.15

	if randf() <= probability:
		last_event_text = _small_event_text(state)


func _small_event_text(state: String) -> String:
	match state:
		"hungry":
			return "%s盯着饭碗看了很久。" % selected_cat_name
		"very_hungry":
			return "%s把饭碗推到了门口。" % selected_cat_name
		"bored":
			return "%s扒拉了一下沙发边角。" % selected_cat_name
		"lonely":
			return "%s坐在门口等你。" % selected_cat_name
		"playful":
			return "%s扑了一下空气里的灰尘。" % selected_cat_name
		"dirty":
			return "%s假装自己一点也不脏。" % selected_cat_name
		"happy":
			return "%s在房间里小跑了一圈。" % selected_cat_name
		"sleepy":
			return "%s找了个奇怪姿势准备睡觉。" % selected_cat_name
		_:
			return "%s换了个地方继续观察世界。" % selected_cat_name


func _save_periodically() -> void:
	ticks_since_save += 1
	if ticks_since_save >= AUTO_SAVE_TICKS:
		ticks_since_save = 0
		save_game()


func _build_offline_summary(before: Dictionary) -> String:
	var parts: Array[String] = []
	if float(before["hunger"]) - hunger > 15.0:
		parts.append("有点饿")
	if energy - float(before["energy"]) > 15.0:
		parts.append("睡得不错")
	if social - float(before["social"]) > 12.0:
		parts.append("有点想你")
	if curiosity > 75.0:
		parts.append("一直惦记着门外")

	if parts.is_empty():
		return "你离开的时候，%s安静地在小屋里待了一会儿。" % selected_cat_name
	return "你离开的时候，%s%s。" % [selected_cat_name, "，还".join(parts)]


func _clamp_stats() -> void:
	hunger = clampf(hunger, 0.0, 100.0)
	mood = clampf(mood, 0.0, 100.0)
	clean = clampf(clean, 0.0, 100.0)
	energy = clampf(energy, 0.0, 100.0)
	social = clampf(social, 0.0, 100.0)
	curiosity = clampf(curiosity, 0.0, 100.0)
