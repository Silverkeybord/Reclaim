shader_type spatial;


render_mode blend_mix, cull_disabled, depth_draw_opaque;

//============================
// Parameters
//============================

uniform vec4 shield_color : source_color = vec4(0.45, 0.95, 1.0, 0.22);

uniform float health : hint_range(0.0,1.0) = 1.0;

uniform float fresnel_strength : hint_range(0.0,8.0) = 3.5;
uniform float fresnel_power : hint_range(0.8,9.0) = 6.0;

uniform float scan_speed = 5;
uniform float scan_density = 70.0;

uniform float pulse_speed = 2.0;

uniform float grid_size = 35.0;


//============================

void fragment()
{
	//-------------------------
	// View direction
	//-------------------------
	
	vec3 view = normalize(VIEW);
	float fresnel = pow(
		1.0 - dot(NORMAL, view),
		fresnel_power
	) * fresnel_strength;
	
	
	//-------------------------
	// Moving scan lines
	//-------------------------
	
	float scan =
		sin(UV.y * scan_density
		+ TIME * scan_speed);
	
	scan = smoothstep(0.3,0.9,scan);
	
	
	//-------------------------
	// Grid pattern
	//-------------------------

	vec2 grid_uv = fract(UV * grid_size);
	
	float grid =
		step(0.95,grid_uv.x)
		+ step(0.95,grid_uv.y);
	
	grid = clamp(grid,0.0,1.0);
	
	
	//-------------------------
	// Pulse
	//-------------------------
	
	float pulse =
		0.1
		+ 0.9*sin(TIME * pulse_speed);
	
	
	//-------------------------
	// Health
	//-------------------------
	
	float damage_flash = 1.0-health;
	
	
	//-------------------------
	// Final emission
	//-------------------------
	
	float glow =
		fresnel
		+ scan*0.35
		+ grid*0.6
		+ pulse*0.15
		+ damage_flash*0.6;
	
	//-------------------------
	
	ALBEDO = shield_color.rgb;
	
	EMISSION =
		shield_color.rgb * glow * 2.5;
	
	ALPHA =
		shield_color.a
		+ fresnel*0.35
		+ scan*0.08;
}