shader_type canvas_item;

uniform vec3 mutagen_color_a : source_color = vec3(0.45882353, 0.5764706, 0.9411765);
uniform vec3 mutagen_color_b : source_color = vec3(0.9529412, 0.44705883, 0.6313726);

void vertex() {
	float t = TIME*1.5;
	float val_r = (sin(t)*.5+.5);
	float val_g = (sin(t+PI)*.5+.5);
	float v = COLOR.r + COLOR.g + COLOR.b;
	COLOR.rgb *= (mutagen_color_a*val_r + mutagen_color_b*val_g);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
