extends Area3D

@export var damaging : bool = false
@export var damage_amount : int = 10

func _process(delta: float) -> void:
	if !damaging:
		return
	var colliding_bodies : Array[Node3D] = get_overlapping_bodies()
	for i : Node3D in colliding_bodies:
		if i.is_in_group("player"):
			i.take_damage(damage_amount)
			damaging = false
			return
