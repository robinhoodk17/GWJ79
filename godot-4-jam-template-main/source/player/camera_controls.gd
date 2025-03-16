extends Node3D

enum camera_state{LOCK_ON, NORMAL, CUTSCENE}

@export var rotate_action: GUIDEAction
@export var camera : Camera3D
@export var sensibility : float = 1.0

var offset : Vector3
var current_camera_state : camera_state = camera_state.NORMAL

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.make_current()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	match current_camera_state:
		camera_state.NORMAL:
			var rotation_input : Vector2 = rotate_action.value_axis_2d
			rotation.x -= rotation_input.y * sensibility * delta
			rotation.x = clamp(rotation.x, -PI/2, PI/4)
			
			rotation.y -= rotation_input.x * sensibility * delta
			rotation.y = wrapf(rotation.y, 0.0, TAU)
