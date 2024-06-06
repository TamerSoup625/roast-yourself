extends Area2D


const SPEED: float = 500.0


func _physics_process(delta):
	position += transform.x * delta * SPEED


func _on_life_timer_timeout():
	queue_free()
