shader_type canvas_item;

uniform sampler2D noise_texture;
uniform float speed = 1.;

void fragment() {

	vec2 new_uv_cord = UV + vec2(TIME * speed) * vec2(0., 1.);
	float alpha = texture(noise_texture, fract(new_uv_cord)).r * COLOR.a;

	COLOR = vec4(COLOR.rgb, alpha);
}

