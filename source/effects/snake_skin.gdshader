shader_type canvas_item;

uniform sampler2D noise : filter_nearest;

uniform vec3 color_key : source_color;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR.rgb *= texture(noise,SCREEN_UV).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
