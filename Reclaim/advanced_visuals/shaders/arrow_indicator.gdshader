shader_type spatial;

render_mode blend_add, unshaded, shadows_disabled, vertex_lighting;

uniform vec4 arrow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float center_alpha : hint_range(0.0, 1.0) = 0.3;
uniform float fresnel_power : hint_range(0.1, 8.0) = 2.0;
uniform float fresnel_strength : hint_range(0.0, 10.0) = 5.0;

void fragment() {
	vec3 normal_direction = normalize(NORMAL);
	vec3 view = normalize(VIEW);
	
	float fresnel = pow(
		1.0 - dot(NORMAL, view),
		fresnel_power
	) * fresnel_strength;
	
	ALBEDO = arrow_color.rgb;
	
	ALPHA = mix(center_alpha, 1.0, fresnel);
	
	EMISSION = arrow_color.rgb * fresnel;
}