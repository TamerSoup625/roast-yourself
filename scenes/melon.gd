extends Area2D


const SPEED: float = 300.0
const SPIKE = preload("res://scenes/spike.tscn")

var target_pos: Vector2
var rotation_offset: float
var target_dir: Vector2
var angular_speed: float = randf_range(-TAU, TAU)

@onready var base = %Base
@onready var boom = %Boom


func _ready():
	target_dir = position.direction_to(target_pos)
	target_dir = target_dir.rotated(deg_to_rad(rotation_offset))


func _physics_process(delta):
	position += target_dir * delta * SPEED
	rotation += angular_speed * delta
	if position.x < 0.0 or position.x > 800.0 or position.y < 0.0 or position.y > 600.0:
		set_deferred("monitorable", false)
		set_physics_process(false)
		base.hide()
		boom.show()
		var tween := create_tween()
		tween.tween_property(boom, "scale", Vector2(0.5, 0.5), 0.1).from(Vector2.ZERO).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_callback(func():
				for i in 16:
					var spike = SPIKE.instantiate()
					spike.position = position
					spike.rotation = lerpf(0, TAU, i / 16.0) + rotation
					add_sibling(spike)
				queue_free()
		)

