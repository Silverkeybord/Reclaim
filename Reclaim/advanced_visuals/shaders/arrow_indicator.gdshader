shader_type spatial;

render_mode blend_mix, depth_draw_always, cull_disabled;

uniform vec4 arrow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float center_alpha : hint_range(0.0, 1.0) = 0.3;
uniform float fresnel_power : hint_range(0.1, 8.0) = 2.0;
uniform float outline_strength : hint_range(0.0, 10.0) = 5.0;

void fragment() {
	vec3 normal_direction = normalize(NORMAL);
	vec3 view_direction = normalize(VIEW);

	float facing = abs(dot(normal_direction, view_direction));

	float fresnel = pow(1.0 - facing, fresnel_power);

	ALBEDO = arrow_color.rgb;

	ALPHA = mix(center_alpha, 1.0, fresnel);

	EMISSION = arrow_color.rgb * fresnel * outline_strength;
}