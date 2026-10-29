shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_nearest;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;  // glitch strength
uniform float cover : hint_range(0.0, 1.0) = 0.0;      // fraction of bars blacked out
uniform float bar_count = 20.0;
uniform float bar_displace : hint_range(0.0, 0.5) = 0.15;
uniform float jitter : hint_range(0.0, 0.05) = 0.015;
uniform float steps_per_second = 18.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	float t = floor(TIME * steps_per_second);
	vec2 uv = SCREEN_UV;
	float band = floor(uv.y * bar_count);

	// displaced bars: more of them move as intensity rises
	if (hash(vec2(band, t)) < intensity * 0.6) {
		uv.x += (hash(vec2(band, t + 17.0)) - 0.5) * 2.0 * bar_displace * intensity;
	}

	// whole-screen jitter
	uv += (vec2(hash(vec2(t, 1.0)), hash(vec2(t, 2.0))) - 0.5) * 2.0 * jitter * intensity;

	vec3 c = texture(screen_tex, uv).rgb;

	// bars cut to black
	if (hash(vec2(band, t + 91.0)) < cover) {
		c = vec3(0.0);
	}
	// anything pulled in from off-screen is black
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		c = vec3(0.0);
	}

	COLOR = vec4(c, 1.0);
}