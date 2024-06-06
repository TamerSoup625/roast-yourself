extends Area2D


const SPEED: float = 500.0

var target_pos: Vector2
var target_dir: Vector2
var angular_speed: float = randf_range(-TAU, TAU)
var rotation_offset: float


func _ready():
	target_dir = position.direction_to(target_pos)
	target_dir = target_dir.rotated(deg_to_rad(rotation_offset))


func _physics_process(delta):
	position += target_dir * delta * SPEED
	rotation += angular_speed * delta


func _on_life_timer_timeout():
	queue_free()
