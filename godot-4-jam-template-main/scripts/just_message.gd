extends Node3D

@onready var message: Label = $SubViewport/Message

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	call_deferred("late_ready")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func late_ready() -> void:
	message.text = message.text
	show()
