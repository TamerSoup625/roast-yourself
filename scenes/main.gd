extends Node


@onready var boss = %Boss
@onready var player = %Player
@onready var ui = %UI
@onready var game_over = %GameOver
@onready var pause_menu = %PauseMenu
@onready var music = %Music
@onready var overlays = %Overlays
@onready var boss_defeat_sfx = %BossDefeatSfx
@onready var boss_defeat_sfx_big = %BossDefeatSfxBig


func _ready():
	music.play(30)
	#music.play(47.13)


func _physics_process(_delta):
	boss.set_target_pos(player.position)


func _on_player_instantiate_this(node):
	add_child(node)


func _input(event):
	if OS.is_debug_build():
		if event.is_action_pressed("debug_time_plus"):
			Engine.time_scale *= 2
		if event.is_action_pressed("debug_time_minus"):
			Engine.time_scale /= 2
		if event.is_action_pressed("debug_time_reset"):
			Engine.time_scale = 1


func _on_boss_instantiate_this(node):
	add_child(node)


func _on_boss_phase_changed():
	ui.do_flash()
	overlays.run_new_phase()
	player.start_iframes()


func _on_player_got_roasted():
	boss.is_invincible = true
	pause_menu.can_pause = false
	game_over.show()
	create_tween().tween_property(music, "pitch_scale", 0.01, 3)


func _on_boss_died():
	ui.do_flash()
	boss_defeat_sfx.play()
	overlays.run_boss_death()
	player.force_iframes()
	player.save_hp()
	var tween := create_tween().set_loops(2)
	tween.tween_callback(ui.do_flash).set_delay(1.02)
	tween.tween_callback(boss_defeat_sfx.play)
	create_tween().tween_callback(func():
			boss_defeat_sfx_big.play()
			ui.do_flash()
	).set_delay(6)
	create_tween().tween_method(func(x: float):
			music.volume_db = linear_to_db(x)
	, 1.0, 0.0, 6)
	create_tween().tween_callback(func():
			ui.fade_to_end()
	).set_delay(8)
