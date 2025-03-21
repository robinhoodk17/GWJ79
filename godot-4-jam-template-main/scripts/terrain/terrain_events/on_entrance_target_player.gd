extends Area3D
class_name Combat

@export var hide_enemies : bool = true
var body_list : Array[Node3D]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(acquire_target)
	Signalbus.enemy_died.connect(enemy_died)
	await get_tree().process_frame
	call_deferred("late_ready")


func late_ready() -> void:
	var overlapping_bodies : Array[Node3D] = $Affected_area.get_overlapping_bodies()
	for i : Node3D in overlapping_bodies:
		if i.is_in_group("enemy"):
			body_list.append(i)
			if hide_enemies:
				i.hide()


func enemy_died(_body : Node3D):
	if _body in body_list:
		for i in body_list.size():
			if body_list[i] == _body:
				body_list.remove_at(i)
				break
	if body_list.size() == 0:
		Signalbus.combat_finished.emit(self)

func acquire_target(body : Node3D) -> void:
	if body.is_in_group("player"):
		Signalbus.combat_started.emit(self)
		var overlapping_bodies : Array[Node3D] = $Affected_area.get_overlapping_bodies()
		for i : Node3D in overlapping_bodies:
			if i.is_in_group("enemy"):
				i.show()
				i.acquire_target(body)
