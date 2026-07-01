shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture;
uniform float scanlines_1 = 500.0;
uniform float scanlines_2 = 25.0;
uniform float scan_reduction = 0.1;
uniform float vignette_alpha : hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float vignette_inner_radius = 0.0;
uniform float vignette_outer_radius = 1.0;

float random(vec2 uv) {
	return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
	vec2 uv_noise = UV * TIME;
	vec2 uv_scan1 = vec2(UV.x, UV.y + TIME);
	vec2 uv_scan2 = vec2(UV.x, UV.y + TIME * 0.4);

	vec4 screen = texture(screen_tex, UV);

	float scanlines1 = sin(uv_scan1.y * scanlines_1) * scan_reduction - scan_reduction;
	float scanlines2 = sin(uv_scan2.y * scanlines_2) * scan_reduction - scan_reduction;

	vec4 noise = vec4(random(uv_noise), random(uv_noise), random(uv_noise), 0.2);

	float vignette_x = abs(UV.x - 0.5) * 2.0;
	float vignette_y = abs(UV.y - 0.5) * 2.0;
	float vignette_q = 1.0 - (1.0 - sqrt(vignette_x * vignette_x + vignette_y * vignette_y) / vignette_outer_radius) / (1.0 - vignette_inner_radius);
	screen += vec4(0, 0, 0, vignette_q * vignette_alpha);

	COLOR = screen * noise;

	COLOR.rgb += vec3(scanlines1);
	COLOR.rgb += vec3(scanlines2);

	COLOR.rgb *= vec3(5, 5, 5);
}