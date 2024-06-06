extends Node


@onready var camera = %Camera
@onready var player = %Player
@onready var anim_player = %AnimPlayer


func _process(_delta):
	var player_x: float = player.position.x
	if player_x <= 1950:
		camera.position.x = player_x - fmod(player_x, 600)
	else:
		camera.position.x = 1950
		if not anim_player.is_playing():
			anim_player.play("boss_start")


func _input(event):
	if event.is_action_pressed("escape") and anim_player.is_playing():
		get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_player_instantiate_this(node):
	add_child(node)


func _on_anim_player_animation_finished(anim_name):
	if anim_name == "boss_start":
		get_tree().change_scene_to_file("res://scenes/main.tscn")
