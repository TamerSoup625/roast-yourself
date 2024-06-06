extends Area2D


const SPEED = 1000.0

var player: CharacterBody2D


func _ready():
	position = player.position
	look_at(get_global_mouse_position())


func _physics_process(delta):
	position += transform.x * SPEED * delta


func _on_life_timer_timeout():
	queue_free()


func _on_area_entered(area: Area2D):
	if area.has_meta("func_take_hit"):
		area.get_meta("func_take_hit").call()
		queue_free()
