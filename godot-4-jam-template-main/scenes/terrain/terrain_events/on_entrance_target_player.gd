extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(acquire_target)


func acquire_target(body : Node3D) -> void:
	if body.is_in_group("player"):
		var overlapping_bodies : Array[Node3D] = get_overlapping_bodies()
		for i : Node3D in overlapping_bodies:
			if i.is_in_group("enemy"):
				i.acquire_target(body)
		queue_free()
