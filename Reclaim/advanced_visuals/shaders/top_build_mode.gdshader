shader_type canvas_item;

// Screen texture uniform required in Godot 4
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// CRT Parameters
uniform float curvature : hint_range(0.0, 10.0) = 2.0;
uniform float scanline_count : hint_range(0.0, 1000.0) = 300.0;
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.25;
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.4;

// Noise Parameters
uniform float noise_amount : hint_range(0.0, 1.0) = 0.15;
uniform float noise_speed : hint_range(0.0, 50.0) = 15.0;

// Simple PRNG function for generating pseudo-random values
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Applies curved distortion to UV coordinates
vec2 curve_uv(vec2 uv) {
    vec2 st = uv * 2.0 - 1.0;
    vec2 offset = abs(st.yx) / vec2(curvature);
    st = st + st * offset * offset;
    return st * 0.5 + 0.5;
}

void fragment() {
    // 1. Calculate curved UV coordinates
    vec2 uv = curve_uv(SCREEN_UV);

    // 2. Clamp UVs to screen edges so border regions stretch/warp instead of cutting to black
    vec2 clamped_uv = clamp(uv, vec2(0.001), vec2(0.999));

    // 3. Fetch base screen color using clamped coordinates
    vec4 text = texture(SCREEN_TEXTURE, clamped_uv);

    // 4. Generate dynamic grayscale noise
    float time_step = floor(TIME * noise_speed);
    float noise = random(clamped_uv + vec2(time_step));
    
    // Blend noise into screen texture color
    vec3 color_with_noise = mix(text.rgb, vec3(noise), noise_amount);

    // 5. Apply Scanlines
    float scanline = sin(clamped_uv.y * scanline_count * 3.14159) * 0.5 + 0.5;
    scanline = pow(scanline, 1.5);
    color_with_noise *= mix(1.0, scanline, scanline_intensity);

    // 6. Apply Vignette (gradually darkens borders without fully blacking out warped edges)
    vec2 uv_vignette = clamped_uv * (1.0 - clamped_uv.yx);
    float vig = uv_vignette.x * uv_vignette.y * 15.0;
    vig = pow(vig, vignette_intensity);
    color_with_noise *= clamp(vig, 0.0, 1.0);

    COLOR = vec4(color_with_noise, text.a);
}