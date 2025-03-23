extends Node3D

var planted:bool

var phase=0
var plant_type=0

@export var growth_phase_time:float=5


@onready var growth_timer: Timer = $growth_timer

@export var default_material:Material
@export var planted_material:Material
@onready var tile: MeshInstance3D = $tile

@onready var plant_1_small: MeshInstance3D = $plant1_small
@onready var plant_1_med: MeshInstance3D = $plant1_med
@onready var plant_1_big: MeshInstance3D = $plant1_big
@onready var plant_2_small: MeshInstance3D = $plant2_small
@onready var plant_2_med: MeshInstance3D = $plant2_med
@onready var plant_2_big: MeshInstance3D = $plant2_big
@onready var plant_3_small: MeshInstance3D = $plant3_small
@onready var plant_3_med: MeshInstance3D = $plant3_med
@onready var plant_3_big: MeshInstance3D = $plant3_big
@onready var plant_4_small: MeshInstance3D = $plant4_small
@onready var plant_4_med: MeshInstance3D = $plant4_med
@onready var plant_4_big: MeshInstance3D = $plant4_big

@onready var matured_sound: AudioStreamPlayer3D = $matured_sound

func _ready() -> void:
	planted=false



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is player and phase==0 and Global.saplings_carried>0:
		Global.saplings_carried-=1
		Global.seeds_carried-=1
	
		planted=true
		tile.material_override=planted_material
		phase=1
	
		if Global.plants_list[3]!=0:
			plant_type=Global.plants_list[3]
		elif Global.plants_list[2]!=0:
			plant_type=Global.plants_list[2]
		elif Global.plants_list[1]!=0:
			plant_type=Global.plants_list[1]
		elif Global.plants_list[0]!=0:
			plant_type=Global.plants_list[0]
		print(plant_type)
		
		Signalbus.seed_dropped.emit()
		phase_change()
func phase_change():
	match phase:

		1:
			match plant_type:
				1:
					plant_1_small.visible=true	
					growth_timer.start(growth_phase_time)	
				2:
					plant_2_small.visible=true	
					growth_timer.start(growth_phase_time)
				3:
					plant_3_small.visible=true	
					growth_timer.start(growth_phase_time)
				4:
					plant_4_small.visible=true	
					growth_timer.start(growth_phase_time)
				
		2:
			match plant_type:
				1:
					plant_1_small.visible=false
					plant_1_med.visible=true	
					growth_timer.start(growth_phase_time)	
				2:
					plant_2_small.visible=false
					plant_2_med.visible=true	
					growth_timer.start(growth_phase_time)
				3:
					plant_3_small.visible=false
					plant_3_med.visible=true	
					growth_timer.start(growth_phase_time)
				4:
					plant_4_small.visible=false
					plant_4_med.visible=true	
					growth_timer.start(growth_phase_time)
		3:
			matured_sound.play()
			match plant_type:
				1:
					plant_1_med.visible=false
					plant_1_big.visible=true	
					growth_timer.start(growth_phase_time)	
				2:
					plant_2_med.visible=false
					plant_2_big.visible=true	
					growth_timer.start(growth_phase_time)
				3:
					plant_3_med.visible=false
					plant_3_big.visible=true	
					growth_timer.start(growth_phase_time)
				4:
					plant_4_med.visible=false
					plant_4_big.visible=true	
					growth_timer.start(growth_phase_time)


func _on_growth_timer_timeout() -> void:
	
	phase+=1
	phase_change()
	
	if phase<3:
		growth_timer.start(growth_phase_time)
