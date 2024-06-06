extends Panel


func _ready():
	hide()


func _on_retry_pressed():
	get_tree().reload_current_scene()
