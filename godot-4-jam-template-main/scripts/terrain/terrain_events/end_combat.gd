extends Area3D
class_name Finish_Combat

var body_list : Array[Node3D]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var overlapping_bodies = get_overlapping_bodies()
	for i in overlapping_bodies:
		if i.is_in_group("enemy"):
			body_list.append(i)
	Signalbus.enemy_died.connect(enemy_died)


func enemy_died(_body : Node3D):
	print_debug("enemy died", _body)
	if _body in body_list:
		for i in body_list.size():
			if body_list[i] == _body:
				body_list.remove_at(i)
				break
	if body_list.size() == 0:
		Signalbus.combat_finished.emit(self)
