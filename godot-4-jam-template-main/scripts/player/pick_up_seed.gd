extends Area3D

@export var player_node : CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(pick_up_seed)

func pick_up_seed(_area : Area3D) -> void:
	print_debug("yup")
	if _area.is_in_group("seed"):
		_area.get_parent().on_player_entered(player_node)
