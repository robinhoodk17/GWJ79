extends Node3D

@export_group("functionality")
@export var death_screen : CanvasLayer
@export var animation_player : AnimationPlayer

@export_group("stats")
@export var max_health : int = 100
var current_health : int = max_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func take_damage(damage : int) -> void:
	current_health -= damage
	if current_health <= 0:
		die()


func die() -> void:
	death_screen.show()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		animation_player.play("tail_attack")
