shader_type canvas_item;

uniform vec4 highlight_color: hint_color = vec4(1, 1, 1, 1);
uniform bool is_highlight = false;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (is_highlight && color.a == 0.0) {
		color = highlight_color;
	}
	COLOR = color;
}