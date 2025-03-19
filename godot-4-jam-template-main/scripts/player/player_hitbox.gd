extends Area3D

@export var damage_amount : int = 10
@export var launch_force : float = 30.0
@export var main_body : Node3D
@export var damaging : bool = false
var damaged_enemies : Array[Node3D] = []

func _process(delta: float) -> void:
	if !damaging:
		return
	var colliding_bodies : Array[Node3D] = get_overlapping_bodies()
	for i : Node3D in colliding_bodies:
		if i.is_in_group("enemy"):
			if !(i in damaged_enemies):
				var launch_direction : Vector3 = i.global_position - main_body.global_position
				i.take_damage(damage_amount, launch_force, launch_direction)
				damaged_enemies.append(i)


func start_damaging():
	damaging = true
	damaged_enemies.clear()
	set_process(true)


func stop_damaging():
	damaging = false
	damaged_enemies.clear()
	set_process(false)
