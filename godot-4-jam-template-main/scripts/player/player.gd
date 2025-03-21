extends CharacterBody3D
class_name player
@export_group("farm")
#region farm variables
@export var farm1: CSGBox3D
@export var farm2: CSGBox3D
@export var farm3: CSGBox3D
@export var farm4: CSGBox3D

@export var sapling1: MeshInstance3D
@export var sapling2: MeshInstance3D
@export var sapling3: MeshInstance3D
@export var sapling4: MeshInstance3D

@export var farm_1_timer: Timer
@export var farm_2_timer: Timer
@export var farm_3_timer: Timer
@export var farm_4_timer: Timer


@export var default_material:Material
@export var planted_material:Material
@export var sapling_growing_time:float
#endregion

@export_group("controls, camera, and animation")
#region Nodes for functionality
enum states{IDLE, WALKING,TAIL_ATTACK,BITE_ATTACK,STOMP_ATTACK,TRANSITION, BLOCKED, DYING, BITE_ATTACK_KILL, WALKING_CARRYING, THROWING}
@export_subgroup("UI")
@export var game_UI : Control
@export var death_screen : CanvasLayer
@export var death_screen_label : Label
#@export var interaction_raycast : RayCast3D
@export_subgroup("GUIDE actions")
@export var tail_attack_action : GUIDEAction
@export var bite_action : GUIDEAction
@export var stomp_action : GUIDEAction
@export var move_action : GUIDEAction
#@export var interact : GUIDEAction
@export_subgroup("camera")
@export var camera : Camera3D
@export var camera_spring_arm : SpringArm3D
@export var camera_pivot : Node3D
@export_subgroup("animation")
@export var mesh_parent : Node3D
@export var animation_player : AnimationPlayer
@export var carried_enemy_position : Marker3D
@export var lock_on_area : Area3D
var current_state : states = states.WALKING
var direction : Vector3 = Vector3.ZERO
var targeted_enemy : Node3D = null
var carrying_enemy : bool = false
var carried_enemy : Node3D = null
#endregion

@export_group("Stats")
#region player Stats
##movement speed
@export var speed : float = 10.0
@export var throw_speed : float = 15.0
##this is needed for the enemies' navigation
@export var kaiju_height : float = 10.0
##this is needed for the enemies' navigation
@export var kaiju_radius : float = 2.5
@export var cd_between_attacks : float = 1.0
@export var max_health : int = 100
##how fast the model turns to look at the direction it is moving
@export var turn_speed : float = 20.0
@export var stomp_cooldown : float = 15.0
@export var tail_cooldown : float = 5.0
@export var bite_damage : float = 10.0
@export var bite_damage_force : float = 20.0
@export var throw_damage : float = 60.0
var current_stomp_cooldown : float = stomp_cooldown
var current_tail_cooldown : float = tail_cooldown

var current_health : int = max_health
#endregion
@onready var animation_state_machine=$AnimationTree.get("parameters/MoveStateMachine/playback")

func _ready() -> void:
	sapling1.visible=false
	sapling2.visible=false
	sapling3.visible=false
	sapling4.visible=false
	farm_1_timer.timeout.connect(_on_farm_1_timer_timeout)
	farm_2_timer.timeout.connect(_on_farm_2_timer_timeout)
	farm_3_timer.timeout.connect(_on_farm_3_timer_timeout)
	farm_4_timer.timeout.connect(_on_farm_4_timer_timeout)
	
	Signalbus.seed_picked.connect(_on_seed_picked)
	Signalbus.seed_dropped.connect(_on_seed_dropped)
	#interaction_raycast.add_exception(self)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_spring_arm.add_excluded_object(self)
	camera_spring_arm.add_excluded_object(camera_spring_arm)
	animation_player.get_animation("Player_Walk").loop_mode=Animation.LOOP_LINEAR
	animation_player.get_animation("Player_Idle").loop_mode=Animation.LOOP_LINEAR
	call_deferred("late_ready")


func late_ready() -> void:
	game_UI.show()


