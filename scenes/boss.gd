class_name Boss
extends Node2D


const MAX_HP: int = 400
const CHESTNUT = preload("res://scenes/chestnut.tscn")
const MELON = preload("res://scenes/melon.tscn")
const FIRE = preload("res://scenes/fire.tscn")
const CHICKEN = preload("res://scenes/chicken.tscn")
const PHASE_COUNT: int = 4
const PHASE_LIST = [
	"phase1",
	"phase2",
	"phase3",
	"phase4",
]

signal hp_changed(new_value)
signal instantiate_this(node)
signal phase_changed
signal chicken_rocket
signal died

@export var animate_to_player_y: float = 0
@export var lock_else_y: bool = false
@export var animate_rotation_offset: float = 0
@export var rocket_target: Node2D

var _target_pos: Vector2

var hp: int = MAX_HP
var phase: int = 0
var is_invincible: bool = false

@onready var ap_control = %APControl
@onready var area_and_else = %AreaAndElse
@onready var flash = %Flash
@onready var chestnut_timer = %ChestnutTimer
@onready var boss_texs = [%BossTex1, %BossTex2, %BossTex3, %BossTex4]
@onready var boss_texs_bag = boss_texs.duplicate()
@onready var ap_attacks = %APAttacks
@onready var go_new_phase_timer = %GoNewPhaseTimer
@onready var fire_timer = %FireTimer
@onready var phase_sfx = %PhaseSfx
@onready var roaster = %Roaster


func _ready():
	ap_control.play("start")
	ap_control.queue(PHASE_LIST[0])
	area_and_else.set_meta("func_take_hit", take_hit)
	randomize()
	boss_texs_bag.shuffle()
	change_boss_texture()


func _physics_process(_delta):
	area_and_else.position.y = _target_pos.y * animate_to_player_y
	if OS.is_debug_build() and Input.is_action_just_pressed("debug_take_damage"):
		for __ in 400:
			take_hit()


func set_target_pos(vec: Vector2):
	if not lock_else_y:
		_target_pos = vec


func do_flash():
	flash.show()
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	flash.hide()


func take_hit():
	if is_invincible:
		return
	hp -= 1
	hp_changed.emit(hp)
	do_flash()
	if hp <= 0:
		died.emit()
		ap_control.stop()
		is_invincible = true
		ap_attacks.play("RESET")
		var tween := create_tween()
		tween.tween_method(func(x: float):
				area_and_else.position = Vector2(
						randf_range(-x, x),
						randf_range(-x, x),
				)
		, 0.0, 25.0, 3)
		tween.tween_callback(func(): area_and_else.position = Vector2.ZERO)
		tween.tween_method(func(x):
				area_and_else.rotation = x ** 2.0
		, 0.0, 10.0, 3.0)
		tween.tween_callback(roaster.show)
		var cycler := create_tween().set_loops(6)
		cycler.tween_callback(func():
				for i in boss_texs:
					i.hide()
				boss_texs.pick_random().show()
		).set_delay(1)
		create_tween().tween_callback(func():
				for i in boss_texs:
					i.hide()
		).set_delay(6)
		return
	if should_change_phase():
		phase += 1
		phase_changed.emit()
		change_boss_texture()
		ap_control.stop()
		ap_attacks.play("RESET")
		is_invincible = true
		go_new_phase_timer.start()
		phase_sfx.play()
		var tween := create_tween()
		tween.tween_interval(1.0)
		tween.tween_method(func(x: float):
				area_and_else.position = Vector2(
						randf_range(-x, x),
						randf_range(-x, x),
				)
		, 25.0, 0.0, 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_callback(func(): area_and_else.position = Vector2.ZERO)


func animate_set_chestnut_throw_interval(period: float):
	if period < 0.0:
		chestnut_timer.stop()
	else:
		chestnut_timer.wait_time = period
		chestnut_timer.start()


func animate_set_fire_interval(period: float):
	if period < 0.0:
		fire_timer.stop()
	else:
		fire_timer.wait_time = period
		fire_timer.start()


func animate_throw_melon(rotation_offset: float = 0.0):
	var melon = MELON.instantiate()
	melon.position = area_and_else.global_position
	melon.target_pos = _target_pos
	melon.rotation_offset = rotation_offset
	instantiate_this.emit(melon)


func animate_throw_chicken(rotation_offset: float = 0.0):
	var chicken = CHICKEN.instantiate()
	chicken.position = area_and_else.global_position
	chicken.target_pos = _target_pos
	chicken.rotation_offset = rotation_offset
	chicken_rocket.connect(chicken.rocket_to_target.bind(rocket_target), CONNECT_ONE_SHOT)
	instantiate_this.emit(chicken)


func animate_chicken_rocket():
	chicken_rocket.emit()


func change_boss_texture():
	for i in boss_texs:
		i.hide()
	if boss_texs_bag.size() > 0:
		boss_texs_bag.pop_back().show()


func should_change_phase():
	@warning_ignore("integer_division")
	return hp <= (MAX_HP / PHASE_COUNT) * (PHASE_COUNT - phase - 1)


func _on_chestnut_timer_timeout():
	var chestnut = CHESTNUT.instantiate()
	chestnut.position = area_and_else.global_position
	chestnut.target_pos = _target_pos
	chestnut.rotation_offset = animate_rotation_offset
	instantiate_this.emit(chestnut)


func _on_go_new_phase_timer_timeout():
	is_invincible = false
	ap_control.play(PHASE_LIST[phase])


func _on_fire_timer_timeout():
	var fire = FIRE.instantiate()
	fire.position = area_and_else.global_position
	fire.target_pos = _target_pos
	fire.rotation_offset = animate_rotation_offset
	instantiate_this.emit(fire)
