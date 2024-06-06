extends Area2D


var target_pos: Vector2
var rotation_offset: float


func _ready():
	look_at(target_pos)
	rotate(deg_to_rad(rotation_offset))
