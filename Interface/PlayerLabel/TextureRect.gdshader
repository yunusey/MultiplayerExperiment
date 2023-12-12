shader_type canvas_item;

uniform sampler2D checked;
uniform vec3 checked_color: source_color = vec3(0., 1., 0.);
uniform sampler2D unchecked;
uniform vec3 unchecked_color: source_color = vec3(1., 0., 0.);
uniform bool situation;

void fragment() {
	float situation_as_float = float(situation);
	
	float checked_alpha = situation_as_float * texture(checked, UV).a;
	float unchecked_alpha = (1. - situation_as_float) * texture(unchecked, UV).a;
	float alpha = checked_alpha + unchecked_alpha;
	
	vec3 checked_color_add = situation_as_float * checked_color;
	vec3 unchecked_color_add = (1. - situation_as_float) * unchecked_color;
	vec3 color = checked_color_add + unchecked_color_add;
	COLOR = vec4(color, alpha);
}