extends SpringArm3D

enum camera_state{LOCK_ON, NORMAL, CUTSCENE}

@export var rotate_action: GUIDEAction
@export var player : Node3D
@export var camera : Camera3D
@export var nest : Node3D
@export var focus_point : Node3D
@export var look_at : Node3D
@export var sensibility : float = 2.0

var offset : Vector3
var current_camera_state : camera_state = camera_state.NORMAL

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.make_current()
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	match current_camera_state:
		camera_state.NORMAL:
			var rotation_input = rotate_action.value_axis_2d
			rotation.x -= rotation_input.y * sensibility * delta
			rotation.y -= rotation_input.x * sensibility * delta
			#global_position = lerp(global_position,player.global_position, delta)
			#focus_point.global_position = lerp(focus_point.global_position, player.global_position + player.velocity, delta * .5)
			#camera.look_at(focus_point.global_position)
			#camera.global_basis = camera.global_basis.slerp(nest.global_basis,delta * 2.0).orthonormalized()
