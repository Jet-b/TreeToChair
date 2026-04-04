shader_type canvas_item;

// --- CRT Screen ---
uniform float curvature: hint_range(1.0, 12.0) = 4.5;
uniform float scanline_intensity: hint_range(0.0, 1.0) = 0.12;
uniform float vignette_strength: hint_range(0.0, 1.0) = 0.35;

// --- Bezel geometry (fraction of container occupied by bezel on each side) ---
uniform float margin_x: hint_range(0.0, 0.3) = 0.055;
uniform float margin_y: hint_range(0.0, 0.3) = 0.07;

// --- Bezel appearance ---
uniform vec4 bezel_color: source_color = vec4(0.185, 0.18, 0.19, 1.0);
uniform float bevel_size: hint_range(0.001, 0.08) = 0.018;
uniform float glow_strength: hint_range(0.0, 1.0) = 0.18;
uniform vec3 glow_tint: source_color = vec3(0.1, 0.85, 0.25);

// --- Power LED (UV space, bottom bezel) ---
uniform vec2 led_pos = vec2(0.5, 0.962);
uniform float led_size: hint_range(0.001, 0.02) = 0.005;
uniform vec3 led_color: source_color = vec3(0.0, 1.0, 0.15);

vec2 crt_curve(vec2 uv) {
	uv = (uv - 0.5) * 2.0;
	uv.x *= 1.0 + pow(abs(uv.y) / curvature, 2.0);
	uv.y *= 1.0 + pow(abs(uv.x) / curvature, 2.0);
	return (uv * 0.5) + 0.5;
}

void fragment() {
	float mx = margin_x;
	float my = margin_y;

	// Screen-local UV — allowed to go outside [0,1] in the bezel region
	vec2 screen_local = vec2(
		(UV.x - mx) / (1.0 - 2.0 * mx),
		(UV.y - my) / (1.0 - 2.0 * my)
	);
	vec2 curved = crt_curve(screen_local);

	// === SCREEN BOUNDARY ===
	// Defined by the CRT curve geometry rather than a rectangle.
	// At top/bottom center the border lies at exactly curved.y == 0/1;
	// further from center the distortion pushes curved.y negative sooner,
	// creating a naturally bowed edge that matches the glass curvature.
	float aa = 0.006;
	float in_screen = smoothstep(-aa, aa, curved.x)
	                * (1.0 - smoothstep(1.0 - aa, 1.0 + aa, curved.x))
	                * smoothstep(-aa, aa, curved.y)
	                * (1.0 - smoothstep(1.0 - aa, 1.0 + aa, curved.y));

	// ---- SCREEN AREA ----
	vec3 screen_col = texture(TEXTURE, clamp(curved, 0.0, 1.0)).rgb;

	// Scanlines
	float scan_y = screen_local.y / SCREEN_PIXEL_SIZE.y;
	float scanline = sin(scan_y * PI) * 0.5 + 0.5;
	screen_col *= 1.0 - scanline_intensity * (1.0 - scanline);

	// Vignette
	vec2 v = (curved - 0.5) * 2.0;
	float vig = 1.0 - dot(v, v) * vignette_strength;
	screen_col *= clamp(vig, 0.0, 1.0);

	// ---- BEZEL AREA ----
	float d_left   = UV.x - mx;
	float d_right  = (1.0 - mx) - UV.x;
	float d_top    = UV.y - my;
	float d_bottom = (1.0 - my) - UV.y;
	float d_min    = min(min(d_left, d_right), min(d_top, d_bottom));
	float d_bezel  = max(0.0, -d_min);

	float bevel = (1.0 - smoothstep(0.0, bevel_size, d_bezel)) * (1.0 - in_screen);

	float w_top    = max(0.0, 1.0 - max(0.0, d_top)    / bevel_size) * (1.0 - in_screen);
	float w_left   = max(0.0, 1.0 - max(0.0, d_left)   / bevel_size) * (1.0 - in_screen);
	float w_bottom = max(0.0, 1.0 - max(0.0, d_bottom) / bevel_size) * (1.0 - in_screen);
	float w_right  = max(0.0, 1.0 - max(0.0, d_right)  / bevel_size) * (1.0 - in_screen);

	float light_w  = max(w_top, w_left)    * bevel;
	float shadow_w = max(w_bottom, w_right) * bevel;

	vec3 bezel_col = bezel_color.rgb + vec3(0.022) * (1.0 - UV.y);
	bezel_col = mix(bezel_col, min(bezel_col * 1.7 + vec3(0.04), vec3(1.0)), light_w  * 0.7);
	bezel_col = mix(bezel_col, bezel_col * 0.38, shadow_w * 0.85);

	vec2 from_center = abs(UV - vec2(0.5)) * 2.0;
	float ao = pow(max(from_center.x, from_center.y), 5.0) * 0.18;
	bezel_col -= vec3(ao) * (1.0 - in_screen);

	float glow = exp(-d_bezel * 22.0) * (1.0 - in_screen) * glow_strength;
	bezel_col += glow_tint * glow;

	float led_dist = length((UV - led_pos) * vec2(16.0 / 9.0, 1.0));
	float led_core = smoothstep(led_size, led_size * 0.35, led_dist);
	float led_halo = exp(-led_dist * 55.0) * 0.5;
	bezel_col = mix(bezel_col, led_color, led_core  * (1.0 - in_screen));
	bezel_col += led_color * led_halo * (1.0 - in_screen);
	bezel_col = clamp(bezel_col, 0.0, 1.0);

	COLOR = vec4(mix(bezel_col, screen_col, in_screen), 1.0);
}
