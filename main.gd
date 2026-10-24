extends Node2D

const W := 960.0
const H := 540.0
const FLOOR_TOP := 305.0
const FLOOR_BOTTOM := 475.0
const PLAYER_START := Vector2(310, 390)
const AUDIO_RATE := 22050
const GAME_LOGO: Texture2D = preload("res://assets/game_logo_blended.png")
const CASTLE_BACKGROUND: Texture2D = preload("res://assets/castle_corridor.png")
const MENU_BACKGROUND: Texture2D = preload("res://assets/castle_menu_background.png")
const TORCHES := [Vector2(88, 118), Vector2(331, 118), Vector2(574, 118), Vector2(818, 118)]
const ARROW_TEXTURE: Texture2D = preload("res://assets/enemies/Arrow01.png")
const SOLDIER_IDLE: Texture2D = preload("res://assets/enemies/Soldier/Soldier-Idle.png")
const SOLDIER_WALK: Texture2D = preload("res://assets/enemies/Soldier/Soldier-Walk.png")
const SOLDIER_ATTACK_1: Texture2D = preload("res://assets/enemies/Soldier/Soldier-Attack01.png")
const SOLDIER_ATTACK_2: Texture2D = preload("res://assets/enemies/Soldier/Soldier-Attack02.png")
const SOLDIER_ATTACK_3: Texture2D = preload("res://assets/enemies/Soldier/Soldier-Attack03.png")
const SOLDIER_HURT: Texture2D = preload("res://assets/enemies/Soldier/Soldier-Hurt.png")
const SOLDIER_DEATH: Texture2D = preload("res://assets/enemies/Soldier/Soldier-Death.png")
const ORC_IDLE: Texture2D = preload("res://assets/enemies/Orc/Orc-Idle.png")
const ORC_WALK: Texture2D = preload("res://assets/enemies/Orc/Orc-Walk.png")
const ORC_ATTACK_1: Texture2D = preload("res://assets/enemies/Orc/Orc-Attack01.png")
const ORC_ATTACK_2: Texture2D = preload("res://assets/enemies/Orc/Orc-Attack02.png")
const ORC_HURT: Texture2D = preload("res://assets/enemies/Orc/Orc-Hurt.png")
const ORC_DEATH: Texture2D = preload("res://assets/enemies/Orc/Orc-Death.png")
var hobbit_idle: Array[Texture2D] = []
var hobbit_run: Array[Texture2D] = []
var hobbit_attack: Array[Texture2D] = []
var hobbit_block: Array[Texture2D] = []
var hobbit_jump: Array[Texture2D] = []
var hobbit_stop: Array[Texture2D] = []
var hobbit_hit: Array[Texture2D] = []
var hobbit_death: Array[Texture2D] = []
var torch_fire_frames: Array[Texture2D] = []
var blood_frames: Array[Texture2D] = []
var blood_effects: Array[Dictionary] = []
var shadow_heroes: Array[Dictionary] = []
var wetlands_animations: Dictionary = {}
const STAGE_NAMES := ["BAMBOO OUTSKIRTS", "IRON FORTRESS", "SUNSET CAUSEWAY", "FROSTFIRE ISLAND", "OBSIDIAN TOWER"]
const WAVES_PER_ACT := 3
const HEROES := [
	{"name": "CINDERGUARD", "style": "SHADOW KNIGHT", "ability": "NIGHTFALL SLASH", "description": "A dark armored guardian with ember-bright eyes and a crushing blade.", "kind": "lunge", "damage": 20.0, "special_damage": 36.0, "reach": 105.0, "special_reach": 160.0, "mp_cost": 28.0, "cooldown": 2.7, "stats": [0.82, 0.62, 0.54]},
	{"name": "DUSKSTALKER", "style": "VEIL RANGER", "ability": "PHANTOM DASH", "description": "A hooded forest hunter who blinks through enemies in a shadow dash.", "kind": "dash", "damage": 18.0, "special_damage": 34.0, "reach": 100.0, "special_reach": 220.0, "mp_cost": 32.0, "cooldown": 3.0, "stats": [0.68, 0.72, 0.82]}
]
const HERO_COLORS := [Color("e9a84d"), Color("c392ff")]
const ENEMY_TYPES := ["SOLDIER", "ORC", "ARCHER", "ORC CHAMPION", "HOBBIT SCOUT", "HOBBIT RAIDER", "WETLANDS BOSS"]

var player := {}
var enemies: Array[Dictionary] = []
var corpses: Array[Dictionary] = []
var projectiles: Array[Dictionary] = []
var elapsed := 0.0
var wave := 1
var stage_number := 1
var act_number := 1
var wave_in_act := 1
var game_mode := "stage"
var intermission_timer := 0.0
var intermission_label := ""
var victory := false
var health_pickup := {}
var score := 0
var selected_character := 0
var difficulty := 1
var screen_mode := "main"
var menu_selection := 0
var menu_press_timer := 0.0
var pending_main_option := -1
var pressed_menu_option := -1
var has_saved_game := false
var attack_flash := 0.0
var special_cooldown := 0.0
var touch_points: Dictionary = {}
var touch_axis := Vector2.ZERO
var held := {"left": false, "right": false, "up": false, "down": false, "attack": false, "special": false}
var game_over := false
var audio_unlocked := false
var music_player: AudioStreamPlayer
var sound_streams: Dictionary = {}
var sound_players: Dictionary = {}

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_setup_audio()
	shadow_heroes = [
		{"idle": _load_hero_strip("Hallokin/idle.png", 192), "run": _load_hero_strip("Hallokin/run.png", 192), "attack": _load_hero_strip("Hallokin/attack.png", 192), "attack_combo": [_load_hero_strip("Hallokin/attack.png", 192), _load_hero_strip("Hallokin/attack_secondary.png", 192), _load_hero_strip("Hallokin/jump_attack_forward.png", 192)], "special_attack": _load_hero_strip("Hallokin/attack_up.png", 192), "jump": _load_hero_strip("Hallokin/jump.png", 192), "fall": _load_hero_strip("Hallokin/fall.png", 192), "hit": _load_hero_strip("Hallokin/hit.png", 192), "death": _load_hero_strip("Hallokin/death.png", 192), "scale": 3.0},
		{"idle": _load_hero_strip("BlindHuntress/idle.png", 240), "run": _load_hero_strip("BlindHuntress/run.png", 240), "jump": _load_hero_strip("BlindHuntress/jump.png", 240), "mid_air": _load_hero_strip("BlindHuntress/mid_air.png", 240), "fall": _load_hero_strip("BlindHuntress/fall.png", 240), "dash": _load_hero_strip("BlindHuntress/dash.png", 240), "attack": _load_hero_strip("BlindHuntress/attack.png", 240), "attack_combo": [_load_hero_strip("BlindHuntress/attack_idle_up.png", 240), _load_hero_strip("BlindHuntress/attack.png", 240), _load_hero_strip("BlindHuntress/attack_heavy.png", 240), _load_hero_strip("BlindHuntress/attack_air.png", 240), _load_hero_strip("BlindHuntress/attack_sweep.png", 240)], "dash_attack": _load_hero_strip("BlindHuntress/attack_dash.png", 240), "special_attack": _load_hero_strip("BlindHuntress/attack_special.png", 240), "hit": _load_hero_strip("BlindHuntress/hit.png", 240), "death": _load_hero_strip("BlindHuntress/death.png", 240), "scale": 1.25}
	]
	_set_hero_pivot(shadow_heroes[0], 57.0, 79.0)
	_set_hero_pivot(shadow_heroes[1], 118.0, 81.0)
	shadow_heroes[0].preview_scale = 4.25
	shadow_heroes[1].preview_scale = 1.25
	wetlands_animations = {
		"idle": _load_wetlands_strip("idle"),
		"run": _load_wetlands_strip("walk"),
		"attack1": _load_wetlands_strip("Attack1"),
		"attack2": _load_wetlands_strip("Attack2"),
		"pre_attack": _load_wetlands_strip("PreAttack3"),
		"mid_attack": _load_wetlands_strip("MidAttack3"),
		"end_attack": _load_wetlands_strip("EndAttack3"),
		"hit": _load_wetlands_strip("hit"),
		"death": _load_wetlands_strip("death")
	}
	for strip in wetlands_animations.values():
		strip.pivot_x = 83.0
		strip.pivot_y = 86.0
	hobbit_idle = _load_hobbit_frames("Idle", 4)
	hobbit_run = _load_hobbit_frames("run", 10)
	hobbit_attack = _load_hobbit_frames("attack", 17)
	hobbit_block = _load_hobbit_frames("block", 13)
	hobbit_jump = _load_hobbit_frames("jumpt", 10)
	hobbit_stop = _load_hobbit_frames("stop", 8)
	hobbit_hit = _load_hobbit_frames("hit", 4)
	hobbit_death = _load_hobbit_frames("death", 12)
	torch_fire_frames = _load_fire_frames("torch")
	for i in range(1, 12):
		var blood_texture := load("res://assets/effects/blood/blood_%02d.png" % i) as Texture2D
		if blood_texture != null: blood_frames.append(blood_texture)
	reset_game()

func _setup_audio() -> void:
	for sound_name in ["menu", "swing", "hit", "hurt", "special", "wave"]:
		sound_streams[sound_name] = _synthesize_sound(sound_name)
		var sound_player := AudioStreamPlayer.new()
		sound_player.name = "SFX_" + sound_name
		sound_player.stream = sound_streams[sound_name]
		sound_player.volume_db = -5.0 if sound_name == "wave" or sound_name == "hurt" else -3.0
		sound_player.max_polyphony = 4
		add_child(sound_player)
		sound_players[sound_name] = sound_player
	music_player = AudioStreamPlayer.new()
	music_player.name = "CastleAmbience"
	music_player.stream = _synthesize_sound("music")
	music_player.volume_db = -6.0
	add_child(music_player)

func _unlock_audio() -> void:
	if audio_unlocked:
		return
	audio_unlocked = true
	if music_player != null:
		music_player.play()

func _play_sound(sound_name: String) -> void:
	if not sound_players.has(sound_name):
		return
	_unlock_audio()
	var sound_player: AudioStreamPlayer = sound_players[sound_name]
	sound_player.play()

func _synthesize_sound(kind: String) -> AudioStreamWAV:
	var sample_rate := 11025 if kind == "music" else AUDIO_RATE
	var duration := 8.0 if kind == "music" else 1.08 if kind == "wave" else 0.52 if kind == "special" else 0.24 if kind == "swing" else 0.22 if kind == "hurt" else 0.19 if kind == "hit" else 0.13
	var sample_count := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var chord_progression := [[110.0, 130.81, 164.81, 220.0], [87.31, 110.0, 130.81, 174.61], [130.81, 164.81, 196.0, 261.63], [98.0, 123.47, 146.83, 196.0]]
	var wave_notes := [523.25, 659.25, 783.99, 1046.5]
	for i in range(sample_count):
		var t := float(i) / float(sample_rate)
		var value := 0.0
		if kind == "music":
			var chord: Array = chord_progression[int(t / 2.0) % chord_progression.size()]
			for j in range(chord.size()):
				var frequency := float(chord[j])
				value += 0.045 * sin(TAU * frequency * t + float(j) * 0.12)
				value += 0.014 * sin(TAU * frequency * 2.0 * t + float(j) * 0.2)
			value *= 0.9 + 0.1 * sin(TAU * 0.23 * t)
			value *= minf(1.0, minf(t / 0.32, (duration - t) / 0.32))
		elif kind == "menu":
			var envelope := exp(-t * 22.0)
			value = envelope * (0.24 * sin(TAU * 610.0 * t) + 0.13 * sin(TAU * 920.0 * t))
		elif kind == "swing":
			var progress := t / duration
			var envelope := sin(PI * progress)
			var frequency := 640.0 - 390.0 * progress
			value = envelope * (0.2 * sin(TAU * frequency * t) + 0.09 * sin(TAU * (frequency * 1.7) * t))
		elif kind == "hit":
			var progress := t / duration
			var envelope := exp(-t * 24.0)
			var frequency := 130.0 - 74.0 * progress
			value = envelope * (0.42 * sin(TAU * frequency * t) + 0.12 * sin(TAU * frequency * 2.0 * t))
		elif kind == "hurt":
			var progress := t / duration
			var envelope := exp(-t * 17.0)
			var frequency := 240.0 - 120.0 * progress
			value = envelope * (0.24 * sin(TAU * frequency * t) + 0.12 * sin(TAU * frequency * 1.4 * t))
		elif kind == "special":
			var progress := t / duration
			var envelope := sin(PI * progress)
			var phase := TAU * (260.0 * t + 340.0 * t * progress)
			value = envelope * (0.2 * sin(phase) + 0.11 * sin(phase * 1.5))
		elif kind == "wave":
			for j in range(wave_notes.size()):
				var note_time := t - float(j) * 0.19
				if note_time >= 0.0:
					var envelope := exp(-note_time * (3.5 if j == 3 else 5.0))
					value += 0.18 * envelope * (sin(TAU * wave_notes[j] * note_time) + 0.22 * sin(TAU * wave_notes[j] * 2.01 * note_time))
		var sample := clampi(roundi(clampf(value, -0.95, 0.95) * 32767.0), -32768, 32767)
		data[i * 2] = sample & 0xff
		data[i * 2 + 1] = (sample >> 8) & 0xff
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	if kind == "music":
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = sample_count
	return stream

