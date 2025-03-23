extends OmniLight3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	Signalbus.day_started.connect(day)
	Signalbus.night_started.connect(night)


func day() -> void:
	hide()


func night() -> void:
	show()
