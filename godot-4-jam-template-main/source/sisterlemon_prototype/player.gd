extends CharacterBody3D

@export_group("functionality")
enum states{IDLE, WALKING, TAIL_ATTACK, BLOCKED, DYING}
@export var game_UI : Control
@export var death_screen : CanvasLayer
@export var death_screen_label : Label
@export var interact_prompt : Control
@export var animation_player : AnimationPlayer
@export var tail_attack_action : GUIDEAction
@export var move_action : GUIDEAction
@export var interact : GUIDEAction
@export var camera : Camera3D
@export var camera_spring_arm : SpringArm3D
@export var mesh_parent : Node3D
@export var plant : Node3D
@export var interaction_raycast : RayCast3D
var current_state : states = states.WALKING

@export_group("Stats")
@export var speed : float = 10.0
@export var attack_range : float = 5.0
@export var kaiju_height : float = 10.0
@export var kaiju_radius : float = 2.5
@export var cd_between_attacks : float = 1.0
@export var max_health : int = 100
@export var turn_speed : float = 20.0
var current_health : int = max_health

func _ready() -> void:
	interaction_raycast.add_exception(self)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_spring_arm.add_excluded_object(self)
	call_deferred("late_ready")


func late_ready() -> void:
	game_UI.show()

func handle_inputs(delta : float) -> void:
	if tail_attack_action.is_triggered():
		animation_player.play("tail_attack")
		current_state = states.TAIL_ATTACK
		velocity = Vector3.ZERO
		return

	var input_dir : Vector2 = move_action.value_axis_2d
	var direction : Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		animation_player.play("Walk")
		direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		var target_rotation : Basis = Basis.looking_at(velocity, Vector3.UP)
		mesh_parent.basis =	mesh_parent.basis.slerp(target_rotation, delta * turn_speed)
	else:
		animation_player.play("RESET")
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if !interaction_raycast.is_colliding():
		interact_prompt.hide()
		return
	interact_prompt.show()
	if interact.is_triggered():
		if interaction_raycast.get_collider() is FarmHouse:
			death_screen.text = "You Win!"
			Global.lost_game.emit()
		if interaction_raycast.get_collider() is PlantPickup:
			$"../Plant Pickup".position.y -= 100
			plant.visible = true
			Global.plants += 1
			Global.picked_plant.emit()


func _physics_process(delta: float) -> void:	
	match current_state:
		states.WALKING:
			if not is_on_floor():
				velocity += get_gravity() * delta
			handle_inputs(delta)
			move_and_slide()


func start_walking() -> void:
	current_state = states.WALKING


func take_damage(damage : int) -> void:
	current_health -= damage
	if current_health <= 0:
		die()


func die() -> void:
	Global.lost_game.emit()


@warning_ignore("unused_parameter")
func _on_bar_spot_1_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	Global.in_sun = !Global.in_sun


@warning_ignore("unused_parameter")
func _on_bar_spot_1_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	Global.in_sun = !Global.in_sun


@warning_ignore("unused_parameter")
func _on_bar_spot_3_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	Global.sleeping = !Global.sleeping


@warning_ignore("unused_parameter")
func _on_bar_spot_3_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	Global.sleeping = !Global.sleeping


@warning_ignore("unused_parameter")
func _on_bar_spot_2_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	Global.drinking_water = !Global.drinking_water


@warning_ignore("unused_parameter")
func _on_bar_spot_2_body_shape_exited(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	Global.drinking_water = !Global.drinking_water