func _load_fire_frames(prefix: String) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	for i in range(1, 9):
		var texture := load("res://assets/effects/fire/%s_%02d.png" % [prefix, i]) as Texture2D
		if texture != null: frames.append(texture)
	return frames

func _load_hero_strip(path: String, frame_width: int) -> Dictionary:
	var tex := load("res://assets/heroes/shadow/%s" % path) as Texture2D
	if tex == null: return {"texture": null, "frame_width": frame_width, "frame_count": 1, "frame_height": 128}
	return {"texture": tex, "frame_width": frame_width, "frame_count": maxi(1, int(tex.get_width() / frame_width)), "frame_height": tex.get_height()}

func _load_wetlands_strip(name: String) -> Dictionary:
	var tex := load("res://assets/enemies/WetlandsBoss/%s.png" % name) as Texture2D
	if tex == null: return {"texture": null, "frame_width": 247, "frame_count": 1, "frame_height": 87}
	return {"texture": tex, "frame_width": 247, "frame_count": maxi(1, int(tex.get_width() / 247)), "frame_height": tex.get_height()}

func _set_hero_pivot(animations: Dictionary, pivot_x: float, pivot_y: float) -> void:
	for animation in animations.values():
		if animation is Dictionary and animation.has("frame_width"):
			animation.pivot_x = pivot_x
			animation.pivot_y = pivot_y
		elif animation is Array:
			for strip in animation:
				strip.pivot_x = pivot_x
				strip.pivot_y = pivot_y

func _load_hobbit_frames(prefix: String, count: int) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	for i in range(1, count + 1):
		var texture := load("res://assets/enemies/Hobbit/%s%d.png" % [prefix, i]) as Texture2D
		if texture != null: frames.append(texture)
	return frames

func reset_game() -> void:
	wave = 1
	stage_number = 1
	act_number = 1
	wave_in_act = 1
	score = 0
	special_cooldown = 0.0
	intermission_timer = 0.0
	intermission_label = ""
	victory = false
	health_pickup.clear()
	player = {"pos": PLAYER_START, "hp": 100.0, "max_hp": 100.0, "mp": 100.0, "max_mp": 100.0, "facing": 1.0, "stun": 0.0, "attack": 0.0, "attack_frame": 4, "combo_index": 0, "anim": 0.0, "special": 0.0, "dash_remaining": 0.0, "dash_direction": 1.0, "dash_finish": 0.0, "character": selected_character, "velocity": Vector2.ZERO}
	enemies.clear()
	corpses.clear()
	projectiles.clear()
	blood_effects.clear()
	_spawn_wave()
	game_over = false

func _spawn_enemy(index: int, is_boss: bool = false) -> void:
	var character := 6 if is_boss else (wave + index - 1) % ENEMY_TYPES.size()
	var enemy_x := W + 54.0 + float(index) * 48.0
	var enemy_y := 350.0 + float((index * 47) % 100)
	var base_hp: float = [54.0, 64.0, 48.0, 76.0, 34.0, 46.0, 145.0][character]
	var move_speed: float = [62.0, 58.0, 48.0, 56.0, 76.0, 60.0, 46.0][character]
	var hit_damage: float = [8.0, 9.0, 7.0, 11.0, 4.0, 6.0, 13.0][character]
	if is_boss: enemy_x = W + 220.0
	enemies.append({"pos": Vector2(enemy_x, enemy_y), "hp": base_hp, "max_hp": base_hp, "facing": -1.0, "stun": 0.0, "attack": 0.0, "attack_frame": 4, "special": 0.0, "block_timer": 0.0, "block_cooldown": randf_range(1.0, 2.5), "jump_timer": 0.0, "jump_cooldown": randf_range(1.5, 3.0), "stop_timer": 0.0, "cooldown": randf_range(0.4, 1.25), "ranged_cooldown": randf_range(1.0, 2.0), "anim": 0.0, "character": character, "speed": move_speed, "damage": hit_damage, "boss": is_boss, "velocity": Vector2.ZERO})

func _spawn_wave() -> void:
	enemies.clear()
	projectiles.clear()
	var is_boss_wave := act_number == 5 and wave_in_act == WAVES_PER_ACT
	if game_mode == "survival": is_boss_wave = wave % 5 == 0
	var count := mini(2 + int((wave - 1) / 2) + stage_number + difficulty - 1, 10)
	for i in range(count):
		_spawn_enemy(i, is_boss_wave and i == count - 1)

func _process(delta: float) -> void:
	elapsed += delta
	if menu_press_timer > 0.0:
		menu_press_timer = maxf(0.0, menu_press_timer - delta)
		if menu_press_timer <= 0.0:
			var option_to_activate := pending_main_option
			pending_main_option = -1
			pressed_menu_option = -1
			if option_to_activate >= 0 and screen_mode == "main": _activate_main_option(option_to_activate)
	if screen_mode != "game":
		queue_redraw()
		return
	attack_flash = maxf(0.0, attack_flash - delta)
	special_cooldown = maxf(0.0, special_cooldown - delta)
	if game_over:
		_update_corpses(delta)
		queue_redraw()
		return
	if intermission_timer > 0.0:
		intermission_timer = maxf(0.0, intermission_timer - delta)
		_update_corpses(delta)
		if intermission_timer <= 0.0 and not victory: _spawn_wave()
		queue_redraw()
		return
	_update_player(delta)
	_update_enemies(delta)
	_update_projectiles(delta)
	_update_blood_effects(delta)
	_update_corpses(delta)
	_update_health_pickup()
	if enemies.is_empty(): _complete_wave()
	queue_redraw()

func _complete_wave() -> void:
	if intermission_timer > 0.0 or game_over: return
	_play_sound("wave")
	score += stage_number * act_number * 75
	if game_mode == "survival":
		intermission_label = "WAVE COMPLETED"
		if wave % 5 == 0 and player.hp < player.max_hp:
			health_pickup = {"pos": Vector2(480.0, 430.0), "heal": 28.0}
		wave += 1
		stage_number = 1 + int((wave - 1) / 5)
		act_number = 1 + ((wave - 1) % 5)
	else:
		if wave_in_act < WAVES_PER_ACT:
			intermission_label = "WAVE COMPLETED"
			if wave_in_act == WAVES_PER_ACT - 1 and player.hp < player.max_hp:
				health_pickup = {"pos": Vector2(480.0, 430.0), "heal": 20.0}
			wave_in_act += 1
			wave += 1
		else:
			wave_in_act = 1
			if act_number < 5:
				intermission_label = "ACT COMPLETED"
				act_number += 1
				wave += 1
			else:
				if player.hp < player.max_hp:
					health_pickup = {"pos": Vector2(480.0, 430.0), "heal": 30.0}
				if stage_number < 5:
					intermission_label = "STAGE COMPLETED"
					player.hp = minf(player.max_hp, player.hp + 18.0)
					stage_number += 1
					act_number = 1
					wave += 1
				else:
					intermission_label = "CAMPAIGN COMPLETE"
					victory = true
					game_over = true
	intermission_timer = 1.6

func _update_health_pickup() -> void:
	if health_pickup.is_empty(): return
	var distance: Vector2 = player.pos - health_pickup.pos
	if absf(distance.x) < 28.0 and absf(distance.y) < 35.0:
		player.hp = minf(player.max_hp, player.hp + float(health_pickup.heal))
		score += 50
		health_pickup.clear()

func _update_player(delta: float) -> void:
	player.anim += delta * 8.0
	player.stun = maxf(0.0, player.stun - delta)
	player.attack = maxf(0.0, player.attack - delta)
	player.special = maxf(0.0, player.special - delta)
	player.dash_finish = maxf(0.0, float(player.dash_finish) - delta)
	if player.stun <= 0.0:
		if float(player.dash_remaining) > 0.0:
			var dash_step := minf(900.0 * delta, float(player.dash_remaining))
			var old_x := float(player.pos.x)
			player.pos.x = clampf(player.pos.x + float(player.dash_direction) * dash_step, 70.0, 890.0)
			player.dash_remaining = maxf(0.0, float(player.dash_remaining) - absf(player.pos.x - old_x))
			player.velocity = Vector2(float(player.dash_direction), 0.0)
			if player.dash_remaining <= 0.0: player.dash_finish = 0.72
		else:
			var axis := touch_axis
			axis.x += (1.0 if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT) else 0.0) - (1.0 if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT) else 0.0)
			axis.y += (1.0 if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN) else 0.0) - (1.0 if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP) else 0.0)
			if axis.length() > 1.0: axis = axis.normalized()
			player.velocity = axis
			player.pos += axis * 210.0 * delta
			player.pos.x = clampf(player.pos.x, 70.0, 890.0)
			player.pos.y = clampf(player.pos.y, FLOOR_TOP + 20.0, FLOOR_BOTTOM)
			if axis.x != 0.0: player.facing = signf(axis.x)
			if _down("attack", KEY_J, KEY_SPACE) and player.attack <= 0.05:
				player.attack = 0.44
				_attack(false)
			var hero: Dictionary = HEROES[selected_character]
			if _down("special", KEY_K, KEY_SHIFT) and special_cooldown <= 0.0 and player.mp >= hero.mp_cost:
				player.special = 0.56
				if selected_character == 1: player.dash_finish = 0.0
				player.mp -= hero.mp_cost
				special_cooldown = hero.cooldown
				_attack(true)
	var hp_regen_per_second := 0.0
	if difficulty == 0:
		hp_regen_per_second = 1.8
	elif difficulty == 1:
		hp_regen_per_second = 0.65
	if hp_regen_per_second > 0.0 and float(player.hp) > 0.0:
		player.hp = minf(float(player.max_hp), float(player.hp) + hp_regen_per_second * delta)

func _down(name: String, key_a: int, key_b: int) -> bool:
	return bool(held[name]) or Input.is_key_pressed(key_a) or Input.is_key_pressed(key_b)