func state_machine(delta : float) -> void:
	match current_state:
		states.IDLE:
			if is_on_floor():
				velocity=Vector3.ZERO
			set_animstate("Idle")
		states.WALKING_CARRYING:
			if carried_enemy == null:
				set_animstate("Walk")
				current_state = states.WALKING
			else:
				set_animstate("Walk_Holding")
			var input_dir : Vector2 = move_action.value_axis_2d
			direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			
			direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			if camera_pivot.current_camera_state == camera_pivot.camera_state.NORMAL:
				var target_rotation : Basis = Basis.looking_at(velocity, Vector3.UP)
				mesh_parent.basis =	mesh_parent.basis.slerp(target_rotation, delta * turn_speed)
			if camera_pivot.current_camera_state == camera_pivot.camera_state.ENEMY_ACQUIRED:
				if camera_pivot.locked_enemy != null:
					velocity /= 2.0
					var transformed_enemy_position : Vector3 = Vector3\
					(camera_pivot.locked_enemy.global_position.x,\
					mesh_parent.global_position.y, \
					camera_pivot.locked_enemy.global_position.z) - \
					Vector3(global_position.x, 0, global_position.z)
					var target_rotation : Basis = Basis.looking_at(transformed_enemy_position, Vector3.UP)
					mesh_parent.basis =	mesh_parent.basis.slerp(target_rotation, delta * turn_speed / 2.0).orthonormalized()
					mesh_parent.rotation.x = 0.0
			
		states.WALKING:
			set_animstate("Walk")
			var input_dir : Vector2 = move_action.value_axis_2d
			direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			
			direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			if camera_pivot.current_camera_state == camera_pivot.camera_state.NORMAL:
				var target_rotation : Basis = Basis.looking_at(velocity, Vector3.UP)
				mesh_parent.basis =	mesh_parent.basis.slerp(target_rotation, delta * turn_speed)
			if camera_pivot.current_camera_state == camera_pivot.camera_state.ENEMY_ACQUIRED:
				if camera_pivot.locked_enemy != null:
					velocity /= 2.0
					var transformed_enemy_position : Vector3 = Vector3\
					(camera_pivot.locked_enemy.global_position.x,\
					mesh_parent.global_position.y, \
					camera_pivot.locked_enemy.global_position.z) - \
					Vector3(global_position.x, 0, global_position.z)
					var target_rotation : Basis = Basis.looking_at(transformed_enemy_position, Vector3.UP)
					mesh_parent.basis =	mesh_parent.basis.slerp(target_rotation, delta * turn_speed / 2.0).orthonormalized()
					mesh_parent.rotation.x = 0.0
					
		states.TAIL_ATTACK:
			velocity = Vector3.ZERO
			set_animstate_oneshot("Tail_Attack")
			current_state=states.TRANSITION
		states.BITE_ATTACK:
			velocity = Vector3.ZERO
			set_attack_animation("Bite_Attack", 3.0)
			current_state=states.TRANSITION
			return
		states.BITE_ATTACK_KILL:
			velocity = Vector3.ZERO
			set_attack_animation("Bite_Attack_Kill", 1.5)
			current_state = states.TRANSITION
			carrying_enemy = true
			if targeted_enemy._current_health <= bite_damage:
				targeted_enemy._current_health = 0
				targeted_enemy.start_ragdoll()
				carried_enemy = targeted_enemy
			return
		states.THROWING:
			current_state=states.TRANSITION
			velocity = Vector3.ZERO
			set_attack_animation("Throw_Enemy", 2.0)
			
		states.STOMP_ATTACK:
			current_state=states.TRANSITION
			velocity = Vector3.ZERO
			set_animstate_oneshot("Stomp_Attack")
			current_stomp_cooldown = 0.0
		states.TRANSITION:
			pass


func go_idle():	# used to go back to idle state after animation to be used as "Call method track" in animation player
	current_state=states.IDLE
	
