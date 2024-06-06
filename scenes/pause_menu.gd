extends Panel


var can_pause: bool = true


func _ready():
	hide()


func _input(event):
	if event.is_action_pressed("pause"):
		switch_pause()


func switch_pause():
	if not can_pause: return
	get_tree().paused = not get_tree().paused
	visible = get_tree().paused


func _on_resume_pressed():
	switch_pause()


func _on_retry_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