func _attack(is_special: bool) -> void:
	_play_sound("special" if is_special else "swing")
	var hero: Dictionary = HEROES[selected_character]
	if is_special:
		player.attack_frame = 8
	else:
		var combo_frames := [4, 5, 6, 7, 8] if selected_character == 1 else [4, 5, 6]
		player.attack_frame = combo_frames[int(player.combo_index)]
		player.combo_index = (int(player.combo_index) + 1) % combo_frames.size()
	var range_x: float = hero.special_reach if is_special else hero.reach
	var range_y: float = 94.0 if is_special and str(hero.kind) == "phase" else 82.0 if is_special else 55.0
	var damage: float = hero.special_damage if is_special else hero.damage
	attack_flash = 0.2 if not is_special else 0.35
	if is_special and str(hero.kind) == "dash":
		var dash_start := float(player.pos.x)
		var dash_end := clampf(dash_start + float(player.facing) * range_x, 70.0, 890.0)
		var dash_distance := absf(dash_end - dash_start)
		player.dash_direction = float(player.facing)
		player.dash_remaining = dash_distance
		var dash_hits := 0
		for enemy in enemies:
			var projected_distance := (float(enemy.pos.x) - dash_start) * float(player.facing)
			if projected_distance >= -26.0 and projected_distance <= dash_distance + 30.0 and absf(enemy.pos.y - player.pos.y) < 80.0:
				var dash_blocked := float(enemy.block_timer) > 0.0
				enemy.hp -= damage * (0.35 if dash_blocked else 1.0)
				_spawn_blood_effect(enemy.pos + Vector2(0, -26), float(player.facing))
				if not dash_blocked: enemy.stun = 0.72
				enemy.pos.x += float(player.facing) * 48.0
				dash_hits += 1
		if dash_hits > 0: _play_sound("hit")
		_enemies_alive()
		return
	if is_special and str(hero.kind) == "lunge":
		player.pos.x = clampf(player.pos.x + player.facing * 82.0, 55.0, W - 55.0)
	elif is_special and str(hero.kind) == "phase":
		var nearest: Dictionary = {}
		var nearest_dist: float = float(hero.special_reach)
		for foe in enemies:
			var d: float = player.pos.distance_to(foe.pos)
			if d < nearest_dist:
				nearest = foe
				nearest_dist = d
		if not nearest.is_empty():
			player.pos = nearest.pos + Vector2(-nearest.facing * 48.0, 0)
			player.facing = signf(nearest.pos.x - player.pos.x)
		elif absf(player.facing) > 0.0:
			player.pos.x = clampf(player.pos.x + player.facing * 72.0, 55.0, W - 55.0)
	if is_special and str(hero.kind) == "projectile":
		_add_projectile(true, player.pos, player.facing, damage)
		return
	var hits := 0
	for enemy in enemies:
		var diff: Vector2 = enemy.pos - player.pos
		var in_range: bool = Vector2(diff.x, diff.y).length() < range_x if is_special and str(hero.kind) == "phase" else absf(diff.x) < range_x and absf(diff.y) < range_y and diff.x * player.facing > -22.0
		if in_range:
			var melee_blocked := float(enemy.block_timer) > 0.0
			enemy.hp -= damage * (0.35 if melee_blocked else 1.0)
			_spawn_blood_effect(enemy.pos + Vector2(0, -26), float(player.facing))
			if not melee_blocked: enemy.stun = 0.55 if is_special else 0.34
			enemy.pos.x += player.facing * (54.0 if is_special else 22.0)
			hits += 1
	if hits > 0: _play_sound("hit")
	if not is_special and hits > 0: player.mp = minf(player.max_mp, player.mp + 4.0 * float(hits))
	_enemies_alive()

func _enemies_alive() -> void:
	var alive: Array[Dictionary] = []
	for e in enemies:
		if e.hp > 0.0:
			alive.append(e)
		else:
			corpses.append({"pos": e.pos, "character": e.character, "facing": e.facing, "timer": 0.85, "anim": e.anim})
			score += 100
			player.mp = minf(player.max_mp, player.mp + 5.0)
	enemies = alive

func _update_enemies(delta: float) -> void:
	for enemy in enemies:
		var was_moving := Vector2(enemy.velocity).length() > 0.1
		enemy.anim += delta * 7.0
		enemy.stun = maxf(0.0, enemy.stun - delta)
		enemy.attack = maxf(0.0, enemy.attack - delta)
		enemy.block_timer = maxf(0.0, float(enemy.block_timer) - delta)
		enemy.block_cooldown = maxf(0.0, float(enemy.block_cooldown) - delta)
		enemy.jump_timer = maxf(0.0, float(enemy.jump_timer) - delta)
		enemy.jump_cooldown = maxf(0.0, float(enemy.jump_cooldown) - delta)
		enemy.stop_timer = maxf(0.0, float(enemy.stop_timer) - delta)
		enemy.cooldown = maxf(0.0, enemy.cooldown - delta)
		enemy.ranged_cooldown = maxf(0.0, enemy.ranged_cooldown - delta)
		var diff: Vector2 = player.pos - enemy.pos
		enemy.facing = signf(diff.x) if absf(diff.x) > 4.0 else enemy.facing
		enemy.velocity = Vector2.ZERO
		if enemy.stun > 0.0: continue
		var is_hobbit := int(enemy.character) == 4 or int(enemy.character) == 5
		if is_hobbit and enemy.block_timer > 0.0: continue
		if is_hobbit and enemy.block_cooldown <= 0.0 and absf(diff.x) < 132.0 and absf(diff.y) < 52.0 and randf() < 0.018:
			enemy.block_timer = 0.62
			enemy.block_cooldown = randf_range(2.8, 4.2)
			continue
		if is_hobbit and enemy.jump_cooldown <= 0.0 and absf(diff.x) > 68.0 and absf(diff.x) < 210.0 and randf() < 0.006:
			enemy.jump_timer = 0.62
			enemy.jump_cooldown = randf_range(3.5, 5.0)
		if int(enemy.character) == 2 and absf(diff.x) > 105.0 and absf(diff.x) < 365.0 and absf(diff.y) < 80.0 and enemy.ranged_cooldown <= 0.0:
			_add_projectile(false, enemy.pos, enemy.facing, float(enemy.damage))
			enemy.attack = 0.54
			enemy.attack_frame = 7
			enemy.ranged_cooldown = 2.25
		if absf(diff.x) > 43.0 or absf(diff.y) > 23.0:
			var direction := diff.normalized()
			enemy.velocity = direction
			enemy.pos += direction * float(enemy.speed) * delta
			enemy.stop_timer = 0.0
		else:
			if was_moving: enemy.stop_timer = 0.32
			if enemy.cooldown <= 0.0:
				enemy.attack = 0.46
				enemy.attack_frame = posmod(int(enemy.anim), 3)
				enemy.cooldown = randf_range(0.9, 1.35)
				if player.stun <= 0.0:
					player.hp -= float(enemy.damage)
					_play_sound("hurt")
					player.stun = 0.22
					player.pos.x += enemy.facing * 16.0
		enemy.pos.x = clampf(enemy.pos.x, 46.0, W + 500.0)
		enemy.pos.y = clampf(enemy.pos.y, FLOOR_TOP + 20.0, FLOOR_BOTTOM)
	if player.hp <= 0.0:
		player.hp = 0.0
		game_over = true

func _add_projectile(from_player: bool, position: Vector2, direction: float, damage: float) -> void:
	projectiles.append({"pos": position + Vector2(direction * 38.0, -58.0), "direction": direction, "damage": damage, "speed": 460.0, "life": 1.25, "player_owned": from_player, "anim": elapsed})

func _update_projectiles(delta: float) -> void:
	var active: Array[Dictionary] = []
	var hit_enemy := false
	for shot in projectiles:
		shot.life = float(shot.life) - delta
		shot.pos.x += float(shot.direction) * float(shot.speed) * delta
		shot.anim = float(shot.anim) + delta
		var hit := false
		if bool(shot.player_owned):
			for enemy in enemies:
				if absf(enemy.pos.x - shot.pos.x) < 30.0 and absf(enemy.pos.y - shot.pos.y) < 62.0:
					enemy.hp -= float(shot.damage)
					_spawn_blood_effect(enemy.pos + Vector2(0, -26), float(shot.direction))
					enemy.stun = 0.48
					enemy.pos.x += float(shot.direction) * 40.0
					hit = true
					hit_enemy = true
					break
		else:
			if player.stun <= 0.0 and absf(player.pos.x - shot.pos.x) < 28.0 and absf(player.pos.y - shot.pos.y) < 55.0:
				player.hp -= float(shot.damage)
				_play_sound("hurt")
				player.stun = 0.28
				player.pos.x += float(shot.direction) * 24.0
				hit = true
		if not hit and float(shot.life) > 0.0 and shot.pos.x > -30.0 and shot.pos.x < W + 30.0:
			active.append(shot)
	projectiles = active
	if hit_enemy: _play_sound("hit")
	if hit_enemy: _enemies_alive()
	if player.hp <= 0.0:
		player.hp = 0.0
		game_over = true

func _update_corpses(delta: float) -> void:
	var remaining: Array[Dictionary] = []
	for body in corpses:
		body.timer = float(body.timer) - delta
		body.anim = float(body.anim) + delta
		if float(body.timer) > 0.0: remaining.append(body)
	corpses = remaining

func _select_character(index: int) -> void:
	selected_character = posmod(index, HEROES.size())

func _start_new_game() -> void:
	reset_game()
	has_saved_game = true
	screen_mode = "game"

func _pause_game() -> void:
	screen_mode = "main"
	touch_points.clear()
	touch_axis = Vector2.ZERO
	held = {"left": false, "right": false, "up": false, "down": false, "attack": false, "special": false}

func _resume_after_knockout() -> void:
	if victory:
		_start_new_game()
		return
	game_over = false
	player.hp = player.max_hp
	player.mp = player.max_mp
	player.pos = PLAYER_START
	player.stun = 0.0
	player.attack = 0.0
	player.special = 0.0
	player.dash_remaining = 0.0
	player.dash_finish = 0.0
	player.velocity = Vector2.ZERO
	special_cooldown = 0.0
	intermission_timer = 0.0
	intermission_label = ""
	corpses.clear()
	blood_effects.clear()
	health_pickup.clear()
	_spawn_wave()

func _game_over_touch(p: Vector2) -> void:
	if Rect2(276, 337, 190, 46).has_point(p):
		_resume_after_knockout()
	elif Rect2(494, 337, 190, 46).has_point(p):
		_pause_game()

func _activate_main_option(index: int) -> void:
	menu_selection = index
	match index:
		0: screen_mode = "select"
		1:
			if has_saved_game: screen_mode = "game"
		2: screen_mode = "options"
		3: get_tree().quit()

func _press_main_option(index: int) -> void:
	_play_sound("menu")
	menu_selection = index
	pressed_menu_option = index
	pending_main_option = index
	menu_press_timer = 0.22

func _handle_menu_key(keycode: Key) -> void:
	match screen_mode:
		"main":
			if keycode == KEY_UP: menu_selection = posmod(menu_selection - 1, 4)
			elif keycode == KEY_DOWN: menu_selection = (menu_selection + 1) % 4
			elif keycode == KEY_ENTER or keycode == KEY_KP_ENTER or keycode == KEY_SPACE: _press_main_option(menu_selection)
		"select":
			if keycode == KEY_LEFT: _select_character(selected_character - 1)
			elif keycode == KEY_RIGHT: _select_character(selected_character + 1)
			elif keycode == KEY_ENTER or keycode == KEY_KP_ENTER or keycode == KEY_SPACE:
				menu_selection = 0
				screen_mode = "mode"
			elif keycode == KEY_ESCAPE: screen_mode = "main"
		"mode":
			if keycode == KEY_UP or keycode == KEY_DOWN: menu_selection = 1 - menu_selection
			elif keycode == KEY_ENTER or keycode == KEY_KP_ENTER or keycode == KEY_SPACE:
				game_mode = "survival" if menu_selection == 1 else "stage"
				_start_new_game()
			elif keycode == KEY_ESCAPE: screen_mode = "select"
		"options":
			if keycode == KEY_LEFT: difficulty = posmod(difficulty - 1, 3)
			elif keycode == KEY_RIGHT: difficulty = (difficulty + 1) % 3
			elif keycode == KEY_ENTER or keycode == KEY_KP_ENTER or keycode == KEY_ESCAPE: screen_mode = "main"

