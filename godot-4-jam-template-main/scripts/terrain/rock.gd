extends CharacterBody3D

@export var damaging : bool = false
@export var damage_amount : int = 10
@export var HitBox : Area3D
@export var timer : Timer
var falling = false
func _ready() -> void:
	HitBox.body_entered.connect(deal_damage)
	timer.timeout.connect(start_falling)
	timer.start()
	

func _physics_process(delta: float) -> void:
	if falling:
		velocity += get_gravity() * delta
		move_and_slide()


func deal_damage(body : Node3D) -> void:
	if damaging:
		if body.is_in_group("player"):
			body.take_damage(damage_amount)
			damaging = false
	queue_free()

func start_falling() -> void:
	falling = true
