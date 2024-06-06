extends StaticBody2D


@onready var hit_area = %HitArea
@onready var break_particles = %BreakParticles
@onready var sprite = %Sprite


func _ready():
	hit_area.set_meta("func_take_hit", func():
			break_particles.restart()
			sprite.hide()
			collision_layer = 0
			collision_mask = 0
	)


func _on_break_particles_finished():
	queue_free()
