extends Label

@onready var timer: Timer = $"../Timer"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var time_left = timer.get_time_left()
	text = "Time Left: " + str(time_left)
	if time_left <= 10.0:
		visible_characters = 15
	if time_left <= 0.0:
		Global.lost_game.emit()
