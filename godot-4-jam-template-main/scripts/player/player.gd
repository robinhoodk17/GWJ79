extends CharacterBody3D
class_name player
@export_group("farm")
#region farm variables
@onready var farm1: MeshInstance3D = $MeshParent/Farm/farm1
@onready var farm2: MeshInstance3D = $MeshParent/Farm/farm2
@onready var farm3: MeshInstance3D = $MeshParent/Farm/farm3
@onready var farm4: MeshInstance3D = $MeshParent/Farm/farm4


@export var farm_1_timer: Timer
@export var farm_2_timer: Timer
@export var farm_3_timer: Timer
@export var farm_4_timer: Timer


@export var default_material:Material
@export var planted_material:Material
@export var sapling_growing_time:float=5
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
@export var lock_on_area : Area3D
@export_subgroup("animation")
@export var mesh_parent : Node3D
@export var animation_player : AnimationPlayer
@export var carried_enemy_position : Marker3D
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

#sounds
@onready var walk_sound: AudioStreamPlayer = $sounds/walk
@onready var bellow_sound: AudioStreamPlayer = $sounds/bellow
@onready var roar_sound: AudioStreamPlayer = $sounds/roar
@onready var seed_sound: AudioStreamPlayer = $sounds/seed



func _ready() -> void:

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
			walk_sound.stop()
			#if walk_sound.finished:
				
			velocity=Vector3.ZERO
			set_animstate("Idle")
		states.WALKING_CARRYING:
			walk_sound.play_varied()
			
			if carried_enemy == null:
				velocity=Vector3.ZERO
				set_animstate("Idle")
				current_state = states.IDLE
				return
				
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
			walk_sound.play_varied()
				
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
			walk_sound.stop()
			bellow_sound.play()
			velocity = Vector3.ZERO
			set_animstate_oneshot("Tail_Attack")
			current_state=states.TRANSITION
		states.BITE_ATTACK:
			walk_sound.stop()
			bellow_sound.play()
			velocity = Vector3.ZERO
			set_attack_animation("Bite_Attack", 3.0)
			current_state=states.TRANSITION
			return
		states.BITE_ATTACK_KILL:
			walk_sound.stop()
			bellow_sound.play()
			velocity = Vector3.ZERO
			set_attack_animation("Bite_Attack_Kill", 3.0)
			current_state = states.TRANSITION
			carrying_enemy = true
			if targeted_enemy._current_health <= bite_damage:
				var duplicate = targeted_enemy.duplicate()
				duplicate.player_node = self
				get_tree().root.add_child(duplicate)
				targeted_enemy.delete_entity()
				targeted_enemy = duplicate
				targeted_enemy.start_ragdoll()
				carried_enemy = targeted_enemy
			return
		states.THROWING:
			walk_sound.stop()
			bellow_sound.play()
			current_state=states.TRANSITION
			velocity = Vector3.ZERO
			set_attack_animation("Throw_Enemy", 3.0)
		states.STOMP_ATTACK:
			walk_sound.stop()
			roar_sound.play()
			current_state=states.TRANSITION
			velocity = Vector3.ZERO
			set_animstate_oneshot("Stomp_Attack")
			velocity = Vector3.ZERO
			current_stomp_cooldown = 0.0
		states.TRANSITION:
			walk_sound.stop()
			pass


func go_idle():	# used to go back to idle state after animation to be used as "Call method track" in animation player
	current_state=states.IDLE
	
func _physics_process(delta: float) -> void:
	#print(Global.plants_list)
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
			if current_stomp_cooldown < stomp_cooldown:
				return
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
	var distance = carried_enemy.global_position.distance_to(targeted_enemy.global_position)
	carried_enemy.start_throw(targeted_enemy, throw_speed, distance, throw_damage)
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
	$CameraPivot/UI/Game/Health.value = current_health
	current_health -= damage
	if current_health <= 0:
		die()


func die() -> void:
	Global.lost_game.emit()

#endregion

##farm
#region New Code Region

func _on_seed_picked(type):
	seed_sound.pitch_scale=1.0
	seed_sound.play()
	match Global.seeds_carried:

		1:
			Global.plants_list[0]=type
			farm1.material_override=planted_material
			farm_1_timer.start(sapling_growing_time)
		2:
			Global.plants_list[1]=type
			farm2.material_override=planted_material
			farm_2_timer.start(sapling_growing_time)
		3:
			Global.plants_list[2]=type
			farm3.material_override=planted_material
			farm_3_timer.start(sapling_growing_time)
		4:
			Global.plants_list[3]=type
			farm4.material_override=planted_material
			farm_4_timer.start(sapling_growing_time)
			
func _on_seed_dropped():
	seed_sound.pitch_scale=0.9
	seed_sound.play()
	match Global.seeds_carried:

		0:
			farm1.material_override=default_material
			farm1.get_node("plant1_small").visible=false
			farm1.get_node("plant2_small").visible=false
			farm1.get_node("plant3_small").visible=false
			farm1.get_node("plant4_small").visible=false		
			Global.plants_list[0]=0
		1:
			farm2.material_override=default_material
			farm2.get_node("plant1_small").visible=false
			farm2.get_node("plant2_small").visible=false
			farm2.get_node("plant3_small").visible=false
			farm2.get_node("plant4_small").visible=false
			Global.plants_list[1]=0
		2:
			farm3.material_override=default_material
			farm3.get_node("plant1_small").visible=false
			farm3.get_node("plant2_small").visible=false
			farm3.get_node("plant3_small").visible=false
			farm3.get_node("plant4_small").visible=false
			Global.plants_list[2]=0
		3:
			farm4.material_override=default_material
			farm4.get_node("plant1_small").visible=false
			farm4.get_node("plant2_small").visible=false
			farm4.get_node("plant3_small").visible=false
			farm4.get_node("plant4_small").visible=false
			Global.plants_list[3]=0

func _on_farm_1_timer_timeout() -> void:
	Global.saplings_carried+=1
	display_plant(1)
	
func _on_farm_2_timer_timeout() -> void:
	Global.saplings_carried+=1
	display_plant(2)
func _on_farm_3_timer_timeout() -> void:
	Global.saplings_carried+=1
	display_plant(3)
func _on_farm_4_timer_timeout() -> void:
	Global.saplings_carried+=1
	display_plant(4)

func display_plant(farm_num):
	var farm=farm1
	match farm_num:
		1:
			farm=farm1
		2:
			farm=farm2
		3:
			farm=farm3
		4:
			farm=farm4
			
	match Global.plants_list[farm_num-1]:
		1:
			farm.get_node("plant1_small").visible=true
		2:
			farm.get_node("plant2_small").visible=true
		3:
			farm.get_node("plant3_small").visible=true
		4:
			farm.get_node("plant4_small").visible=true
			
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
