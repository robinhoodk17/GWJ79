extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.lost_game.connect(lost_game)
	hide()


func lost_game() -> void:
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()
	$VBoxContainer/Retry.grab_focus()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()


func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$VBoxContainer/Label.text = "You Lost"
