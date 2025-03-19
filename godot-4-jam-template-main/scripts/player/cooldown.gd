extends ProgressBar

@export var  player_node : CharacterBody3D
var pinged


func _process(delta : float) -> void:
	if !player_node:
		return
	max_value = player_node.stomp_cooldown
	value = player_node.current_stomp_cooldown
