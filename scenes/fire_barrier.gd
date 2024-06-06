extends Area2D


const SPEED = 400.0

@onready var sprite = %Sprite


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sprite.region_rect.position.x += delta * SPEED
