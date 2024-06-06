extends Control


@onready var boss_bar = %BossBar
@onready var flash = %Flash
@onready var black = %Black


func _ready():
	boss_bar.max_value = Boss.MAX_HP
	set_boss_hp(Boss.MAX_HP)


func set_boss_hp(value: int):
	boss_bar.value = value


func do_flash():
	flash.color = Color.WHITE
	flash.show()
	var tween := create_tween()
	tween.tween_property(flash, "color", Color.TRANSPARENT, 1.0)
	tween.tween_callback(flash.hide)


func fade_to_end():
	black.color = Color(0, 0, 0, 0)
	black.show()
	var tween := create_tween()
	tween.tween_property(black, "color", Color.BLACK, 2.0)
	tween.tween_callback(get_tree().change_scene_to_file.bind("res://scenes/you_win.tscn"))
