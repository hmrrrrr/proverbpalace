shader_type canvas_item;

uniform float speed = 4;
varying vec2 uv;
void vertex() {
	float time = TIME*speed;
	int frame = (int(time))%2;
	if (frame == 0) {
		UV.y /= 2.;
	} else if (frame == 1){
		UV.y = UV.y/2. + .5;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
