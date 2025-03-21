extends FarmHouse

@export var new_scene : String = "res://scenes/terrain/main_path.tscn"


func interact(_body : Node3D):
	get_tree().change_scene_to_file(new_scene)
