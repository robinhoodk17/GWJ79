extends Area3D
class_name Combat

@export var hide_enemies : bool = true
@export var respawn : bool = true
@export var days_for_respawn : int = 3
var days_passed : int  = 0
var body_list : Array[Node3D]
var body_list_dead : Array[Node3D]
var waiting_for_respawn : bool = false
var positions : Array[Vector3] = []
var respawning : bool = false
var enemies_exist : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(acquire_target)
	Signalbus.enemy_died.connect(enemy_died)
	Signalbus.day_started.connect(wait_for_respawn)
	await get_tree().process_frame
	call_deferred("late_ready")


func late_ready() -> void:
	if !respawning:
		body_list.clear()
		var overlapping_bodies : Array[Node3D] = $Affected_area.get_overlapping_bodies()
		for i : Node3D in overlapping_bodies:
			if i.is_in_group("enemy"):
				body_list.append(i)
				positions.append(i.global_position)
				if hide_enemies:
					i.hide()
		respawning = true
	else:
		for i in body_list:
			if hide_enemies:
				i.hide()
	enemies_exist = true

func enemy_died(_body : Node3D):
	if !(_body in body_list_dead):
		body_list_dead.append(_body)
	if body_list.size() == body_list_dead.size():
		Signalbus.combat_finished.emit(self)
		if respawn:
			days_passed = 0
			waiting_for_respawn = true

func wait_for_respawn() -> void:
	if !waiting_for_respawn:
		return
	if days_passed == days_for_respawn:
		respawn_enemies()
	days_passed += 1


func respawn_enemies() -> void:
	respawning = true
	for i in body_list.size():
		add_child(body_list[i])
		body_list[i].global_position = positions[i]
		body_list[i]._ready()
	await get_tree().process_frame
	late_ready()
	waiting_for_respawn = false

func acquire_target(body : Node3D) -> void:
	if !enemies_exist:
		return
	if body.is_in_group("player"):
		Signalbus.combat_started.emit(self)
		print_debug("combat_started")
		var overlapping_bodies : Array[Node3D] = $Affected_area.get_overlapping_bodies()
		for i : Node3D in overlapping_bodies:
			if i.is_in_group("enemy"):
				i.show()
				i.acquire_target(body)
