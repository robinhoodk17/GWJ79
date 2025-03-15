extends Area3D

@export var damaging : bool = false
@export var damage_amount : int = 10

func _ready() -> void:
	body_entered.connect(deal_damage)


func deal_damage(body : Node3D) -> void:
	if damaging:
		if body.is_in_group("player"):
			body.get_node("Combat").take_damage(damage_amount)
			damaging = false
