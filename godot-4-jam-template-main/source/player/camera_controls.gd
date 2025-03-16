extends Node3D

enum camera_state{LOCK_ON, NORMAL, CUTSCENE, ENEMY_ACQUIRED}

@export_group("functionality")
@export var rotate_action: GUIDEAction
@export var lock_action : GUIDEAction
@export var camera : Camera3D
@export var follow_target : Marker3D
@export var original_target : Node3D
@export var spring_position : Node3D
@export var spring_arm : SpringArm3D
@export var player : CharacterBody3D
@export var mesh_parent : Node3D
@export var lock_on_area : Area3D
@export var lock_on_timer : Timer
@export var lock_on_sprite : Sprite2D
@export var animator_2d : AnimationPlayer
var locked_enemy : Node3D
var lock_changeable : bool = true
var locked_enemy_list : Array[Node3D] = []

@export_group("customizable")
@export var sensibility : float = 1.0
@export var lerp_power : float = 10.0
@export var lock_on_cooldown : float = 0.5

var current_camera_state : camera_state = camera_state.NORMAL

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#camera.make_current()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	lock_on_timer.timeout.connect(allow_relock)


func allow_relock() -> void:
	lock_changeable = true


func _physics_process(delta: float) -> void:
	match current_camera_state:
		camera_state.NORMAL:
			var position_lerp_strength : float = delta * sensibility * 2.0
			if !player.direction:
				position_lerp_strength *= 2.0
			follow_target.position = lerp(follow_target.position, original_target.position + player.direction * 2.0, position_lerp_strength)
			var rotation_input : Vector2 = rotate_action.value_axis_2d
			rotation.x -= rotation_input.y * sensibility * delta
			rotation.x = clamp(rotation.x, -PI/2, PI/4)
			
			rotation.y -= rotation_input.x * sensibility * delta * 3.0
			rotation.y = wrapf(rotation.y, 0.0, TAU)

			camera.global_position = lerp(camera.global_position, spring_position.global_position, delta*lerp_power)
			camera.global_rotation = Vector3.ZERO
			camera.look_at(follow_target.global_position, Vector3.UP)
			if lock_action.value_bool:
				current_camera_state = camera_state.LOCK_ON

		camera_state.LOCK_ON:
			if !lock_action.value_bool:
				current_camera_state = camera_state.NORMAL
				return
			if lock_on_area.has_overlapping_bodies():
				current_camera_state = camera_state.ENEMY_ACQUIRED
				var colinearity : float = -10.0
				var array_with_bodies : Array[Node3D] = lock_on_area.get_overlapping_bodies()
				var camera_front : Vector3 = -camera.global_basis.z
				for body : Node3D in array_with_bodies:
					var candidate_colinearity : float = camera_front.dot(body.global_position.normalized())
					if candidate_colinearity > colinearity:
						colinearity = candidate_colinearity
						locked_enemy = body
						locked_enemy_list.append(locked_enemy)
					
			rotation.x = lerp(rotation.x, -0.524, delta*lerp_power)
			rotation.y = lerp(rotation.y, mesh_parent.rotation.y, delta*lerp_power)
			camera.global_position = lerp(camera.global_position, spring_position.global_position, delta*lerp_power)

		camera_state.ENEMY_ACQUIRED:
			if !lock_action.value_bool or locked_enemy == null:
				current_camera_state = camera_state.NORMAL
				locked_enemy_list.clear()
				animator_2d.stop()
				lock_on_sprite.hide()
				return

			if abs(rotate_action.value_axis_2d.x) > 0.5 and lock_changeable:
				lock_on_timer.start(lock_on_cooldown)
				lock_changeable = false
				var found_something = false
				for body : Node3D in lock_on_area.get_overlapping_bodies():
					if !(body in locked_enemy_list):
						found_something = true
						locked_enemy = body
						locked_enemy_list.append(locked_enemy)
						break
				if !found_something:
					if locked_enemy_list.size() > 1:
						locked_enemy = locked_enemy_list[0]
						locked_enemy_list.clear()
						locked_enemy_list.append(locked_enemy)
			
			rotation.x = lerp(rotation.x, -0.524, delta * lerp_power/5.0)
			rotation.y = lerp(rotation.y, mesh_parent.rotation.y, delta*lerp_power/5.0)

			lock_on_sprite.show()
			lock_on_sprite.global_position = camera.unproject_position(locked_enemy.global_position)
			if !animator_2d.is_playing():
				animator_2d.play("rotate_lock")
			var target_rotation  : Basis = camera.basis.looking_at(locked_enemy.global_position)
			camera.basis.slerp(target_rotation, delta * lerp_power / 5.0)
