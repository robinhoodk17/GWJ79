extends Area3D

@export var damage_amount : int = 10
@export var launch_force : float = 30.0
@export var main_body : Node3D
@export var damaging : bool = false

func _ready() -> void:
	body_entered.connect(deal_damage)


func deal_damage(body : Node3D) -> void:
	if damaging:
		if body.is_in_group("enemy"):
			var launch_direction : Vector3 = body.global_position - main_body.global_position
			body.take_damage(damage_amount, launch_force, launch_direction)
