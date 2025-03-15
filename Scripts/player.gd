extends CharacterBody3D

#Camera
@export var SENSATIVITY = 0.3
@onready var pivot = $CameraTarget

#Player
const SPEED = 10.0
const JUMP_VELOCITY = 4.5

func _ready():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$CameraTarget/SpringArm3D.add_excluded_object(self)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * SENSATIVITY))
		pivot.rotate_x(deg_to_rad(-event.relative.y * SENSATIVITY))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-45), deg_to_rad(35))
	
		if Input.is_action_pressed("Esc"):
			get_tree().quit()
		if Input.is_action_pressed("E"):
			if $RayCast3D.get_collider() is FarmHouse:
				$"../Lose Screen/ColorRect/Label".text = "You Win!"
				Global.lost_game.emit()

		if Input.is_action_pressed("E"):
			if $RayCast3D.get_collider() is PlantPickup:
				$"../Plant Pickup".position.y -= 100
				$Plant.visible = true
				Global.plants += 1
				Global.picked_plant.emit()

func _process(_delta):
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("A", "D", "W", "S")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		$AnimationPlayer.play("Walk")
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 9.0)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 9.0)
		$AnimationPlayer.play("RESET")

	move_and_slide()


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
