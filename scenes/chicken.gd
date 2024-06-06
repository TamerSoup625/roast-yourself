extends StaticBody2D


const SPEED: float = 700.0
const ROTATION_OFFSET: float = deg_to_rad(30)
const HOME_ROTATION_SPEED: float = deg_to_rad(90)
const HOME_MOVEMENT_ACCEL: float = 800.0

var target_pos: Vector2
var target_dir: Vector2
var angular_speed: float = randf_range(TAU, 2 * TAU) * (-1 if randi() < 0.5 else 1)
var rotation_offset: float
var rocket_target: Node2D
var home_speed: float = 0

@onready var normal = %Normal
@onready var rocket = %Rocket
@onready var flash = %Flash
@onready var rocket_particles = %RocketParticles
@onready var life_timer = %LifeTimer


func _ready():
	target_dir = position.direction_to(target_pos)
	target_dir = target_dir.rotated(deg_to_rad(rotation_offset))


func _physics_process(delta):
	if rocket_target:
		home_speed += delta * HOME_MOVEMENT_ACCEL
		position += target_dir * delta * home_speed
		target_dir = vec2_move_toward(
				target_dir,
				position.direction_to(rocket_target.position),
				HOME_ROTATION_SPEED * delta,
		)
		look_at(global_position + target_dir)
		return
	rotation += angular_speed * delta
	var collision: KinematicCollision2D = move_and_collide(target_dir * delta * SPEED)
	if is_instance_valid(collision):
		target_dir = target_dir.rotated(randf_range(-ROTATION_OFFSET, ROTATION_OFFSET))
		target_dir = target_dir.bounce(collision.get_normal())


func rocket_to_target(target: Node2D):
	normal.hide()
	rocket.show()
	flash.show()
	create_tween().tween_property(flash, "modulate", Color.TRANSPARENT, 0.1)
	rocket_target = target
	target_dir = position.direction_to(target.position)
	rocket_particles.emitting = true


func disable():
	set_physics_process(false)
	life_timer.start()


func vec2_move_toward(from: Vector2, to: Vector2, delta: float) -> Vector2:
	if delta == 0.0: return from
	if sign(delta) == 1:
		if from == to: return from
	else:
		if from == -to: return from
	
	var dir: float = sign(from.dot(to.orthogonal()))
	if dir == 0:
		if (from.dot(to) >= 0 and delta > 0) or (from.dot(to) <= 0 and delta < 0):
			return from
	var vec: Vector2 = from
	if dir == 1.0:
		vec = vec.rotated(delta)
	else:
		vec = vec.rotated(-delta)
	
	if dir != 0.0 and dir != sign(vec.dot(to.orthogonal())):
		if sign(delta) == 1:
			vec = to
		else:
			vec = -to
	
	return vec


func _on_life_timer_timeout():
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	disable()
