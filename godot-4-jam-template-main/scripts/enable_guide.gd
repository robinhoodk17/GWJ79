extends Node3D
# This scene is started by clicking the "Play" button in main.tscn.
# Change Project Settings: application/run/start_scene to game/game.tscn to skip the menus while developing

@export var default_mapping_context: GUIDEMappingContext
@onready var theme_sound: AudioStreamPlayer = $theme_sound
@onready var combat_theme: AudioStreamPlayer = $combat_theme


func _ready() -> void:
	theme_sound.play()
	GUIDE.enable_mapping_context(default_mapping_context)
	Signalbus.combat_started.connect(play_battle)
	Signalbus.combat_finished.connect(play_theme)


func play_theme(_area) -> void:
	combat_theme.stop()
	theme_sound.play()


func play_battle(_area) -> void:
	theme_sound.stop()
	combat_theme.play()
