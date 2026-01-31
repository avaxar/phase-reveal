shader_type canvas_item;

varying vec2 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	if (mod((TIME * 32.0 + world_position.x + world_position.y), 16.0) < 8.0) {
		COLOR = vec4(1.0, 1.0, 1.0, 0.75);
	}
	else {
		COLOR = vec4(1.0, 1.0, 1.0, 0.5);
	}
}
