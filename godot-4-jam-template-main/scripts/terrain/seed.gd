extends Node3D

@export var area3D : Area3D
@export var type:int=1

func  _ready() -> void:
	area3D.body_entered.connect(_on_area_3d_body_entered)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and Global.seeds_carried<4:
		Global.seeds_carried+=1
		Signalbus.seed_picked.emit(type)
		queue_free()
