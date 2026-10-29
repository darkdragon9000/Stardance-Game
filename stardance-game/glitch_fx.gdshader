shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 1.0;      // drive this from code
uniform float bar_count : hint_range(2.0, 64.0) = 16.0;    // horizontal bands
uniform float bar_chance : hint_range(0.0, 1.0) = 0.25;    // fraction of bands shifted per step
uniform float bar_displace : hint_range(0.0, 0.3) = 0.06;  // max horizontal shift (UV units)
uniform float jitter : hint_range(0.0, 0.05) = 0.006;      // whole-sprite shake
uniform float steps_per_second = 12.0;                      // lower = choppier
uniform float burst_rate = 2.0;                             // how often glitch bursts roll
uniform float burst_chance : hint_range(0.0, 1.0) = 0.5;    // 1.0 = always glitching

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	float t = floor(TIME * steps_per_second);
	float burst = step(1.0 - burst_chance, hash(vec2(floor(TIME * burst_rate), 3.0)));
	float k = intensity * burst;

	vec2 uv = UV;

	// displaced bars
	float band = floor(uv.y * bar_count);
	if (hash(vec2(band, t)) < bar_chance) {
		uv.x += (hash(vec2(band, t + 17.0)) - 0.5) * 2.0 * bar_displace * k;
	}

	// whole-image jitter
	uv += (vec2(hash(vec2(t, 1.0)), hash(vec2(t, 2.0))) - 0.5) * 2.0 * jitter * k;

	vec4 c = texture(TEXTURE, uv);

	// don't smear the edge pixels when UVs leave the texture
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		c.a = 0.0;
	}

	COLOR = c;
}