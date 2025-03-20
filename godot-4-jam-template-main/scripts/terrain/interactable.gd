extends Node3D
class_name FarmHouse

@export var pop_up: Node3D

func display_prompt() -> void:
	if pop_up.visible:
		return
	pop_up.pop_up_show()

func  turn_off_prompt():
	pop_up.turn_off_prompt()
	
func  interact(_body : Node3D):
	#do whaterver you want
	pass
