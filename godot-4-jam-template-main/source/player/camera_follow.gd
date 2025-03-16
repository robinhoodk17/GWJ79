extends Camera3D

@export var player : CharacterBody3D
@export var spring_position : Node3D
@export var lerp_power : float = 10.0
@export var follow_target : Marker3D

func _process(delta: float) -> void:
	global_position = lerp(global_position, spring_position.global_position, delta*lerp_power)
