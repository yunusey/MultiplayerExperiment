shader_type canvas_item;

uniform vec3 color: source_color;
uniform sampler2D noise_texture;
uniform float speed: hint_range(0., 5., .01) = 1.;

void fragment() {
	float uv_y = fract(UV.y + TIME * speed);
	float uv_x = UV.x;
	float noise = texture(noise_texture, vec2(uv_x, uv_y)).r;
	COLOR.rgb = mix(COLOR.rgb, color, noise);
}
