extends Node3D

@export var area3D : Area3D

func  _ready() -> void:
	area3D.body_entered.connect(_on_area_3d_body_entered)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		Global.seeds_carried+=1
		Signalbus.emit_signal("seed_picked")
		queue_free()