func _menu_touch(p: Vector2) -> void:
	if screen_mode == "main":
		for i in range(4):
			var rect := Rect2(26, 308 + i * 44, 302, 38)
			if rect.has_point(p):
				_press_main_option(i)
				return
	elif screen_mode == "select":
		if p.y >= 405.0 and p.y <= 480.0:
			for i in range(HEROES.size()):
				var card_x := 56.0 + float(i) * 290.0
				if p.x >= card_x and p.x <= card_x + 270.0:
					_select_character(i)
					return
		if p.y >= 492.0 and p.y <= 526.0:
			if p.x < 230.0: screen_mode = "main"
			elif p.x >= 738.0:
				menu_selection = 0
				screen_mode = "mode"
	elif screen_mode == "mode":
		if p.y >= 210.0 and p.y <= 290.0:
			game_mode = "stage"
			_start_new_game()
		elif p.y >= 300.0 and p.y <= 380.0:
			game_mode = "survival"
			_start_new_game()
		elif p.y >= 420.0 and p.y <= 500.0: screen_mode = "select"
	elif screen_mode == "options":
		if p.y >= 196.0 and p.y <= 308.0 and p.x >= 145.0 and p.x <= 805.0:
			difficulty = clampi(int((p.x - 145.0) / 225.0), 0, 2)
		elif p.y >= 456.0 and p.y <= 516.0: screen_mode = "main"

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_unlock_audio()
	elif event is InputEventKey and event.pressed and not event.echo:
		_unlock_audio()
	elif event is InputEventMouseButton and event.pressed:
		_unlock_audio()
	if event is InputEventScreenTouch:
		if event.pressed:
			var p: Vector2 = event.position * Vector2(W, H) / get_viewport_rect().size
			if screen_mode != "game":
				_menu_touch(p)
			elif game_over:
				_game_over_touch(p)
			elif p.y < 82.0 and p.x > 860.0:
				_pause_game()
			else:
				touch_points[event.index] = event.position
				_refresh_touch_controls()
		else:
			touch_points.erase(event.index)
			_refresh_touch_controls()
	elif event is InputEventScreenDrag and screen_mode == "game":
		touch_points[event.index] = event.position
		_refresh_touch_controls()
	elif event is InputEventKey and event.pressed and not event.echo:
		if screen_mode == "game":
			if game_over and event.keycode == KEY_ESCAPE:
				_pause_game()
			elif game_over and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER or event.keycode == KEY_R):
				_resume_after_knockout()
			elif event.keycode == KEY_ESCAPE:
				_pause_game()
		else:
			_handle_menu_key(event.keycode)
	elif event is InputEventMouseButton and event.pressed:
		var p: Vector2 = event.position * Vector2(W, H) / get_viewport_rect().size
		if screen_mode == "game":
			if game_over: _game_over_touch(p)
			elif p.y < 82.0 and p.x > 860.0: _pause_game()
		else: _menu_touch(p)
	elif event is InputEventMouseMotion and screen_mode == "main":
		var p: Vector2 = event.position * Vector2(W, H) / get_viewport_rect().size
		for i in range(4):
			if Rect2(63, 272 + i * 52, 320, 42).has_point(p):
				menu_selection = i
				break

func _refresh_touch_controls() -> void:
	held = {"left": false, "right": false, "up": false, "down": false, "attack": false, "special": false}
	touch_axis = Vector2.ZERO
	var stick_center := Vector2(120, 428)
	var attack_center := Vector2(772, 436)
	var special_center := Vector2(875, 374)
	for point in touch_points.values():
		var p: Vector2 = point
		p *= Vector2(W, H) / get_viewport_rect().size
		var stick_delta: Vector2 = p - stick_center
		if stick_delta.length() <= 82.0:
			if stick_delta.length() > 12.0:
				touch_axis = (stick_delta / 56.0).limit_length(1.0)
				if touch_axis.x < -0.16: held.left = true
				elif touch_axis.x > 0.16: held.right = true
				if touch_axis.y < -0.16: held.up = true
				elif touch_axis.y > 0.16: held.down = true
		if p.distance_to(attack_center) <= 64.0: held.attack = true
		if p.distance_to(special_center) <= 60.0: held.special = true

func _draw() -> void:
	if screen_mode != "game":
		if screen_mode == "main" or screen_mode == "mode" or screen_mode == "options":
			texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			draw_texture_rect(MENU_BACKGROUND, Rect2(0, 0, W, H), false)
			texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		else:
			_draw_background()
			_draw_torch_effects()
		_draw_menu()
		return
	_draw_background()
	_draw_floor()
	_draw_torch_effects()
	for body in corpses: _draw_corpse(body)
	_draw_projectiles()
	_draw_health_pickup()
	var fighters: Array[Dictionary] = []
	for enemy in enemies: fighters.append(enemy)
	fighters.append(player)
	fighters.sort_custom(func(a, b): return a.pos.y < b.pos.y)
	for f in fighters:
		_draw_fighter(f, f == player)
	_draw_blood_effects()
	_draw_hud()
	_draw_controls()
	if game_over: _draw_game_over()
	if intermission_timer > 0.0 and not game_over: _draw_intermission()
	var pause_button := StyleBoxFlat.new()
	pause_button.bg_color = Color(0.024, 0.075, 0.11, 0.96)
	pause_button.border_color = Color("83d7e8", 0.82)
	pause_button.set_border_width_all(1)
	pause_button.set_corner_radius_all(6)
	pause_button.shadow_color = Color(0.02, 0.42, 0.65, 0.23)
	pause_button.shadow_size = 5
	pause_button.shadow_offset = Vector2(0, 1)
	draw_style_box(pause_button, Rect2(858, 12, 84, 30))
	draw_colored_polygon(PackedVector2Array([Vector2(873, 18), Vector2(879, 24), Vector2(873, 30), Vector2(867, 24)]), Color("e7c778"))
	draw_string(ThemeDB.fallback_font, Vector2(884, 31), "MENU", HORIZONTAL_ALIGNMENT_LEFT, 48, 11, Color("f4fdff"))

