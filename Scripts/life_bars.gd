extends ProgressBar

class_name LifeBars

@onready var bar: Timer = $"../Timer"

var life_drain = 1
var life_gain = 3
var timer_time = 0.4 #Ah yes, timer time.


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer()
	bar.wait_time = timer_time
	$"..".visible = false
	Global.picked_plant.connect(picked_plant)

func picked_plant() -> void:
	$"..".visible = true
	timer()

func timer():
	if Global.plants > 0:
		bar.start()
		await bar.timeout
		if Global.in_sun == false:
			$".".value -= life_drain
		elif Global.in_sun == true:
			$".".value += life_gain
		if Global.drinking_water == false:
			$"../Thirst Bar".value -= life_drain
		elif Global.drinking_water == true:
			$"../Thirst Bar".value += life_gain
		if Global.sleeping == false:
			$"../Sleep Bar".value -= life_drain
		elif Global.sleeping == true:
			$"../Sleep Bar".value += life_gain
		timer()
		if $".".value == 0 or $"../Thirst Bar".value == 0 or $"../Sleep Bar".value == 0:
			Global.lost_game.emit()
