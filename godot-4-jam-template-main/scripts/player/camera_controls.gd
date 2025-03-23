extends Node3D

enum camera_state{LOCK_ON, NORMAL, CUTSCENE, ENEMY_ACQUIRED}

@export_group("camera shake")
@export var decay : float = 0.6 #How quickly shaking will stop [0,1].
@export var kaiju_decay : float = 4.5 #How quickly shaking will stop from kaiju steps [0,1].
@export var max_roll : Vector3 = Vector3(0.2,0.2,.35) #Maximum rotation in radians (use sparingly).
var max_kaiju_trauma : float = 0.75
@export var noise : FastNoiseLite #The source of random values.
var noise_y : float = 0 #Value used to move through the noise
var kaiju_noise_y : float = 0
var kaiju_trauma : float = 0.0 #Current shake strength
var trauma : float = 0.0 #Current shake strength
var trauma_pwr : float = 3 #Trauma exponent. Use [2,3]
var kaiju_trauma_pwr : float = 2
var current_camera_roll : float = 0.0

@export_group("functionality")
@export var rotate_action: GUIDEAction
@export var lock_action : GUIDEAction
@export var change_lcck : GUIDEAction
@export var camera_nest : Node3D
@export var camera : Camera3D
@export var follow_target : Marker3D
@export var original_target : Node3D
@export var spring_position : Node3D
@export var spring_arm : SpringArm3D
@export var player : CharacterBody3D
@export var mesh_parent : Node3D
@export var lock_on_area : Area3D
@export var lock_on_timer : Timer
@export var lock_on_sprite : Control
@export var animator_2d : AnimationPlayer
var locked_enemy : Node3D
var lock_changeable : bool = true
var locked_enemy_list : Array[Node3D] = []
var camera_toggled : bool = false
var lock_action_cooldown : float = 0.5
var lock_action_current_cooldown : float = 0.0

@export_group("customizable")
@export var lerp_power : float = 10.0
@export var lock_on_cooldown : float = 0.5
@export var idle_cooldown : float = 1.5
@export var shake_probability : float = 0.8
@export var tween_duration : float = 0.25
@export var _reset_x_rotation : float = -0.35
@export var default_FOV : float = 75
@export var focused_FOV : float = 68
var _target_rotation : Vector3 = Vector3(_reset_x_rotation,0,0)
var tween : Tween

var current_camera_state : camera_state = camera_state.NORMAL


func position_camera_behind_player(duration : float = tween_duration) -> void:
	_tween_rotation(mesh_parent.get_rotation().y,  duration)


func _tween_rotation(target_y_rotation : float, duration : float = tween_duration):
	_target_rotation.y = wrapf(target_y_rotation, rotation.y - PI, rotation.y + PI)
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "rotation", _target_rotation, duration)

func add_trauma(amount : float, max_trauma : float) -> void:
	trauma = min(trauma + amount, max_trauma)


func add_kaiju_step_trauma(amount : float, max_trauma : float) -> void:
	var probability = randf_range(0.0, 1.0)
	if probability > shake_probability:
		return
	kaiju_trauma = min(kaiju_trauma + amount, max_trauma)


func shake(howMuch : float) -> void:
	var amt : float = pow(howMuch, trauma_pwr)
	noise_y += 1
	var rollx :float = max_roll.x * amt * noise.get_noise_2d(5,noise_y)
	var rolly :float = max_roll.y * amt * noise.get_noise_2d(33,noise_y)
	var rollz :float = max_roll.z * amt * noise.get_noise_2d(60,noise_y)
	var rotatingBasis : Basis = camera.basis
	rotatingBasis = rotatingBasis.rotated(Vector3(1,0,0),rollx)
	rotatingBasis = rotatingBasis.rotated(Vector3(0,1,0),rolly)
	rotatingBasis = rotatingBasis.rotated(Vector3(0,0,1),rollz)


func kaiju_shake(howMuch : float, max_trauma : float) -> void:
	var amt :float = pow(howMuch, kaiju_trauma_pwr)
	kaiju_noise_y += 1
	var rollx : float = max_roll.x * amt * noise.get_noise_2d(5,kaiju_noise_y)
	var rolly : float = max_roll.y * amt * noise.get_noise_2d(33,kaiju_noise_y)
	var rollz : float= max_roll.z * amt * noise.get_noise_2d(30,kaiju_noise_y)
	var rotatingBasis : Basis = camera_nest.basis
	rotatingBasis = rotatingBasis.rotated(camera_nest.basis.x,rollx)
	rotatingBasis = rotatingBasis.rotated(camera_nest.basis.y,rolly)
	rotatingBasis = rotatingBasis.rotated(camera_nest.basis.z,rollz)
	camera.basis =	rotatingBasis.orthonormalized()


func handleShakes(delta : float) -> void:
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake(trauma)
	else:
		shake(0.0001)
	if kaiju_trauma:
		kaiju_trauma = max(kaiju_trauma - kaiju_decay * delta, 0)
		kaiju_shake(kaiju_trauma, max_kaiju_trauma)
	else:
		kaiju_shake(0.0001, max_kaiju_trauma)


func _ready() -> void:
	camera.make_current()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	lock_on_timer.timeout.connect(allow_relock)


