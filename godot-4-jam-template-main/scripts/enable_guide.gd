extends Node3D
# This scene is started by clicking the "Play" button in main.tscn.
# Change Project Settings: application/run/start_scene to game/game.tscn to skip the menus while developing

@export var default_mapping_context: GUIDEMappingContext
@onready var theme_sound: AudioStreamPlayer = $theme_sound

# TODO: Create your game beginning here


func _ready() -> void:
	theme_sound.play()
	GUIDE.enable_mapping_context(default_mapping_context)
	#$UI.show_ui("Game")
