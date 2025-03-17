extends Node3D

var planted:bool
@export var growth_phase_time:float=5
var phase=0
@onready var sapling_1: MeshInstance3D = $sapling1
@onready var sapling_2: MeshInstance3D = $sapling2
@onready var sapling_3: MeshInstance3D = $sapling3
@onready var growth_timer: Timer = $growth_timer

const default_material = preload("res://assets/materials/default_player_farm_material.tres")
const planted_material = preload("res://assets/materials/planted_player_farm_material.tres")
@onready var tile: MeshInstance3D = $tile

func _ready() -> void:
	planted=false
	sapling_1.visible=false
	sapling_2.visible=false
	sapling_3.visible=false



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is player and phase==0 and Global.saplings_carried>0:
		Global.saplings_carried-=1
		Global.seeds_carried-=1
		
		Signalbus.seed_dropped.emit()
		planted=true
		tile.material_override=planted_material
		growth_timer.start(growth_phase_time)
		
	
func phase_change(phase):
	match phase:

		1:
			sapling_1.visible=true
		2:
			sapling_1.visible=false
			sapling_2.visible=true
		3:
			sapling_2.visible=false
			sapling_3.visible=true


func _on_growth_timer_timeout() -> void:
	
	phase+=1
	phase_change(phase)
	
	if phase<3:
		growth_timer.start(growth_phase_time)
