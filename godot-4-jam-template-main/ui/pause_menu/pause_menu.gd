extends UiPage

@export var pause_action : GUIDEAction
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_connect_buttons")


func _connect_buttons() -> void:
	if ui:
		%Resume.pressed.connect(_resume)
		%Settings.pressed.connect(ui.go_to.bind("Settings"))
		%Controls.pressed.connect(ui.go_to.bind("Controls"))
		%MainMenu.pressed.connect(_main_menu)
		%Quit.pressed.connect(quit)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_back"):
		get_viewport().set_input_as_handled()
		_resume()


func _resume() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if ui:
		ui.go_to("Game")
	get_tree().paused = false


func _main_menu() -> void:
	get_tree().set_deferred("paused", false)
	get_tree().change_scene_to_file("res://main.tscn")


func quit() -> void:
	get_tree().quit()


func show_ui() -> void:
	show()
	%Resume.grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