func _draw_menu() -> void:
	if screen_mode == "main":
		draw_rect(Rect2(0, 0, W, H), Color(0.005, 0.018, 0.045, 0.12))
		draw_rect(Rect2(0, 0, 352, H), Color(0.006, 0.025, 0.075, 0.82))
		draw_rect(Rect2(352, 0, 118, H), Color(0.006, 0.025, 0.075, 0.30))
		draw_texture_rect(GAME_LOGO, Rect2(6, 58, 240, 240), false, Color.WHITE)
		draw_string(ThemeDB.fallback_font, Vector2(270, 54), "RFM BRAWL", HORIZONTAL_ALIGNMENT_CENTER, 420, 32, Color("fff0c0"))
		draw_string(ThemeDB.fallback_font, Vector2(270, 81), "CASTLE ARENA", HORIZONTAL_ALIGNMENT_CENTER, 420, 13, Color("83e9ff"))
		draw_line(Vector2(382, 96), Vector2(578, 96), Color(0.50, 0.82, 0.99, 0.58), 1.0)
		var labels := ["START GAME", "RESUME", "OPTIONS", "EXIT GAME"]
		for i in range(labels.size()):
			var disabled := i == 1 and not has_saved_game
			_draw_main_menu_button(Rect2(26, 308 + i * 44, 302, 38), labels[i], i, disabled)
		draw_string(ThemeDB.fallback_font, Vector2(28, 514), "ARROWS + ENTER  /  TOUCH TO SELECT", HORIZONTAL_ALIGNMENT_LEFT, 315, 9, Color("a8bfd6"))
		var brand := StyleBoxFlat.new()
		brand.bg_color = Color(0.012, 0.035, 0.075, 0.88)
		brand.border_color = Color(0.30, 0.73, 0.92, 0.92)
		brand.set_border_width_all(1)
		brand.set_corner_radius_all(8)
		brand.shadow_color = Color(0.02, 0.58, 0.88, 0.26)
		brand.shadow_size = 9
		brand.shadow_offset = Vector2(0, 2)
		draw_style_box(brand, Rect2(742, 482, 202, 42))
		draw_colored_polygon(PackedVector2Array([Vector2(762, 492), Vector2(771, 503), Vector2(762, 514), Vector2(753, 503)]), Color("45c9ee"))
		draw_colored_polygon(PackedVector2Array([Vector2(762, 496), Vector2(767, 503), Vector2(762, 510), Vector2(757, 503)]), Color("ffda84"))
		draw_string(ThemeDB.fallback_font, Vector2(780, 509), "DJHallo Games", HORIZONTAL_ALIGNMENT_LEFT, 150, 14, Color("fff0c0"))
	elif screen_mode == "select":
		var hero: Dictionary = HEROES[selected_character]
		var accent: Color = HERO_COLORS[selected_character]
		draw_texture_rect(MENU_BACKGROUND, Rect2(0, 0, W, H), false)
		draw_rect(Rect2(0, 0, W, H), Color(0.008, 0.022, 0.045, 0.77))
		draw_rect(Rect2(0, 0, W, 5), accent)
		draw_string(ThemeDB.fallback_font, Vector2(0, 43), "CHOOSE YOUR FIGHTER", HORIZONTAL_ALIGNMENT_CENTER, W, 25, Color("fff3d0"))
		draw_string(ThemeDB.fallback_font, Vector2(0, 67), "SELECT A WARRIOR  •  VIEW THEIR SIGNATURE TECHNIQUE", HORIZONTAL_ALIGNMENT_CENTER, W, 10, Color("a9c5dc"))
		var panel := Rect2(42, 84, 876, 304)
		draw_rect(panel, Color(0.012, 0.035, 0.065, 0.91))
		draw_rect(panel, Color(accent.r, accent.g, accent.b, 0.62), false, 2.0)
		draw_rect(Rect2(panel.position + Vector2(5, 5), panel.size - Vector2(10, 10)), Color(0.61, 0.78, 0.90, 0.16), false, 1.0)
		var corner_color := Color(accent.r, accent.g, accent.b, 0.95)
		for corner in [Vector2(48, 104), Vector2(912, 104), Vector2(48, 368), Vector2(912, 368)]:
			var dx := 1.0 if corner.x < W / 2.0 else -1.0
			var dy := 1.0 if corner.y < H / 2.0 else -1.0
			draw_line(corner, corner + Vector2(dx * 15.0, 0), corner_color, 2.0)
			draw_line(corner, corner + Vector2(0, dy * 15.0), corner_color, 2.0)
		draw_circle(Vector2(232, 244), 112, Color(accent.r, accent.g, accent.b, 0.07))
		draw_arc(Vector2(232, 244), 95, 0.0, TAU, 64, Color(accent.r, accent.g, accent.b, 0.65), 2.0, true)
		draw_arc(Vector2(232, 244), 105, 0.0, TAU, 64, Color("f0c77a", 0.38), 1.0, true)
		draw_line(Vector2(410, 105), Vector2(410, 366), Color("79a9c2", 0.34), 1.0)
		var preview_ground_y: float = [291.0, 270.0][selected_character]
		draw_circle(Vector2(232, preview_ground_y + 5.0), 27.0, Color(0, 0, 0, 0.34))
		var idle_strip: Dictionary = shadow_heroes[selected_character].idle
		var preview_frame := int(elapsed * 1.8) % int(idle_strip.frame_count)
		_draw_hero_strip(idle_strip, preview_frame, 232.0, preview_ground_y, float(shadow_heroes[selected_character].preview_scale), false)
		draw_string(ThemeDB.fallback_font, Vector2(452, 139), hero.name, HORIZONTAL_ALIGNMENT_LEFT, 420, 30, Color("fff8e8"))
		draw_string(ThemeDB.fallback_font, Vector2(454, 166), hero.style, HORIZONTAL_ALIGNMENT_LEFT, 400, 12, accent)
		draw_line(Vector2(452, 181), Vector2(874, 181), Color(accent.r, accent.g, accent.b, 0.40), 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(454, 204), hero.description, HORIZONTAL_ALIGNMENT_LEFT, 420, 12, Color("d0dfed"))
		var ability_card := StyleBoxFlat.new()
		ability_card.bg_color = Color(0.018, 0.063, 0.10, 0.96)
		ability_card.border_color = Color(accent.r, accent.g, accent.b, 0.78)
		ability_card.set_border_width_all(1)
		ability_card.set_corner_radius_all(7)
		draw_style_box(ability_card, Rect2(452, 226, 423, 58))
		draw_rect(Rect2(452, 226, 4, 58), accent)
		draw_string(ThemeDB.fallback_font, Vector2(470, 247), "SIGNATURE TECHNIQUE", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("9fb6c9"))
		draw_string(ThemeDB.fallback_font, Vector2(470, 270), hero.ability, HORIZONTAL_ALIGNMENT_LEFT, 390, 17, Color("fff0c0"))
		var stat_names := ["POWER", "SPEED", "RANGE"]
		var stats: Array = hero.stats
		for i in range(stat_names.size()):
			var y := 305.0 + float(i) * 23.0
			draw_string(ThemeDB.fallback_font, Vector2(454, y + 9), stat_names[i], HORIZONTAL_ALIGNMENT_LEFT, 84, 9, Color("a9bdcf"))
			var filled := roundi(float(stats[i]) * 14.0)
			for segment in range(14):
				var segment_rect := Rect2(548.0 + float(segment) * 22.0, y, 19, 8)
				draw_rect(segment_rect, accent.lightened(0.32) if segment < filled else Color("26394e"))
				draw_rect(segment_rect, Color("b5d5e8", 0.15), false, 1.0)
		for i in range(HEROES.size()):
			var x := (W - float(HEROES.size() * 270 + (HEROES.size() - 1) * 20)) / 2.0 + float(i) * 290.0
			var rect := Rect2(x, 405, 270, 75)
			var selected := i == selected_character
			var card_hero: Dictionary = HEROES[i]
			_draw_fighter_select_card(rect, card_hero, HERO_COLORS[i], selected, i)
		_draw_menu_action_button(Rect2(56, 492, 166, 34), "BACK", Color("c0d5e8"), false)
		draw_string(ThemeDB.fallback_font, Vector2(480, 514), "← / → TO BROWSE  •  ENTER TO CONTINUE", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color("95a7ba"))
		_draw_menu_action_button(Rect2(738, 492, 166, 34), "CONTINUE  →", accent, true)
	elif screen_mode == "mode":
		draw_rect(Rect2(0, 0, W, H), Color(0.005, 0.022, 0.052, 0.62))
		draw_rect(Rect2(0, 0, W, 4), Color("d6ae68", 0.94))
		draw_string(ThemeDB.fallback_font, Vector2(0, 56), "CHOOSE GAME MODE", HORIZONTAL_ALIGNMENT_CENTER, W, 29, Color("fff0c0"))
		draw_string(ThemeDB.fallback_font, Vector2(0, 81), "SELECT HOW YOU WANT TO FIGHT", HORIZONTAL_ALIGNMENT_CENTER, W, 10, Color("add0e5"))
		var hero_plate := StyleBoxFlat.new()
		hero_plate.bg_color = Color(0.018, 0.05, 0.09, 0.91)
		hero_plate.border_color = Color(HERO_COLORS[selected_character].r, HERO_COLORS[selected_character].g, HERO_COLORS[selected_character].b, 0.72)
		hero_plate.set_border_width_all(1)
		hero_plate.set_corner_radius_all(8)
		draw_style_box(hero_plate, Rect2(324, 101, 312, 42))
		draw_colored_polygon(PackedVector2Array([Vector2(348, 110), Vector2(357, 122), Vector2(348, 134), Vector2(339, 122)]), HERO_COLORS[selected_character])
		draw_string(ThemeDB.fallback_font, Vector2(371, 128), "%s  ·  %s" % [HEROES[selected_character].name, HEROES[selected_character].style], HORIZONTAL_ALIGNMENT_LEFT, 245, 11, Color("f0f6fb"))
		_draw_game_mode_card(Rect2(220, 176, 520, 96), "STAGE MODE", "Five regions  •  story waves  •  boss battles", menu_selection == 0, Color("e9b85f"), "01")
		_draw_game_mode_card(Rect2(220, 292, 520, 96), "SURVIVAL MODE", "Endless waves  •  climb the arena rankings", menu_selection == 1, Color("64d5ee"), "∞")
		draw_string(ThemeDB.fallback_font, Vector2(W / 2, 454), "↑ / ↓ CHOOSE  •  ENTER CONTINUE  •  ESC BACK", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color("bed0df"))
	elif screen_mode == "options":
		draw_rect(Rect2(0, 0, W, H), Color(0.005, 0.022, 0.052, 0.56))
		draw_rect(Rect2(0, 0, W, 4), Color("d6ae68", 0.94))
		var options_panel := StyleBoxFlat.new()
		options_panel.bg_color = Color(0.008, 0.027, 0.061, 0.82)
		options_panel.border_color = Color("6bc8e1", 0.68)
		options_panel.set_border_width_all(1)
		options_panel.set_corner_radius_all(12)
		options_panel.shadow_color = Color(0.01, 0.32, 0.52, 0.2)
		options_panel.shadow_size = 12
		options_panel.shadow_offset = Vector2(0, 3)
		draw_style_box(options_panel, Rect2(110, 58, 740, 398))
		draw_string(ThemeDB.fallback_font, Vector2(0, 101), "GAME OPTIONS", HORIZONTAL_ALIGNMENT_CENTER, W, 27, Color("fff0c0"))
		draw_string(ThemeDB.fallback_font, Vector2(0, 126), "TUNE THE CHALLENGE", HORIZONTAL_ALIGNMENT_CENTER, W, 10, Color("add0e5"))
		draw_line(Vector2(360, 140), Vector2(600, 140), Color("d6ae68", 0.55), 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(0, 177), "DIFFICULTY", HORIZONTAL_ALIGNMENT_CENTER, W, 12, Color("bbd1e0"))
		var names := ["EASY", "NORMAL", "HARD"]
		var details := ["REGEN 1.8 HP/S", "REGEN 0.65 HP/S", "NO REGEN"]
		for i in range(3):
			_draw_option_difficulty_card(Rect2(145 + i * 225, 196, 210, 112), names[i], details[i], i == difficulty, i)
		var controls := StyleBoxFlat.new()
		controls.bg_color = Color(0.012, 0.044, 0.077, 0.94)
		controls.border_color = Color("8aa9c2", 0.40)
		controls.set_border_width_all(1)
		controls.set_corner_radius_all(7)
		draw_style_box(controls, Rect2(145, 328, 670, 58))
		draw_string(ThemeDB.fallback_font, Vector2(0, 352), "CONTROLS", HORIZONTAL_ALIGNMENT_CENTER, W, 9, Color("8fe0ef"))
		draw_string(ThemeDB.fallback_font, Vector2(0, 373), "WASD / ARROWS  MOVE     •     J  ATTACK     •     K  SPECIAL", HORIZONTAL_ALIGNMENT_CENTER, W, 12, Color("e1ebf2"))
		draw_string(ThemeDB.fallback_font, Vector2(0, 435), "← / → CHANGE DIFFICULTY", HORIZONTAL_ALIGNMENT_CENTER, W, 9, Color("91a9bd"))
		_draw_menu_action_button(Rect2(375, 466, 210, 42), "←  BACK TO MENU", Color("d8b36d"), false)

func _draw_main_menu_button(rect: Rect2, label: String, index: int, disabled: bool) -> void:
	var selected := index == menu_selection
	var press_progress := clampf(1.0 - menu_press_timer / 0.22, 0.0, 1.0) if pressed_menu_option == index else 0.0
	var press_wave := sin(press_progress * PI)
	var scale := 1.0 - 0.055 * press_wave
	var pulse := 0.5 + 0.5 * sin(elapsed * 4.2)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.27, 0.42, 0.78 + 0.08 * pulse) if selected else Color(0.012, 0.055, 0.12, 0.74)
	style.border_color = Color(0.35, 0.86, 0.96, 0.62 + 0.3 * pulse) if selected else Color(0.32, 0.49, 0.66, 0.4)
	style.set_border_width_all(2 if selected else 1)
	style.set_corner_radius_all(8)
	style.shadow_size = 12 if selected else 2
	style.shadow_color = Color(0.08, 0.70, 0.94, 0.24 + 0.14 * pulse) if selected else Color(0, 0, 0, 0.20)
	style.shadow_offset = Vector2(0, 2)
	var center := rect.position + rect.size / 2.0
	draw_set_transform(center, 0.0, Vector2(scale, scale))
	draw_style_box(style, Rect2(-rect.size / 2.0, rect.size))
	var label_color := Color("8797aa") if disabled else Color("f8fbff") if selected else Color("c3d1e1")
	draw_string(ThemeDB.fallback_font, Vector2(-rect.size.x / 2.0 + 20.0, 6.0), "%02d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, 28, 9, Color("83dff0") if selected else Color("71849b"))
	draw_string(ThemeDB.fallback_font, Vector2(-rect.size.x / 2.0 + 62.0, 6.0), label, HORIZONTAL_ALIGNMENT_LEFT, 200, 14, label_color)
	draw_string(ThemeDB.fallback_font, Vector2(rect.size.x / 2.0 - 25.0, 7.0), "›", HORIZONTAL_ALIGNMENT_CENTER, 16, 17, Color("a5eff7") if selected else Color("61758d"))
	if selected: draw_rect(Rect2(-rect.size.x / 2.0 + 58.0, rect.size.y / 2.0 - 5.0, 92.0 + 18.0 * pulse, 1.0), Color(0.4, 0.87, 0.96, 0.48 + 0.3 * pulse))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_menu_card(rect: Rect2, title: String, subtitle: String, selected: bool) -> void:
	draw_rect(rect, Color(0.06, 0.48, 0.58, 0.94) if selected else Color(0.06, 0.12, 0.21, 0.94))
	draw_rect(rect, Color("62e6f5") if selected else Color("304965"), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + rect.size.x / 2, rect.position.y + 33), title, HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color("ffffff"))
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + rect.size.x / 2, rect.position.y + 56), subtitle, HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color("c4d5e4"))

func _draw_option_difficulty_card(rect: Rect2, title: String, subtitle: String, selected: bool, index: int) -> void:
	var accent := Color("e9b85f") if selected else Color("64b9d0")
	var card := StyleBoxFlat.new()
	card.bg_color = Color(0.025, 0.075, 0.12, 0.98) if selected else Color(0.012, 0.035, 0.068, 0.92)
	card.border_color = Color(accent.r, accent.g, accent.b, 0.95 if selected else 0.48)
	card.set_border_width_all(2 if selected else 1)
	card.set_corner_radius_all(9)
	card.shadow_color = Color(accent.r, accent.g, accent.b, 0.22 if selected else 0.06)
	card.shadow_size = 10 if selected else 2
	card.shadow_offset = Vector2(0, 2)
	draw_style_box(card, rect)
	draw_rect(Rect2(rect.position.x + 12, rect.position.y + 14, 3, rect.size.y - 28), accent)
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + 25, rect.position.y + 33), "%02d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, 30, 9, Color(accent.r, accent.g, accent.b, 0.88))
	var text_x := rect.position.x + 26.0
	var text_width := rect.size.x - 52.0
	draw_string(ThemeDB.fallback_font, Vector2(text_x, rect.position.y + 57), title, HORIZONTAL_ALIGNMENT_CENTER, text_width, 17, Color("fff1cf") if selected else Color("e0ebf3"))
	draw_string(ThemeDB.fallback_font, Vector2(text_x, rect.position.y + 79), subtitle, HORIZONTAL_ALIGNMENT_CENTER, text_width, 9, Color("9fb8cb"))
	if selected:
		for segment in range(3):
			var segment_color := accent if segment <= index else Color("293b4e")
			draw_rect(Rect2(rect.position.x + 62 + segment * 32, rect.position.y + 92, 25, 3), segment_color)


