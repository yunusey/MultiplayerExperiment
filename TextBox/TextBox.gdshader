shader_type canvas_item;

uniform float clipping_length: hint_range(0., 1., .01) = .1;
uniform vec3 edge_color: source_color = vec3(1., 1., 1.);
uniform vec3 inside_color: source_color = vec3(0., 0., 0.);
uniform float color_influence = 1.;
uniform sampler2D noise_texture;
uniform float speed = 1.;

float get_closest_corner_distance(vec2 pos, vec2 closest_center) {
	vec2 direction = normalize(pos - closest_center);
	vec2 arc_point = closest_center + direction * clipping_length;
	vec2 distance = pos - arc_point;
	return length(distance);
}

void fragment() {
	vec2 pos = (UV - .5) * 2.0;
	vec2 closest_corner = sign(pos);
	vec2 closest_center = closest_corner - vec2(clipping_length) * sign(pos);

	bool inside_corner = all(lessThanEqual(abs(pos - closest_corner), vec2(clipping_length)));
	bool outside_center = length((pos - closest_center)) > clipping_length;
	bool inside = inside_corner && outside_center;

	// Distance to the closest edge
	float min_dist = min(abs(pos.x - closest_corner.x), abs(pos.y - closest_corner.y));

	// Distance to the closest clipped corner
	float closest_corner_distance = get_closest_corner_distance(pos, closest_corner);

	float dist = (inside_corner && !outside_center) ? min(get_closest_corner_distance(pos, closest_center), min_dist) : min_dist;

	// Let's add some noise! (I like this a lot)
	float noise = texture(noise_texture, UV).r;

	vec3 fragment_color = mix(inside_color, edge_color, pow(clamp(1. - dist + (sin(TIME * speed + noise) + 1.) / 20., 0., 1.), color_influence));
	
	COLOR = vec4(fragment_color, inside ? 0. : 1.);
}
