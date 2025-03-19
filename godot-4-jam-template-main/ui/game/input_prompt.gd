extends RichTextLabel


@export var action : GUIDEAction
@export var message : String
func _ready() -> void:
	call_deferred("update")


func update() -> void:
	var formatter : GUIDEInputFormatter = GUIDEInputFormatter.for_active_contexts()
	var action_string : String = await formatter.action_as_richtext_async(action)
	text = "[center]%s %s[/center]" % [message, action_string]
