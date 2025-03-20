extends Node3D

@onready var label: RichTextLabel = $SubViewport/Label
@export var interact_action : GUIDEAction

func _ready() -> void:
	call_deferred("turn_off_prompt")

func turn_off_prompt() -> void:
	hide()


func pop_up_show():
	show()
	var formatter : GUIDEInputFormatter = GUIDEInputFormatter.for_active_contexts(100)
	var input_label = await formatter.action_as_richtext_async(interact_action)
	label.text = "[center]%s[center]" % [input_label]
