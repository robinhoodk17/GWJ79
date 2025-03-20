extends RichTextLabel


@export var action : GUIDEAction
@export var label_size : float
func _ready() -> void:
	call_deferred("update")


func update() -> void:
	var formatter : GUIDEInputFormatter = GUIDEInputFormatter.for_active_contexts(label_size)
	var action_string : String = await formatter.action_as_richtext_async(action)
	text = "[center]%s[/center]" % action_string