func _draw_fighter_select_card(rect: Rect2, hero: Dictionary, accent: Color, selected: bool, index: int) -> void:
	var pulse := 0.5 + 0.5 * sin(elapsed * 3.8)
	var card := StyleBoxFlat.new()
	card.bg_color = Color(0.025, 0.075, 0.12, 0.97) if selected else Color(0.012, 0.032, 0.06, 0.91)
	card.border_color = Color(accent.r, accent.g, accent.b, 0.56 + 0.38 * pulse) if selected else Color("58708a", 0.58)
	card.set_border_width_all(2 if selected else 1)
	card.set_corner_radius_all(8)
	card.shadow_color = Color(accent.r, accent.g, accent.b, 0.16 + 0.12 * pulse) if selected else Color(0, 0, 0, 0.18)
	card.shadow_size = 8 if selected else 2
	card.shadow_offset = Vector2(0, 2)
	draw_style_box(card, rect)
	draw_rect(Rect2(rect.position.x + 11, rect.position.y + 11, 4, rect.size.y - 22), accent if selected else Color(accent.r, accent.g, accent.b, 0.55))
	draw_circle(Vector2(rect.position.x + 34, rect.position.y + rect.size.y / 2.0), 10, Color(accent.r, accent.g, accent.b, 0.14))
	draw_circle(Vector2(rect.position.x + 34, rect.position.y + rect.size.y / 2.0), 5, accent if selected else Color(accent.r, accent.g, accent.b, 0.65))
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + 55, rect.position.y + 31), "%02d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, 26, 9, accent if selected else Color("93a7ba"))
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + 84, rect.position.y + 34), str(hero.name), HORIZONTAL_ALIGNMENT_LEFT, 170, 13, Color("fff5db") if selected else Color("cad8e6"))
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + 84, rect.position.y + 55), str(hero.style), HORIZONTAL_ALIGNMENT_LEFT, 170, 9, accent if selected else Color("91a5b8"))
	if selected:
		draw_rect(Rect2(rect.position.x + 20, rect.end.y - 5, rect.size.x - 40, 2), Color(accent.r, accent.g, accent.b, 0.28 + 0.5 * pulse))
		draw_colored_polygon(PackedVector2Array([Vector2(rect.end.x - 23, rect.position.y + 15), Vector2(rect.end.x - 16, rect.position.y + 23), Vector2(rect.end.x - 23, rect.position.y + 31), Vector2(rect.end.x - 30, rect.position.y + 23)]), accent)

func _draw_menu_action_button(rect: Rect2, label: String, accent: Color, primary: bool) -> void:
	var button := StyleBoxFlat.new()
	button.bg_color = Color(accent.r, accent.g, accent.b, 0.92) if primary else Color(0.02, 0.055, 0.09, 0.92)
	button.border_color = Color("fff0c0", 0.85) if primary else Color(accent.r, accent.g, accent.b, 0.72)
	button.set_border_width_all(1)
	button.set_corner_radius_all(7)
	button.shadow_color = Color(accent.r, accent.g, accent.b, 0.24) if primary else Color(0, 0, 0, 0.18)
	button.shadow_size = 6 if primary else 2
	button.shadow_offset = Vector2(0, 2)
	draw_style_box(button, rect)
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x, rect.position.y + rect.size.y / 2.0 + 4.0), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 11, Color("081a28") if primary else Color("e5eef6"))

func _draw_hero_strip(strip: Dictionary, frame: int, x: float, ground_y: float, scale: float, flip_x: bool, modulate: Color = Color.WHITE) -> void:
	var tex := strip.texture as Texture2D
	if tex == null: return
	var frame_width := float(strip.frame_width)
	var frame_height := float(strip.frame_height)
	var frame_count := int(strip.frame_count)
	var sx := -scale if flip_x else scale
	var src := Rect2(float(clampi(frame, 0, frame_count - 1)) * frame_width, 0.0, frame_width, frame_height)
	draw_set_transform(Vector2(x, ground_y), 0.0, Vector2(sx, scale))
	draw_texture_rect_region(tex, Rect2(-float(strip.pivot_x), -float(strip.pivot_y), frame_width, frame_height), src, modulate)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_background() -> void:
	draw_texture_rect(CASTLE_BACKGROUND, Rect2(0, -45, W, 648), false)
	draw_rect(Rect2(0, 500, W, 40), Color(0.025, 0.04, 0.07, 0.56))

func _draw_torch_effects() -> void:
	for i in range(TORCHES.size()):
		var torch: Vector2 = TORCHES[i]
		var phase := elapsed * 8.0 + float(i) * 1.73
		var flicker := 0.72 + 0.18 * sin(phase) + 0.10 * sin(phase * 2.31)
		var sway := sin(phase * 0.83) * 1.6
		var flame_x := torch.x + sway
		var flame_base := torch.y + 8.0
		var flame_height := 10.0 + 3.0 * flicker
		var flame_center := Vector2(flame_x, flame_base - flame_height * 0.48)
		draw_circle(flame_center, 18.0 + 3.0 * flicker, Color(1.0, 0.37, 0.06, 0.08 * flicker))
		draw_circle(flame_center, 9.0 + 1.5 * flicker, Color(1.0, 0.48, 0.08, 0.12 * flicker))
		if not torch_fire_frames.is_empty():
			var flame_frame := posmod(int(elapsed * 12.0 + float(i) * 1.37), torch_fire_frames.size())
			draw_texture_rect(torch_fire_frames[flame_frame], Rect2(flame_x - 12.0, flame_base - 36.0, 24.0, 36.0), false, Color(1.0, 0.94, 0.82, 0.82 + 0.18 * flicker))
		for segment in range(6):
			var y := 294.0 + float(segment) * 17.0
			var alpha := (0.115 - float(segment) * 0.014) * flicker
			var reflection_x := torch.x + sin(phase * 0.47 + float(segment)) * (2.0 + float(segment))
			draw_line(Vector2(reflection_x, y), Vector2(reflection_x + sway, y + 10.0), Color(1.0, 0.46, 0.12, alpha), 4.5 - float(segment) * 0.48)

func _spawn_blood_effect(position: Vector2, direction: float) -> void:
	if blood_frames.is_empty(): return
	blood_effects.append({"pos": position, "time": 0.36, "duration": 0.36, "direction": direction})

func _update_blood_effects(delta: float) -> void:
	var remaining: Array[Dictionary] = []
	for effect in blood_effects:
		effect.time = float(effect.time) - delta
		if float(effect.time) > 0.0: remaining.append(effect)
	blood_effects = remaining

func _draw_blood_effects() -> void:
	for effect in blood_effects:
		var progress := clampf(1.0 - float(effect.time) / float(effect.duration), 0.0, 1.0)
		var frame := clampi(int(progress * float(blood_frames.size())), 0, blood_frames.size() - 1)
		var pos: Vector2 = effect.pos
		var alpha := 1.0 if progress < 0.55 else (1.0 - progress) / 0.45
		var size := Vector2(64.0, 54.0) * (0.78 + progress * 0.25)
		draw_set_transform(pos, 0.0, Vector2(-1.0, 1.0) if float(effect.direction) < 0.0 else Vector2.ONE)
		draw_texture_rect(blood_frames[frame], Rect2(-size.x * 0.5, -size.y * 0.5, size.x, size.y), false, Color(1.0, 0.72, 0.74, alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_game_mode_card(rect: Rect2, title: String, subtitle: String, selected: bool, accent: Color, index: String) -> void:
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.024, 0.071, 0.12, 0.96) if selected else Color(0.008, 0.027, 0.061, 0.92)
	panel.border_color = Color(accent.r, accent.g, accent.b, 0.98 if selected else 0.42)
	panel.set_border_width_all(2 if selected else 1)
	panel.set_corner_radius_all(9)
	panel.shadow_color = Color(accent.r, accent.g, accent.b, 0.22 if selected else 0.06)
	panel.shadow_size = 12 if selected else 2
	panel.shadow_offset = Vector2(0, 2)
	draw_style_box(panel, rect)
	draw_rect(Rect2(rect.position.x, rect.position.y + 12, 4, rect.size.y - 24), accent)
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + 26, rect.position.y + 37), index, HORIZONTAL_ALIGNMENT_LEFT, 40, 20, accent)
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + 82, rect.position.y + 39), title, HORIZONTAL_ALIGNMENT_LEFT, 390, 19, Color("fff3d0") if selected else Color("e0ebf3"))
	draw_string(ThemeDB.fallback_font, Vector2(rect.position.x + 82, rect.position.y + 66), subtitle, HORIZONTAL_ALIGNMENT_LEFT, 410, 11, Color("b7ccdc"))
	if selected:
		draw_string(ThemeDB.fallback_font, Vector2(rect.end.x - 34, rect.position.y + 57), "›", HORIZONTAL_ALIGNMENT_CENTER, 18, 23, accent)

func _draw_floor() -> void:
	draw_rect(Rect2(0, FLOOR_TOP, W, FLOOR_BOTTOM - FLOOR_TOP), Color(0.025, 0.045, 0.075, 0.07))

func _draw_fighter(f: Dictionary, is_player: bool) -> void:
	var p: Vector2 = f.pos
	var facing := float(f.facing)
	var character := int(f.character)
	var is_hobbit := not is_player and (character == 4 or character == 5)
	var is_wetlands_boss := not is_player and character == 6
	var bar_w := 42.0 if not bool(f.get("boss", false)) else 62.0
	draw_circle(Vector2(p.x, p.y - 1), 15.0 if is_hobbit else (12.0 if not bool(f.get("boss", false)) else 18.0), Color(0, 0, 0, 0.32))
	if is_player:
		_draw_shadow_hero(f)
	elif is_hobbit:
		_draw_hobbit_fighter(f)
	elif is_wetlands_boss:
		_draw_wetlands_boss(f)
	else:
		_draw_pack_fighter(f)
	var bar_offset := 62.0 if is_hobbit else 94.0 if is_wetlands_boss else 66.0
	if bool(f.get("boss", false)): bar_offset = 94.0
	var bar_y := p.y - bar_offset
	var bar_rect := Rect2(p.x - bar_w / 2.0, bar_y, bar_w, 6.0)
	draw_rect(bar_rect, Color(0.012, 0.027, 0.047, 0.92))
	draw_rect(Rect2(bar_rect.position + Vector2(1, 1), Vector2((bar_w - 2) * clampf(float(f.hp) / float(f.max_hp), 0, 1), 4)), Color("50e2b1") if is_player else Color("f25370"))
	draw_rect(bar_rect, Color("9dc5d8", 0.68), false, 1.0)

