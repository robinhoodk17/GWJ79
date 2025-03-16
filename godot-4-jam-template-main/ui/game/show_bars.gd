extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.picked_plant.connect(show)
	Global.lost_plant.connect(hide)
