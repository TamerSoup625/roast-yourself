extends Node


@onready var hp_bar = %HpBar
@onready var hp_left = %HpLeft


func _ready():
	var player_hp: int = get_tree().get_meta("hp_left", 0)
	hp_bar.value = player_hp
	hp_left.text = hp_left.text % player_hp


func _on_play_again_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
