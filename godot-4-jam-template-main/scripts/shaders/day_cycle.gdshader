shader_type canvas_item;

uniform sampler2D day_time_colors : hint_default_white;

uniform float current_time : hint_range(0, 1) = 0.0f;

uniform float shader_opacity : hint_range(0, 1) = 1.0f;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 sky_color = texture(day_time_colors, vec2(current_time, 0.0f));
	sky_color.a = shader_opacity;
	COLOR = screen_color * sky_color;
}
