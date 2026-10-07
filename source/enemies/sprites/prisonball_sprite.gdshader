shader_type canvas_item;

uniform sampler2D pattern : filter_nearest;

uniform float mix_level : hint_range(0.0, 1.0, 0.1);

void fragment() {
	vec4 desired = texture(pattern,SCREEN_UV);
	COLOR *= mix(vec4(1.),desired,mix_level);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