func allow_relock() -> void:
	lock_changeable = true


func _physics_process(delta: float) -> void:
	if lock_action_current_cooldown < lock_action_cooldown:
		lock_action_current_cooldown += delta
	match current_camera_state:
		camera_state.NORMAL:
			camera.fov = move_toward(camera.fov, default_FOV, delta * 10.0)
			if lock_on_sprite.visible:
				animator_2d.stop()
				lock_on_sprite.hide()
			var position_lerp_strength : float = delta
			if !player.direction:
				position_lerp_strength /= 2.0
			follow_target.position = lerp(follow_target.position, original_target.position + player.direction * 2.0, position_lerp_strength)
			position = lerp(position, original_target.position, position_lerp_strength)
			var rotation_input : Vector2 = rotate_action.value_axis_2d

			rotation.x -= rotation_input.y * Global.sensitivity * delta
			rotation.x = clamp(rotation.x, -PI/2, PI/4)
			rotation.y -= rotation_input.x * Global.sensitivity * delta * 3.0
			rotation.y = wrapf(rotation.y, 0.0, TAU)

			camera_nest.global_position = lerp(camera_nest.global_position, spring_position.global_position, delta * lerp_power /2.0)
			camera_nest.look_at(follow_target.global_position, Vector3.UP)
			if lock_action.is_triggered() and lock_action_current_cooldown >= lock_action_cooldown:
				lock_action_current_cooldown = 0.0
				camera_toggled = true
				current_camera_state = camera_state.LOCK_ON
				position_camera_behind_player()
			handleShakes(delta)

		camera_state.LOCK_ON:
			camera.fov = move_toward(camera.fov, focused_FOV, delta * 10.0)
			if lock_on_sprite.visible:
				animator_2d.stop()
				lock_on_sprite.hide()

			if lock_action.is_triggered() and lock_action_current_cooldown >= lock_action_cooldown:
				lock_action_current_cooldown = 0.0
				current_camera_state = camera_state.NORMAL
				camera_toggled = false
				return

			if lock_on_area.has_overlapping_bodies():
				var colinearity : float = -10.0
				var array_with_bodies : Array[Node3D] = lock_on_area.get_overlapping_bodies()
				var camera_front : Vector3 = -camera_nest.global_basis.z
				for body : Node3D in array_with_bodies:
					var candidate_colinearity : float = camera_front.dot(body.global_position.normalized())
					if candidate_colinearity > colinearity:
						if locked_enemy == null:
							if body.lockable:
								current_camera_state = camera_state.ENEMY_ACQUIRED
								colinearity = candidate_colinearity
								locked_enemy = body
								locked_enemy_list.append(locked_enemy)
						else:
							if body.is_in_group("enemy"):
								if body.lockable:
									current_camera_state = camera_state.ENEMY_ACQUIRED
									colinearity = candidate_colinearity
									locked_enemy = body
									locked_enemy_list.append(locked_enemy)
			if !tween.is_running():
				rotation = _target_rotation
			position = lerp(position, original_target.position, delta * lerp_power)
			camera_nest.global_position = lerp(camera_nest.global_position, spring_position.global_position, delta*lerp_power)
			camera.rotation = Vector3.ZERO

		camera_state.ENEMY_ACQUIRED:
			camera.fov = move_toward(camera.fov, focused_FOV, delta * 10.0)
			if locked_enemy == null:
				current_camera_state = camera_state.LOCK_ON
				locked_enemy_list.clear()
				animator_2d.stop()
				lock_on_sprite.hide()
				return

			if lock_action.is_triggered() and lock_action_current_cooldown >= lock_action_cooldown:
				current_camera_state = camera_state.NORMAL
				camera_toggled = false
				lock_action_current_cooldown = 0.0
				locked_enemy_list.clear()
				animator_2d.stop()
				lock_on_sprite.hide()
				return

			var overlapping_bodies : Array[Node3D] = lock_on_area.get_overlapping_bodies()
			if change_lcck.value_bool and lock_changeable:
				lock_on_timer.start(lock_on_cooldown)
				lock_changeable = false
				var found_something : bool = false
				for body : Node3D in overlapping_bodies:
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
			if !(locked_enemy in overlapping_bodies):
				current_camera_state = camera_state.LOCK_ON
				locked_enemy_list.clear()
				animator_2d.stop()
				lock_on_sprite.hide()
				return
				
			follow_target.global_position = lerp(follow_target.global_position, locked_enemy.global_position, delta)
			var rotation_input : Vector2 = rotate_action.value_axis_2d

			rotation.x -= rotation_input.y * Global.sensitivity * delta
			rotation.x = clamp(rotation.x, -PI/2, PI/4)
			rotation.y -= rotation_input.x * Global.sensitivity * delta * 3.0
			rotation.y = wrapf(rotation.y, 0.0, TAU)

			camera_nest.global_position = lerp(camera_nest.global_position, spring_position.global_position, delta*lerp_power)
			camera_nest.look_at(follow_target.global_position)
			camera.rotation = Vector3.ZERO

			lock_on_sprite.show()
			lock_on_sprite.global_position = camera.unproject_position(locked_enemy.global_position)
			if !animator_2d.is_playing():
				animator_2d.play("rotate_lock")
