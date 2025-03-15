extends Camera3D

@export var spring_position : Node3D
@export var lerp_power : float = 10.0

func _process(delta: float) -> void:
	position = lerp(position, spring_position.position, delta*lerp_power)
