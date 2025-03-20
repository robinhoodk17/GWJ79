extends ColorRect

var day_color : ShaderMaterial

func _ready() -> void:
	day_color = material

func _process(delta: float) -> void:
	var current_time : float = Global.time
	day_color.set_shader_parameter("current_time", current_time)
	if current_time > 0.4:
		day_color.set_shader_parameter("shader_opacity", 0.25)
	else: 
		day_color.set_shader_parameter("shader_opacity", 0.0)
