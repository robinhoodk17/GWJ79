extends Area3D

@export var light_particles : ParticleProcessMaterial
@export var water_particles : ParticleProcessMaterial
@export var sleep_particles : ParticleProcessMaterial

@export_flags("Light", "Water", "Sleep") var Particles = 0

@onready var bar_spot: GPUParticles3D = $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Particles == 1:
		bar_spot.process_material = light_particles
	elif Particles == 3:
		bar_spot.process_material = sleep_particles
	elif Particles == 2:
		bar_spot.process_material = water_particles


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