func _draw_shadow_hero(f: Dictionary) -> void:
	var character := clampi(int(f.character), 0, shadow_heroes.size() - 1)
	var animations: Dictionary = shadow_heroes[character]
	var state := "idle"
	if game_over: state = "death"
	elif float(f.stun) > 0.0: state = "hit"
	elif float(f.special) > 0.0: state = "special_attack"
	elif float(f.attack) > 0.0: state = "attack"
	elif character == 1 and float(f.dash_finish) > 0.0: state = "dash_finish"
	elif Vector2(f.velocity).length() > 0.1:
		if float(f.velocity.y) < -0.1:
			state = "mid_air" if character == 1 and int(float(f.anim) * 0.75) % 2 == 1 else "jump"
		elif float(f.velocity.y) > 0.1: state = "fall"
		else: state = "run"
	var strip: Dictionary = animations.get(state, animations.idle)
	if state == "attack":
		var combo_attacks: Array = animations.attack_combo
		strip = combo_attacks[posmod(int(f.attack_frame) - 4, combo_attacks.size())]
	if state == "special_attack" and character == 1:
		var dash_progress := clampf(1.0 - float(f.special) / 0.56, 0.0, 1.0)
		if dash_progress < 0.14: strip = animations.dash
		elif dash_progress > 0.84: strip = animations.dash_attack
	elif state == "dash_finish":
		strip = animations.dash_attack
	var frame_count := int(strip.frame_count)
	var frame := int(float(f.anim) * 1.8) % frame_count
	var attack_progress := 0.0
	if state == "attack" or state == "special_attack":
		var duration := 0.56 if float(f.special) > 0.0 else 0.44
		var remaining := maxf(float(f.attack), float(f.special))
		attack_progress = clampf(1.0 - remaining / duration, 0.0, 1.0)
		frame = clampi(int(attack_progress * frame_count), 0, frame_count - 1)
	elif state == "dash_finish":
		frame = frame_count - 1
	var tint := Color("ffaaaa") if state == "hit" else Color.WHITE
	var draw_x := float(f.pos.x)
	var draw_y := float(f.pos.y)
	var draw_scale := float(animations.scale)
	if state == "idle":
		draw_y -= sin(float(f.anim) * 2.8) * 1.4
	elif state == "run":
		draw_y -= absf(sin(float(f.anim) * 8.0)) * 2.2
	elif state == "attack" or state == "special_attack":
		draw_x += float(f.facing) * sin(attack_progress * PI) * (9.0 if character == 0 else 4.0)
		draw_y -= sin(attack_progress * PI) * (2.0 if character == 0 else 1.0)
		draw_scale *= 1.0 + sin(attack_progress * PI) * 0.035
	_draw_hero_strip(strip, frame, draw_x, draw_y, draw_scale, float(f.facing) < 0.0, tint)
	if character == 0 and (state == "attack" or state == "special_attack"):
		var slash_alpha := sin(attack_progress * PI) * 0.72
		var slash_center := Vector2(draw_x + float(f.facing) * 12.0, draw_y - 28.0)
		var slash_start := -1.0 if float(f.facing) > 0.0 else PI - 1.0
		var slash_end := 1.0 if float(f.facing) > 0.0 else PI + 1.0
		draw_arc(slash_center, 35.0, slash_start, slash_end, 18, Color(1.0, 0.68, 0.25, slash_alpha), 2.5, true)

func _draw_wetlands_boss(f: Dictionary) -> void:
	var strip: Dictionary = wetlands_animations.idle
	var frame := int(float(f.anim) * 1.4) % int(strip.frame_count)
	if float(f.stun) > 0.0:
		strip = wetlands_animations.hit
		frame = 0
	elif float(f.attack) > 0.0:
		var progress := clampf(1.0 - float(f.attack) / 0.46, 0.0, 1.0)
		match posmod(int(f.attack_frame), 3):
			0:
				strip = wetlands_animations.attack1
				frame = clampi(int(progress * float(strip.frame_count)), 0, int(strip.frame_count) - 1)
			1:
				strip = wetlands_animations.attack2
				frame = clampi(int(progress * float(strip.frame_count)), 0, int(strip.frame_count) - 1)
			_:
				if progress < 0.24:
					strip = wetlands_animations.pre_attack
					frame = clampi(int(progress / 0.24 * float(strip.frame_count)), 0, int(strip.frame_count) - 1)
				elif progress < 0.72:
					strip = wetlands_animations.mid_attack
					frame = clampi(int((progress - 0.24) / 0.48 * float(strip.frame_count)), 0, int(strip.frame_count) - 1)
				else:
					strip = wetlands_animations.end_attack
					frame = clampi(int((progress - 0.72) / 0.28 * float(strip.frame_count)), 0, int(strip.frame_count) - 1)
	elif Vector2(f.velocity).length() > 0.1:
		strip = wetlands_animations.run
		frame = int(float(f.anim) * 1.4) % int(strip.frame_count)
	_draw_hero_strip(strip, frame, f.pos.x, f.pos.y, 1.45, float(f.facing) < 0.0)

func _draw_hobbit_fighter(f: Dictionary) -> void:
	var frames: Array[Texture2D] = hobbit_idle
	var frame := int(float(f.anim) * 1.5) % maxi(1, frames.size())
	if float(f.stun) > 0.0 and not hobbit_hit.is_empty():
		frames = hobbit_hit
		frame = int(float(f.anim) * 8.0) % frames.size()
	elif float(f.block_timer) > 0.0 and not hobbit_block.is_empty():
		frames = hobbit_block
		frame = int(float(f.anim) * 13.0) % frames.size()
	elif float(f.attack) > 0.0 and not hobbit_attack.is_empty():
		frames = hobbit_attack
		frame = clampi(int((1.0 - float(f.attack) / 0.46) * frames.size()), 0, frames.size() - 1)
	elif float(f.jump_timer) > 0.0 and not hobbit_jump.is_empty():
		frames = hobbit_jump
		var jump_progress := clampf(1.0 - float(f.jump_timer) / 0.62, 0.0, 1.0)
		frame = clampi(int(jump_progress * frames.size()), 0, frames.size() - 1)
	elif Vector2(f.velocity).length() > 0.1 and not hobbit_run.is_empty():
		frames = hobbit_run
		frame = int(float(f.anim) * 1.5) % frames.size()
	elif float(f.stop_timer) > 0.0 and not hobbit_stop.is_empty():
		frames = hobbit_stop
		frame = clampi(int((1.0 - float(f.stop_timer) / 0.32) * frames.size()), 0, frames.size() - 1)
	var draw_pos: Vector2 = f.pos
	if float(f.jump_timer) > 0.0:
		var draw_jump_progress := clampf(1.0 - float(f.jump_timer) / 0.62, 0.0, 1.0)
		draw_pos.y -= sin(draw_jump_progress * PI) * 24.0
	_draw_hobbit_frame(frames, frame, draw_pos, float(f.facing), 2.0 * (1.12 if bool(f.get("boss", false)) else 1.0))

func _draw_hobbit_frame(frames: Array[Texture2D], frame: int, p: Vector2, facing: float, scale: float, alpha: float = 1.0) -> void:
	if frames.is_empty(): return
	var tex := frames[clampi(frame, 0, frames.size() - 1)]
	var sx := -scale if facing < 0.0 else scale
	draw_set_transform(Vector2(p.x, p.y), 0.0, Vector2(sx, scale))
	draw_texture_rect(tex, Rect2(-32.0, -38.0, 64.0, 64.0), false, Color(1, 1, 1, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_pack_fighter(f: Dictionary) -> void:
	var orc := int(f.character) == 1 or int(f.character) == 3
	var frame := 0
	var tex: Texture2D = ORC_IDLE if orc else SOLDIER_IDLE
	if float(f.stun) > 0.0:
		tex = ORC_HURT if orc else SOLDIER_HURT
	elif float(f.attack) > 0.0:
		if orc:
			tex = ORC_ATTACK_2 if int(float(f.anim) * 2.0) % 2 == 1 else ORC_ATTACK_1
		else:
			match int(f.attack_frame) % 3:
				0: tex = SOLDIER_ATTACK_1
				1: tex = SOLDIER_ATTACK_2
				_: tex = SOLDIER_ATTACK_3
	elif Vector2(f.velocity).length() > 0.1:
		tex = ORC_WALK if orc else SOLDIER_WALK
	elif bool(f.get("dead", false)):
		tex = ORC_DEATH if orc else SOLDIER_DEATH
	frame = int(float(f.anim) * (2.5 if float(f.attack) > 0.0 else 1.6)) % maxi(1, int(tex.get_width() / 100))
	var size := 3.4 if bool(f.get("boss", false)) else 3.0
	_draw_enemy_strip_frame(tex, frame, f.pos.x, f.pos.y, size, float(f.facing) < 0.0)

func _draw_enemy_strip_frame(tex: Texture2D, frame: int, center_x: float, ground_y: float, scale: float, flip_x: bool, modulate: Color = Color.WHITE) -> void:
	var frame_count := maxi(1, int(tex.get_width() / 100))
	var src := Rect2(float(clampi(frame, 0, frame_count - 1)) * 100.0, 0.0, 100.0, 100.0)
	var sx := -scale if flip_x else scale
	draw_set_transform(Vector2(center_x, ground_y), 0.0, Vector2(sx, scale))
	draw_texture_rect_region(tex, Rect2(-50.0, -56.0, 100.0, 100.0), src, modulate)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_corpse(body: Dictionary) -> void:
	var p: Vector2 = body.pos
	var alpha: float = clampf(float(body.timer) / 0.85, 0.0, 1.0)
	if int(body.character) == 4 or int(body.character) == 5:
		var frame := clampi(int((1.0 - float(body.timer) / 0.85) * hobbit_death.size()), 0, maxi(0, hobbit_death.size() - 1))
		_draw_hobbit_frame(hobbit_death, frame, p, float(body.facing), 2.0, alpha)
	elif int(body.character) == 6:
		var death_strip: Dictionary = wetlands_animations.death
		var frame := clampi(int((1.0 - float(body.timer) / 0.85) * float(death_strip.frame_count)), 0, int(death_strip.frame_count) - 1)
		_draw_hero_strip(death_strip, frame, p.x, p.y, 1.45, float(body.facing) < 0.0, Color(1, 1, 1, alpha))
	else:
		var orc := int(body.character) == 1 or int(body.character) == 3
		var death_tex: Texture2D = ORC_DEATH if orc else SOLDIER_DEATH
		_draw_enemy_strip_frame(death_tex, int(death_tex.get_width() / 100) - 1, p.x, p.y, 3.0, float(body.facing) < 0.0, Color(1, 1, 1, alpha))

func _draw_health_pickup() -> void:
	if health_pickup.is_empty(): return
	var p: Vector2 = health_pickup.pos
	draw_circle(p, 18.0, Color(0.18, 0.9, 0.64, 0.18))
	draw_rect(Rect2(p.x - 7, p.y - 17, 14, 28), Color("f4fff8"))
	draw_rect(Rect2(p.x - 4, p.y - 22, 8, 6), Color("b8d8d3"))
	draw_rect(Rect2(p.x - 7, p.y - 5, 14, 16), Color("57e0a4"))
	draw_string(ThemeDB.fallback_font, Vector2(p.x, p.y + 31), "MILK", HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color("f4fff8"))

func _draw_intermission() -> void:
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.006, 0.025, 0.06, 0.92)
	panel.border_color = Color("63d8ec", 0.82)
	panel.set_border_width_all(1)
	panel.set_corner_radius_all(9)
	panel.shadow_color = Color(0.02, 0.47, 0.67, 0.18)
	panel.shadow_size = 10
	panel.shadow_offset = Vector2(0, 2)
	draw_style_box(panel, Rect2(150, 194, 660, 92))
	draw_string(ThemeDB.fallback_font, Vector2(150, 231), intermission_label, HORIZONTAL_ALIGNMENT_CENTER, 660, 23, Color("fff0c0"))
	var stage_text := "SURVIVAL · WAVE %02d COMPLETED" % maxi(wave - 1, 1)
	if game_mode == "stage":
		if intermission_label == "ACT COMPLETED":
			stage_text = "STAGE %02d  ·  NEXT ACT %02d/05" % [stage_number, act_number]
		elif intermission_label == "STAGE COMPLETED":
			stage_text = "NEXT STAGE %02d  ·  %s" % [stage_number, STAGE_NAMES[stage_number - 1]]
		else:
			stage_text = "STAGE %02d  ·  ACT %02d/05" % [stage_number, act_number]
	draw_string(ThemeDB.fallback_font, Vector2(150, 261), stage_text, HORIZONTAL_ALIGNMENT_CENTER, 660, 12, Color("9ed9e9"))

func _draw_projectiles() -> void:
	for shot in projectiles:
		var p: Vector2 = shot.pos
		var tint := Color("62e6f5") if bool(shot.player_owned) else Color("b17cff")
		draw_line(p - Vector2(float(shot.direction) * 29.0, 0), p, Color(tint.r, tint.g, tint.b, 0.46), 8.0)
		draw_circle(p, 9.0 + sin(float(shot.anim) * 23.0) * 2.0, tint)

func _draw_hud() -> void:
	draw_rect(Rect2(0, 0, W, 88), Color(0.012, 0.028, 0.065, 0.97))
	draw_rect(Rect2(0, 0, W, 2), Color("d8ad64", 0.88))
	draw_rect(Rect2(0, 85, W, 3), Color("46c7e7", 0.68))
	var brand_panel := StyleBoxFlat.new()
	brand_panel.bg_color = Color(0.024, 0.058, 0.095, 0.96)
	brand_panel.border_color = Color("7098b3", 0.55)
	brand_panel.set_border_width_all(1)
	brand_panel.set_corner_radius_all(7)
	draw_style_box(brand_panel, Rect2(12, 10, 205, 67))
	draw_string(ThemeDB.fallback_font, Vector2(27, 34), "RFM BRAWL", HORIZONTAL_ALIGNMENT_LEFT, 172, 19, Color("fff0c0"))
	draw_string(ThemeDB.fallback_font, Vector2(28, 57), "STAGE MODE" if game_mode == "stage" else "SURVIVAL MODE", HORIZONTAL_ALIGNMENT_LEFT, 172, 10, Color("78e2f5"))
	var hero: Dictionary = HEROES[selected_character]
	var combat_panel := StyleBoxFlat.new()
	combat_panel.bg_color = Color(0.024, 0.058, 0.095, 0.96)
	combat_panel.border_color = Color("496b87", 0.64)
	combat_panel.set_border_width_all(1)
	combat_panel.set_corner_radius_all(7)
	draw_style_box(combat_panel, Rect2(228, 10, 379, 67))
	draw_string(ThemeDB.fallback_font, Vector2(244, 31), "%s  ·  %s" % [hero.name, hero.style], HORIZONTAL_ALIGNMENT_LEFT, 245, 11, Color("e7f0f8"))
	draw_string(ThemeDB.fallback_font, Vector2(440, 31), hero.ability, HORIZONTAL_ALIGNMENT_RIGHT, 151, 9, Color("7be6f7"))
	var special_ready: bool = special_cooldown <= 0.0 and float(player.mp) >= float(hero.mp_cost)
	var special_gem := Color("6cecff") if special_ready else Color("667b91")
	draw_colored_polygon(PackedVector2Array([Vector2(592, 20), Vector2(597, 25), Vector2(592, 30), Vector2(587, 25)]), special_gem)
	_draw_pixel_heart(Vector2(250, 46), Color("ef4054"))
	var hp_bar := Rect2(266, 39, 324, 14)
	_draw_resource_bar(hp_bar, clampf(float(player.hp) / float(player.max_hp), 0.0, 1.0), Color("ed3349"), Color("ffd17a"))
	_draw_pixel_star(Vector2(250, 65), Color("258eea"))
	var mp_bar := Rect2(266, 58, 324, 14)
	_draw_resource_bar(mp_bar, clampf(float(player.mp) / float(player.max_mp), 0.0, 1.0), Color("247ff1"), Color("7bc8ff"))
	var progress := "STAGE %02d ACT %02d/05 WAVE %d/%d" % [stage_number, act_number, wave_in_act, WAVES_PER_ACT] if game_mode == "stage" else "SURVIVAL WAVE %02d" % wave
	var info_panel := StyleBoxFlat.new()
	info_panel.bg_color = Color(0.024, 0.058, 0.095, 0.96)
	info_panel.border_color = Color("947a50", 0.62)
	info_panel.set_border_width_all(1)
	info_panel.set_corner_radius_all(7)
	draw_style_box(info_panel, Rect2(618, 10, 230, 67))
	draw_string(ThemeDB.fallback_font, Vector2(632, 34), progress, HORIZONTAL_ALIGNMENT_LEFT, 207, 9, Color("fff0c0"))
	var boss_name := ""
	for foe in enemies:
		if bool(foe.boss): boss_name = str(ENEMY_TYPES[int(foe.character)])
	draw_string(ThemeDB.fallback_font, Vector2(632, 59), "BOSS: " + boss_name if not boss_name.is_empty() else "SCORE  %06d" % score, HORIZONTAL_ALIGNMENT_LEFT, 207, 11, Color("ff8a96") if not boss_name.is_empty() else Color("a8bed2"))
	var touch_mode := DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")
	if not touch_mode:
		draw_string(ThemeDB.fallback_font, Vector2(20, 525), "WASD MOVE     J COMBO     K SPECIAL     ESC MENU", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.68, 0.78, 0.88, 0.78))

