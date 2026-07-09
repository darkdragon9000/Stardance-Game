shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;

uniform float effect_strength : hint_range(0.0, 5.0, 0.01);
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	COLOR = texture(screen_texture, SCREEN_UV);
	COLOR.rgb = (COLOR.rgb + tint_color.rgb) / effect_strength;
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
