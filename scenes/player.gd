extends CharacterBody2D


enum State {
	WALKING,
	DASHING,
	HURT,
}

const WALK_SPEED = 200.0
const DASH_SPEED = 800.0
const HURT_KNOCKBACK_SPEED = 400.0
const PLAYER_BULLET = preload("res://scenes/player_bullet.tscn")

signal instantiate_this(node)
signal got_roasted

@export var is_intro: bool = false

var _dash_buffer := Buffer.new(0.1)
var _fire_buffer := Buffer.new(0.1)

var state: State = State.WALKING
var can_fire: bool = true
var last_dir: Vector2 = Vector2.RIGHT
var has_iframes: bool = false
var hp: int = 8
var wrong_dash: bool = false

@onready var dash_timer = %DashTimer
@onready var fire_bullet_timer = %FireBulletTimer
@onready var shoot_particles = %ShootParticles
@onready var hurtbox = %Hurtbox
@onready var stun_timer = %StunTimer
@onready var i_frame_timer = %IFrameTimer
@onready var hp_bar = %HpBar
@onready var hurt_particles = %HurtParticles
@onready var hit_sfx = %HitSfx
@onready var fire_sfx = %FireSfx


func _ready():
	if is_intro:
		i_frame_timer.wait_time = 1


func _process(_delta):
	if has_iframes and (Time.get_ticks_msec() % 200 < 100 or state == State.HURT):
		hp_bar.modulate = Color(1, 0.5, 0.5)
	else:
		hp_bar.modulate = Color.WHITE


func _physics_process(delta):
	# State change
	for x in hurtbox.get_overlapping_areas():
		if x.get_meta("hurtful", false) and can_take_hits():
			take_damage()
	_dash_buffer.input = Input.is_action_just_pressed("dash")
	_dash_buffer.allow = state == State.WALKING
	_dash_buffer.update(delta)
	if _dash_buffer.can_do_action():
		state = State.DASHING
		wrong_dash = true
		dash_timer.start()
	
	# Movement
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	if not direction.is_zero_approx():
		wrong_dash = false
	if state == State.HURT:
		direction = -last_dir
	var speed: float = DASH_SPEED if state == State.DASHING else WALK_SPEED if state == State.WALKING else HURT_KNOCKBACK_SPEED
	if state == State.DASHING and wrong_dash:
		direction = last_dir
	velocity = direction * speed
	if state != State.HURT and not velocity.is_zero_approx():
		last_dir = velocity.normalized()
	
	# Here we go
	move_and_slide()
	
	# Block boundaries
	if is_intro:
		position.x = maxf(position.x, 0)
	else:
		position.x = clampf(position.x, 0, 800)
	position.y = clampf(position.y, 0, 600)
	
	if state == State.HURT:
		return
	
	# Fire bullets
	_fire_buffer.input = Input.is_action_pressed("fire_bullet")
	_fire_buffer.allow = can_fire
	_fire_buffer.update(delta)
	if _fire_buffer.can_do_action():
		create_bullet()
		can_fire = false
		fire_bullet_timer.start()
		shoot_particles.look_at(get_global_mouse_position())
		shoot_particles.restart()
		fire_sfx.play()


func _on_dash_timer_timeout():
	state = State.WALKING


func create_bullet():
	var bullet = PLAYER_BULLET.instantiate()
	bullet.player = self
	instantiate_this.emit(bullet)


func _on_fire_bullet_timer_timeout():
	can_fire = true


func can_take_hits():
	return state == State.WALKING and not has_iframes


func _on_stun_timer_timeout():
	state = State.WALKING


func _on_i_frame_timer_timeout():
	has_iframes = false


func update_hp_bar():
	hp_bar.value = hp


func start_iframes():
	has_iframes = true
	i_frame_timer.start()


func take_damage():
	if not is_intro:
		hp -= 1
	state = State.HURT
	if hp > 0:
		stun_timer.start()
	start_iframes()
	update_hp_bar()
	hurt_particles.restart()
	var tween := create_tween()
	if hp <= 0:
		tween.set_loops()
		got_roasted.emit()
	tween.tween_property(hp_bar, "rotation", TAU * 2, 0.5).from(0.0)
	hit_sfx.play()


func save_hp():
	get_tree().set_meta("hp_left", hp)


func force_iframes():
	i_frame_timer.stop()
	has_iframes = true
