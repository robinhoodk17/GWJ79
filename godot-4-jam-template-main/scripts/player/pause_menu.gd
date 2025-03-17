extends CanvasLayer

@export var pause_action : GUIDEAction

var paused : bool = false

func _ready() -> void:
	pause_action.triggered.connect(pause)


func pause() -> void:
	if !paused:
		get_tree().paused = true
		paused = true
		show()
	else:
		get_tree().paused = false
		paused = false
		hide()
