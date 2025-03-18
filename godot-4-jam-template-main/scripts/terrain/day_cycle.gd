extends Node3D

@export var worldEnvironment : WorldEnvironment
@export var sun : DirectionalLight3D
@export var sun_color : Gradient
@export var sun_intensity : Curve 
@export var sky_color : Gradient 
@export var horizon_color : Gradient
#day length in seconds. A 5 minute day is 300
@export var day_length : float = 20.0
@export var start_time : float = 0.3
const  day_cover = preload("res://assets/materials/day_environment.tres")
const night_cover = preload("res://assets/materials/night_environment.tres")
var time : float
var time_rate : float 
var day : bool = true

func _ready() -> void:
	time_rate = 1.0 / day_length
	time = start_time
	
	
func _physics_process(delta: float) -> void:
	time += time_rate * delta

	if time >= 0.5 and day:
		worldEnvironment.environment = night_cover
		day = false

	if time >= 1.0:
		time = 0.0
		Signalbus.day_started.emit()
		worldEnvironment.environment = day_cover
		day = true
		print_debug("restarted")
		
	Global.time = time
	rotation.x = -time * 2 * PI
	#rotation.x = lerp(rotation.x, -time * 2 * PI, delta * 5.0)
	sun.light_color = sun_color.sample(time)
	sun.light_energy = sun_intensity.sample(time)
	if time < 0.5:
		worldEnvironment.environment.background_energy_multiplier = sun_intensity.sample(time)
	else:
		worldEnvironment.environment.background_energy_multiplier = 1.0
	sun.visible = sun.light_energy > 0
	var _sky_color = sky_color.sample(time)
	worldEnvironment.environment.sky.sky_material.set("sky_top_color", _sky_color)
	#worldEnvironment.environment.sky.sky_material.set("ground_bottom_color", _sky_color)
	var _horizon_color = horizon_color.sample(time)
	worldEnvironment.environment.sky.sky_material.set("sky_horizon_color", _horizon_color)
	worldEnvironment.environment.sky.sky_material.set("ground_horizon_color", _horizon_color)
	
	
