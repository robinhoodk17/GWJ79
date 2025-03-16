extends CharacterBody3D

@export_group("functionality")
enum states{IDLE, WALKING, TAIL_ATTACK, BLOCKED, DYING}
@export var death_screen : CanvasLayer
@export var animation_player : AnimationPlayer
@export var tail_attack_action : GUIDEAction
@export var attack_cd_timer : Timer
@export var move_action : GUIDEAction
@export var camera : Camera3D
@export var mesh_parent : Node3D
var current_state : states = states.WALKING

@export_group("Stats")
@export var speed : float = 20.0
@export var attack_range : float = 5.0
@export var kaiju_height : float = 10.0
@export var kaiju_radius : float = 2.5
@export var cd_between_attacks : float = 1.0
@export var max_health : int = 100
@export var turn_speed : float = 50.0
var current_health : int = max_health


func _physics_process(delta: float) -> void:
	match current_state:
		states.WALKING:
			if tail_attack_action.is_triggered():
				animation_player.play("tail_attack")
				current_state = states.TAIL_ATTACK
				velocity = Vector3.ZERO
				return
			if not is_on_floor():
				velocity += get_gravity() * delta
			var input_dir : Vector2 = move_action.value_axis_2d
			var direction : Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if direction:
				#mesh_parent.look_at(global_position + direction)
				direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
				var target_rotation : Basis = mesh_parent.basis.looking_at(velocity, Vector3.UP)
				mesh_parent.basis =	mesh_parent.basis.slerp(target_rotation, delta * turn_speed)
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				velocity.z = move_toward(velocity.z, 0, speed)
			move_and_slide()


func start_walking() -> void:
	current_state = states.WALKING


func take_damage(damage : int) -> void:
	current_health -= damage
	if current_health <= 0:
		die()


func die() -> void:
	death_screen.show()
