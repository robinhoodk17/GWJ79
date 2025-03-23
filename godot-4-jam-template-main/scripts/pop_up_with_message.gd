extends Node3D

@onready var label: RichTextLabel = $SubViewport/Label
@onready var _message: Label = $SubViewport/Message
@export var action : GUIDEAction
@export var message : String
@export var turn_off : bool = true


func _ready() -> void:
	if turn_off:
		call_deferred("turn_off_prompt")
	else:
		call_deferred("pop_up_show")

func turn_off_prompt() -> void:
	hide()


func pop_up_show():
	show()
	var formatter : GUIDEInputFormatter = GUIDEInputFormatter.for_active_contexts(100)
	var input_label = await formatter.action_as_richtext_async(action)
	_message.text = message
	label.text = "[center]%s[center]" % [input_label]
