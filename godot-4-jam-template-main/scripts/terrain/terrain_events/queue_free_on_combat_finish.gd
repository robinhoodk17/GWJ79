extends Node3D

@export var which_combat : Combat
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Signalbus.combat_finished.connect(on_combat_finished)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func on_combat_finished(_body : Node3D) -> void:
	if _body == which_combat:
		queue_free()