func _draw_pixel_heart(center: Vector2, color: Color) -> void:
	var rows := ["0110110", "1111111", "1111111", "0111110", "0011100", "0001000"]
	for y in range(rows.size()):
		for x in range(rows[y].length()):
			if rows[y][x] == "1":
				draw_rect(Rect2(center.x - 7.0 + float(x) * 2.0, center.y - 6.0 + float(y) * 2.0, 2, 2), color)

func _draw_pixel_star(center: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(10):
		var angle := -PI / 2.0 + float(i) * PI / 5.0
		var radius := 9.0 if i % 2 == 0 else 4.2
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, color)
	draw_line(center + Vector2(-4, 0), center + Vector2(4, 0), Color(0.72, 0.91, 1.0, 0.8), 1.0)

func _draw_resource_bar(rect: Rect2, ratio: float, fill: Color, highlight: Color) -> void:
	draw_rect(rect, Color("101b2a"))
	var inner := Rect2(rect.position + Vector2(2, 2), Vector2(maxf(0.0, rect.size.x - 4.0), maxf(0.0, rect.size.y - 4.0)))
	var filled_width := inner.size.x * clampf(ratio, 0.0, 1.0)
	if filled_width > 0.0:
		draw_rect(Rect2(inner.position, Vector2(filled_width, inner.size.y)), fill)
		draw_rect(Rect2(inner.position, Vector2(filled_width, 2.0)), highlight)
	draw_rect(rect, Color("c99d57"), false, 1.0)
	draw_rect(Rect2(rect.position + Vector2(1, 1), rect.size - Vector2(2, 2)), Color(0.04, 0.07, 0.11, 0.9), false, 1.0)

func _draw_controls() -> void:
	var touch_mode := DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")
	if not touch_mode: return
	var stick_center := Vector2(120, 428)
	var stick_active := touch_axis.length() > 0.1
	draw_circle(stick_center + Vector2(0, 5), 73, Color(0.0, 0.0, 0.0, 0.28))
	draw_circle(stick_center, 70, Color(0.012, 0.033, 0.064, 0.55))
	draw_arc(stick_center, 70, 0, TAU, 64, Color("d2aa66", 0.72), 2.0)
	draw_arc(stick_center, 62, 0, TAU, 64, Color("62d4ee", 0.35), 1.0)
	for i in range(8):
		var angle := float(i) * TAU / 8.0
		var inner := stick_center + Vector2(cos(angle), sin(angle)) * 63.0
		var outer := stick_center + Vector2(cos(angle), sin(angle)) * 68.0
		draw_line(inner, outer, Color("e8c67d", 0.75), 2.0)
	var knob_center := stick_center + touch_axis * 30.0
	draw_circle(knob_center, 34, Color(0.04, 0.17, 0.27, 0.86))
	draw_circle(knob_center, 31, Color("102d43", 0.96))
	draw_arc(knob_center, 31, 0, TAU, 48, Color("70dff1", 0.92) if stick_active else Color("92b5c9", 0.76), 2.0)
	draw_arc(knob_center - Vector2(2, 2), 22, PI * 1.05, PI * 1.85, 24, Color("ffffff", 0.30), 2.0)
	draw_line(knob_center + Vector2(-13, 0), knob_center + Vector2(13, 0), Color("62d4ee", 0.42), 1.0)
	draw_line(knob_center + Vector2(0, -13), knob_center + Vector2(0, 13), Color("62d4ee", 0.42), 1.0)
	draw_string(ThemeDB.fallback_font, Vector2(79, 518), "MOVE", HORIZONTAL_ALIGNMENT_CENTER, 82, 9, Color("d6e6ef", 0.88))
	_draw_touch_action_button(Vector2(772, 436), 53.0, "ATTACK", "J · COMBO", held.attack, Color("edbd67"), false)
	_draw_touch_action_button(Vector2(875, 374), 49.0, "SPECIAL", "K · SKILL", held.special, Color("64d9f0"), true)

func _draw_touch_action_button(center: Vector2, radius: float, label: String, hint: String, active: bool, accent: Color, is_special: bool) -> void:
	var glow_alpha := 0.27 if active else 0.12
	draw_circle(center, radius + 8.0, Color(accent.r, accent.g, accent.b, glow_alpha * 0.35))
	draw_circle(center + Vector2(0, 4), radius + 2.0, Color(0.0, 0.0, 0.0, 0.38))
	draw_circle(center, radius, Color("111e2b", 0.96))
	draw_circle(center, radius - 4.0, Color(accent.r, accent.g, accent.b, 0.20 if active else 0.10))
	draw_arc(center, radius, 0, TAU, 56, Color(accent.r, accent.g, accent.b, 0.98 if active else 0.78), 3.0 if active else 2.0)
	draw_arc(center, radius - 6.0, PI * 1.08, PI * 1.92, 32, Color("fff0c0", 0.52), 1.0)
	if is_special:
		var gem := PackedVector2Array([center + Vector2(0, -21), center + Vector2(15, -6), center + Vector2(0, 9), center + Vector2(-15, -6)])
		draw_colored_polygon(gem, accent.lightened(0.12))
		draw_line(center + Vector2(-6, -7), center + Vector2(6, -7), Color("ffffff", 0.72), 2.0)
	else:
		draw_line(center + Vector2(-10, 8), center + Vector2(12, -15), Color("f5d487"), 5.0)
		draw_line(center + Vector2(-13, 1), center + Vector2(-3, 11), Color("fff0c0"), 3.0)
		draw_line(center + Vector2(3, -9), center + Vector2(13, -3), accent, 3.0)
	draw_string(ThemeDB.fallback_font, Vector2(center.x - radius, center.y + radius * 0.53), label, HORIZONTAL_ALIGNMENT_CENTER, radius * 2.0, 9, Color("fff4d9") if active else Color("e8f3f8"))
	draw_string(ThemeDB.fallback_font, Vector2(center.x - radius, center.y + radius * 0.77), hint, HORIZONTAL_ALIGNMENT_CENTER, radius * 2.0, 7, Color(accent.r, accent.g, accent.b, 0.94))

func _draw_game_over() -> void:
	draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.70))
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.008, 0.028, 0.065, 0.98)
	panel.border_color = Color("d7ad67", 0.88) if victory else Color("66d7ec", 0.88)
	panel.set_border_width_all(2)
	panel.set_corner_radius_all(12)
	panel.shadow_color = Color(0.01, 0.45, 0.70, 0.3)
	panel.shadow_size = 16
	panel.shadow_offset = Vector2(0, 3)
	draw_style_box(panel, Rect2(238, 144, 484, 260))
	draw_rect(Rect2(258, 158, 444, 2), Color("d7ad67", 0.78))
	draw_string(ThemeDB.fallback_font, Vector2(238, 218), "CAMPAIGN COMPLETE" if victory else "KNOCKED OUT", HORIZONTAL_ALIGNMENT_CENTER, 484, 30, Color("fff0c0") if victory else Color("f7f4ef"))
	draw_string(ThemeDB.fallback_font, Vector2(238, 260), "SCORE  %06d" % score, HORIZONTAL_ALIGNMENT_CENTER, 484, 16, Color("71dff2"))
	draw_string(ThemeDB.fallback_font, Vector2(238, 292), "YOUR RUN IS OVER" if not victory else "THE CASTLE IS SAFE", HORIZONTAL_ALIGNMENT_CENTER, 484, 10, Color("a7bfd1"))
	_draw_menu_action_button(Rect2(276, 337, 190, 46), "PLAY AGAIN" if victory else "RESUME", Color("e9b85f"), true)
	_draw_menu_action_button(Rect2(494, 337, 190, 46), "OPEN MENU", Color("67d5e9"), false)
	draw_string(ThemeDB.fallback_font, Vector2(238, 397), "ENTER / R  RESUME     •     ESC  MENU", HORIZONTAL_ALIGNMENT_CENTER, 484, 9, Color("849bad"))
