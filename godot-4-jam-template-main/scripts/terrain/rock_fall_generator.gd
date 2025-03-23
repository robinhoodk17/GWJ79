extends Node3D

@export var rock_prefab = preload("res://scenes/terrain/rock.tscn")
@onready var timer = $Timer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(produce_rock)
	var delay = randf_range(1.9,2.2)
	timer.start(delay)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func produce_rock() -> void:
	var new_rock = rock_prefab.instantiate()
	add_child(new_rock)
	new_rock.global_position = global_position
