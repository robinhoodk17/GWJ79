extends UiPage

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Input.set_deferred("mouse_mode", Input.MOUSE_MODE_VISIBLE)
		ui.go_to("PauseMenu")
		get_tree().paused = true
		accept_event()


func _toggle_guide_debugger(toggled_on: bool) -> void:
	%GuideDebugger.visible = toggled_on
	%ToggleGuideDebugger.release_focus()
	await get_tree().process_frame
	%ToggleGuideDebugger.release_focus()
