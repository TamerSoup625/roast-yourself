extends Control


@onready var anim_player = %AnimPlayer
@onready var test_sprite = %TestSprite


func _ready():
	test_sprite.queue_free()
	anim_player.play("RESET")


func run_new_phase():
	anim_player.play("new_phase")


func run_boss_death():
	anim_player.play("boss_death")
