extends CharacterBody3D

@export_group("functionality")
enum states{IDLE, WALKING, ATTACKING, BLOCKED, DYING, STAGGERED}
@export var nav_agent : NavigationAgent3D
@export var attack_raycast : RayCast3D
@export var animation_player : AnimationPlayer
@export var attack_cd_timer : Timer
var current_state : states = states.IDLE
var player : Node3D

@export_group("Stats")
@export var max_health : int = 50
@export var resistance_against_launch : float = 10.0
@export var speed : float = 25.0
@export var attack_range : float = 5.0
@export var kaiju_height : float = 10.0
@export var kaiju_radius : float = 2.5
@export var cd_between_attacks : float = 1.0
var _current_health : int = max_health
var accumulated_launch : float = 0.0
var launch_distance : float = 0.0
var was_launched_ago : float = 0.0
var launch_direction : Vector3 = Vector3.ZERO
var launch_speed : float = 0.0

func _ready() -> void:
	attack_cd_timer.timeout.connect(start_walking)
	call_deferred("_late_ready")


func _late_ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	current_state = states.WALKING
	nav_agent.height = kaiju_height
	nav_agent.radius = kaiju_radius


func  _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var random_position : Vector3 = Vector3.ZERO
		random_position.x = randf_range(-200,200)
		random_position.y = randf_range(-200,200)
		nav_agent.target_position = random_position


func _physics_process(delta: float) -> void:
	match current_state:
		states.WALKING:
			nav_agent.target_position = Vector3(player.global_position.x, 
			global_position.y, player.global_position.z)
			var destination : Vector3 = nav_agent.get_next_path_position()
			var local_destination : Vector3 = destination - global_position
			var direction : Vector3 = local_destination.normalized()
			if direction:
				look_at(global_position + direction)
			check_for_attack()
			velocity = direction * speed
			if !is_on_floor():
				velocity += get_gravity() * delta
			move_and_slide()
		states.STAGGERED:
			was_launched_ago += launch_speed * delta
			velocity = launch_direction * launch_speed
			move_and_slide()
			if was_launched_ago > launch_distance:
				was_launched_ago = 0
				start_walking()


func check_for_attack() -> void:
	attack_raycast.target_position = Vector3(0, 0 ,-attack_range)
	if attack_raycast.is_colliding():
		var attacked_body : Node3D = attack_raycast.get_collider()
		if attacked_body.is_in_group("player"):
			current_state = states.ATTACKING
			animation_player.play("attack")


func attack_cooldown() -> void:
	attack_cd_timer.start(cd_between_attacks)


func start_walking() -> void:
	current_state = states.WALKING


func take_damage(how_much : int, launch_force : float, _launch_direction : Vector3) -> void:
	accumulated_launch += launch_force
	if accumulated_launch >= resistance_against_launch:
		if animation_player.is_playing():
			animation_player.play("RESET")
		
		current_state = states.STAGGERED
		was_launched_ago = 0.0
		launch_distance = accumulated_launch/resistance_against_launch
		launch_direction = _launch_direction
		launch_speed = (accumulated_launch/resistance_against_launch) * 8.0
		accumulated_launch = 0
	_current_health -= how_much
	if _current_health <= 0:
		die()


func die() -> void:
	current_state = states.DYING
	animation_player.play("die")


func delete_entity() -> void:
	queue_free()
