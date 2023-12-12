shader_type canvas_item;

uniform float clipping_length: hint_range(0., 1., .01) = .1;
uniform vec3 edge_color: source_color = vec3(1., 1., 1.);
uniform vec3 inside_color: source_color = vec3(0., 0., 0.);
uniform float color_influence = 1.;

const vec2[4] CORNERS = {
	vec2(-1., -1.),
	vec2(-1., 1.),
	vec2(1., -1.),
	vec2(1., 1.)
};

float calculate_min_distance(vec2 pos, vec2[4] centers) {
	// Distance to the closest edge
	float min_dist = min(min(abs(pos.x + 1.), abs(pos.x - 1.)), min(abs(pos.y + 1.), abs(pos.y - 1.)));

	// Distance to the closest clipped corner
	for (int i = 0; i < centers.length(); i++) {
		vec2 center = centers[i];
		vec2 direction = normalize(pos - center);
		vec2 point_on_arc = center + direction * clipping_length;
		float length = length(point_on_arc - pos);

		float pos_length_to_rect_corner = length(CORNERS[i] - pos);
		float arc_pos_length_to_rect_corner = length(CORNERS[i] - point_on_arc);

		if (pos_length_to_rect_corner < arc_pos_length_to_rect_corner) {
			return length;
		}
		else {
			continue;
		}

		min_dist = min(min_dist, length);
	}
	return min_dist;
}

void fragment() {

	vec2[4] corner_center = {
		vec2(-1. + clipping_length, -1. + clipping_length),
		vec2(-1. + clipping_length, 1. - clipping_length),
		vec2(1. - clipping_length, -1. + clipping_length),
		vec2(1. - clipping_length, 1. - clipping_length)
	};

	vec2 pos = (UV - .5) * 2.;
	bool inside = false;

	for (int i = 0; i < CORNERS.length(); i++) {
		vec2 corner = CORNERS[i];
		vec2 center = corner_center[i];
		bool inside_corner = all(lessThanEqual(abs(pos - corner), vec2(clipping_length)));
		bool outside_center = length((pos - center)) > clipping_length;
		inside = inside || (inside_corner && outside_center);
	}

	float dist = calculate_min_distance(pos, corner_center);

	COLOR = vec4(mix(inside_color, edge_color, pow(1. - dist, color_influence)), inside ? 0. : 1.);

}

