shader_type spatial;

// Blend with background using standard alpha mixing (required for transparency)
// Render both front and back faces (essential for shield bubbles - visible from inside)
// Write to depth buffer as opaque to prevent sorting issues with other transparent objects
render_mode cull_disabled, depth_draw_opaque;

//============================
// Parameters
//============================

// Base color of the shield (cyan-blue) with base transparency (0.22)
uniform vec4 shield_color : source_color = vec4(0.45, 0.95, 1.0, 0.22);

// Current shield integrity (1.0 = full, 0.0 = destroyed)
// Drives the damage flash effect - lower health = brighter/more intense glow
uniform float health : hint_range(0.0,1.0) = 1.0;

// Fresnel rim lighting controls:
// Strength: Overall brightness multiplier for edge glow (higher = brighter rim)
uniform float fresnel_strength : hint_range(0.0,8.0) = 3.5;
// Power: Falloff sharpness (higher = tighter, more concentrated edge glow)
uniform float fresnel_power : hint_range(0.8,9.0) = 6.0;

// Horizontal scan line animation:
// Speed: How fast lines scroll upward (units per second)
uniform float scan_speed = 5;
// Density: How many lines appear across the surface (higher = more lines)
uniform float scan_density = 70.0;

// Overall glow pulsing/breathing speed (sine wave oscillation)
uniform float pulse_speed = 2.0;

// Grid pattern density (higher = more/smaller grid cells)
uniform float grid_size = 35.0;


//============================

void fragment()
{
	//-------------------------
	// View direction & Fresnel
	//-------------------------
	
	// Normalize the view vector (points from fragment to camera)
	vec3 view = normalize(VIEW);
	
	// Calculate fresnel term: 
	// dot(NORMAL, view) = 1 when looking straight at surface, 0 at grazing angles
	// 1.0 - dot(...) inverts this so edges = 1, center = 0
	// pow(..., fresnel_power) sharpens the falloff (higher power = tighter rim)
	// * fresnel_strength boosts overall intensity
	float fresnel = pow(
		1.0 - dot(NORMAL, view),
		fresnel_power
	) * fresnel_strength;
	
	
	//-------------------------
	// Moving scan lines
	//-------------------------
	
	// Create sine wave across Y axis (horizontal lines)
	// UV.y * scan_density creates vertical repetition
	// TIME * scan_speed animates the offset, making lines scroll upward
	float scan =
		sin(UV.y * scan_density
		+ TIME * scan_speed);
	
	// Convert smooth sine wave into sharp bands
	// Values below 0.3 become 0 (gap between lines)
	// Values above 0.9 become 1 (bright line)
	// Creates crisp laser-scan effect instead of soft gradient
	scan = smoothstep(0.3,0.9,scan);
	
	
	//-------------------------
	// Grid pattern
	//-------------------------
	
	// Scale UVs by grid_size and keep only fractional part (0.0 to 1.0)
	// This creates repeating tiles across the surface
	vec2 grid_uv = fract(UV * grid_size);
	
	// Detect if we're near the edge of a tile:
	// step(0.95, x) returns 1.0 if x >= 0.95 (last 5% of tile), else 0.0
	// Adding X and Y lines creates a cross/plus pattern at grid intersections
	float grid =
		step(0.95,grid_uv.x)  // Vertical grid lines
		+ step(0.95,grid_uv.y); // Horizontal grid lines
	
	// Clamp to prevent double-brightness at corners where X and Y lines overlap
	// (Without this, intersections would have value 2.0 instead of 1.0)
	grid = clamp(grid,0.0,1.0);
	
	
	//-------------------------
	// Pulse (breathing effect)
	//-------------------------
	
	// Sine wave oscillating over time
	// 0.1 offset prevents complete darkness at minimum
	// Range: -0.8 to 1.0 (negative values get clamped by renderer, creating sharp pulse)
	float pulse =
		0.1
		+ 0.9 * sin(TIME * pulse_speed);
	
	
	//-------------------------
	// Health / Damage flash
	//-------------------------
	
	// Invert health so 1.0 health = 0 flash, 0 health = 1.0 flash
	// This gets added to emission, making shield glow brighter as it takes damage
	float damage_flash = 1.0-health;
	
	
	//-------------------------
	// Final emission composition
	//-------------------------
	
	// Combine all glow sources:
	// - fresnel: Edge rim lighting (primary shape definition)
	// - scan * 0.35: Animated scan lines (subtle, 35% intensity)
	// - grid * 0.6: Tech grid overlay (moderate, 60% intensity)
	// - pulse * 0.15: Breathing animation (subtle, 15% intensity)
	// - damage_flash * 0.6: Damage feedback (strong, 60% intensity)
	float glow =
		fresnel
		+ scan * 0.35
		+ grid * 0.6
		+ pulse * 0.15
		+ damage_flash * 0.6;
	
	//-------------------------
	
	// Set base surface color (diffuse component)
	// Mostly overridden by emission for energy shield effect, but affects scene lighting
	ALBEDO = shield_color.rgb;
	
	// Emission makes the shield appear self-illuminated
	// Multiply color by combined glow factor, then boost by 2.5x for bloom
	EMISSION =
		shield_color.rgb * glow * 2.5;
	
	// Final transparency:
	// + fresnel * 0.35 = edges become more opaque (rim definition)
	// + scan * 0.08 = scan lines slightly increase opacity
	// Note: Can exceed 1.0 at bright edges, renderer clamps automatically
	ALPHA =
		shield_color.a
		+ fresnel * 0.35
		+ scan * 0.08;
}