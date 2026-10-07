shader_type canvas_item;

varying vec4 vertex_color;

void vertex() {
	vertex_color = COLOR;
}

float snapf(float value, float step_size) {
    return floor(value / step_size) * step_size;
}

void fragment() {
	vec2 uv = UV;
	//uv.y = snapf(uv.y,TEXTURE_PIXEL_SIZE.y);
	uv.x -= .5;
	float circle = sqrt(1.-(2.*uv.y-1.)*(2.*uv.y-1.));
	uv.x /= circle;
	uv.x += .5;
	COLOR = texture(TEXTURE,uv)*vertex_color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
