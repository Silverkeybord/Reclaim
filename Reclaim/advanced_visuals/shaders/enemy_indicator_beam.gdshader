shader_type spatial;

// AI GENERATED

render_mode blend_add, unshaded, shadows_disabled;

uniform vec4 normal_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);



void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = normal_color.rgb;
}
