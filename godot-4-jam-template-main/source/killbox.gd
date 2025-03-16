extends Area3D

func _ready() -> void:
	body_entered.connect(kill_body)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func kill_body(body: Node3D) -> void:
	if body.is_in_group("player") or body.is_in_group("enemy"):
		body.die()