func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity()
	#print_debug(current_state)
	var input_dir : Vector2 = move_action.value_axis_2d
	if current_state!=states.TRANSITION:
		if input_dir.length()>0.1:
			if carrying_enemy:
				current_state=states.WALKING_CARRYING
			else:
				current_state=states.WALKING
		else:
			current_state=states.IDLE

		if tail_attack_action.is_triggered():
			current_state=states.TAIL_ATTACK
			current_tail_cooldown = 0.0
		if bite_action.is_triggered():
			var targetable_enemies : Array[Node3D] = lock_on_area.get_overlapping_bodies()
			targeted_enemy = null
			var current_distance = 10000
			for i in targetable_enemies.size():
				if targetable_enemies[i].is_in_group("enemy"):
					if targetable_enemies[i].lockable:
						var candidate_distance = targetable_enemies[i].global_position.distance_squared_to(global_position)
						if candidate_distance < current_distance:
							targeted_enemy = targetable_enemies[i]
			if targeted_enemy != null:
				if carrying_enemy and carried_enemy!= null:
					current_state = states.THROWING
					velocity = Vector3.ZERO
				else:
					carrying_enemy = false
					carried_enemy = null
					if targeted_enemy.small:
						targeted_enemy._current_health = 0
						targeted_enemy.start_ragdoll()
						current_state = states.BITE_ATTACK_KILL
						velocity = Vector3.ZERO
					else:
						targeted_enemy.take_damage(bite_damage, bite_damage_force, targeted_enemy.global_position - global_position)
						current_state=states.BITE_ATTACK
						velocity = Vector3.ZERO
			
		if stomp_action.is_triggered():
			if current_stomp_cooldown >= stomp_cooldown:
				current_state=states.STOMP_ATTACK
		
		
	handle_cooldowns(delta)
	state_machine(delta)
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	if carrying_enemy and carried_enemy!= null:
		carried_enemy.global_position = carried_enemy_position.global_position
		carried_enemy.global_basis = carried_enemy_position.global_basis
func start_throw():
	if targeted_enemy != null:
		var distance = carried_enemy.global_position.distance_to(targeted_enemy.global_position)
		carried_enemy.start_throw(targeted_enemy, throw_speed, distance, throw_damage)
	else:
		carried_enemy.start_throw(targeted_enemy, throw_speed, 0.0, throw_damage)
	carrying_enemy = false
	carried_enemy = null
##combat and state machine
#region New Code Region
func handle_cooldowns(delta : float):
	if current_stomp_cooldown <= stomp_cooldown:
		current_stomp_cooldown += delta
	if current_tail_cooldown <= tail_cooldown:
		current_tail_cooldown += delta

func take_damage(damage : int) -> void:
	current_health -= damage
	if current_health <= 0:
		die()


func die() -> void:
	Global.lost_game.emit()

#endregion

##farm
#region New Code Region

func _on_seed_picked():

	match Global.seeds_carried:

		1:
			farm1.material_override=planted_material
			farm_1_timer.start(sapling_growing_time)
		2:
			farm2.material_override=planted_material
			farm_2_timer.start(sapling_growing_time)
		3:
			farm3.material_override=planted_material
			farm_3_timer.start(sapling_growing_time)
		4:
			farm4.material_override=planted_material
			farm_4_timer.start(sapling_growing_time)
			
func _on_seed_dropped():

	print_debug(Global.seeds_carried)
	match Global.seeds_carried:

		0:
			farm1.material_override=default_material
			sapling1.visible=false			
		1:
			farm2.material_override=default_material
			sapling2.visible=false
		2:
			farm3.material_override=default_material
			sapling3.visible=false
		3:
			farm4.material_override=default_material
			sapling4.visible=false

func _on_farm_1_timer_timeout() -> void:
	Global.saplings_carried+=1
	sapling1.visible=true
func _on_farm_2_timer_timeout() -> void:
	Global.saplings_carried+=1
	sapling2.visible=true
func _on_farm_3_timer_timeout() -> void:
	Global.saplings_carried+=1
	sapling3.visible=true
func _on_farm_4_timer_timeout() -> void:
	Global.saplings_carried+=1
	sapling4.visible=true


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

#endregion

func set_animstate(state_name):	# to set looped animation state
	animation_state_machine.travel(state_name)
	
func set_animstate_oneshot(state_name):# to set oneshot animation state
	$AnimationTree.set("parameters/"+str(state_name)+"/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func set_attack_animation(attack_name : String, time_scale : float = 1.0):
	var attack_animation = $AnimationTree.get_tree_root().get_node("Attack_Animation")
	#$AnimationTree.get_tree_root().get_node("Attack_TimeScale").scale = time_scale
	$AnimationTree.set("parameters/Attack_TimeScale/scale", time_scale)
	attack_animation.animation = attack_name
	$AnimationTree.set("parameters/Activate_Attack/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
