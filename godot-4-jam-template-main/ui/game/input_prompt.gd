extends RichTextLabel


@export var action : GUIDEAction

func _ready() -> void:
	call_deferred("update")


func update() -> void:
	var formatter : GUIDEInputFormatter = GUIDEInputFormatter.for_active_contexts()
	var action_string : String = await formatter.action_as_richtext_async(action)
	text = "[center]interact  %s[/center]" % action_string
