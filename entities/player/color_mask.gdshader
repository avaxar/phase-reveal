shader_type canvas_item;

uniform vec4 mask_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 eyes_color = vec4(0.0, 0.0, 0.0, 1.0);

void vertex() {}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	if (distance(tex_color, vec4(0.08, 1.0, 0.0, 1.0)) < 0.02) {
		COLOR = mask_color;
	}
	else if (distance(tex_color, vec4(0.20, 0.05, 0.19, 1.0)) < 0.02) {
		COLOR = eyes_color;
	}
}
