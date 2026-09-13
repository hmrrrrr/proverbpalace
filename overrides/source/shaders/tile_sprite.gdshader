shader_type canvas_item;

#include "res://source/shaders/hsv.gdshaderinc"

instance uniform bool hole_enabled;
instance uniform bool epsilon_enabled;
instance uniform bool mutagen_enabled = false;
instance uniform vec2 hole_local_position;

uniform sampler2D hole_mask : filter_nearest;
uniform sampler2D tile_wraparound : filter_nearest;

uniform vec3 mutagen_color_a : source_color = vec3(0.45882353, 0.5764706, 0.9411765);
uniform vec3 mutagen_color_b : source_color = vec3(0.9529412, 0.44705883, 0.6313726);

varying vec2 local_position;

const float WRAPAROUND_STRIPES = 8.;
const float WRAPAROUND_SPEED = .75;
const float WRAPAROUND_STRIPE_WIDTH = .5;

void vertex() {
	local_position = VERTEX;
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (hole_enabled) {
		vec2 hole_size = vec2(textureSize(hole_mask, 0));
		vec2 position_in_hole = local_position - hole_local_position;
		if (
			position_in_hole.x >= 0.0 && 
			position_in_hole.y >= 0.0 &&
			position_in_hole.x <= hole_size.x &&
			position_in_hole.y <= hole_size.y
		) {
			vec2 hole_uv = position_in_hole / hole_size;
			if (texture(hole_mask, hole_uv).a != 0.0) discard;
		}
	}
	if (mutagen_enabled) {
		if (COLOR.g < 0.3 && COLOR.g > 0.01) {
			COLOR.rgb = vec3(1.,1.,1.);
		} else {
		float t = TIME*1.5;
		float val_r = (sin(t)*.5+.5);
		float val_g = (sin(t+PI)*.5+.5);
		float v = COLOR.r + COLOR.g + COLOR.b;
		if ((v > 0.)) {
			COLOR.rgb *= (mutagen_color_a*val_r + mutagen_color_b*val_g);
		}
		}
	}
	if (epsilon_enabled){
		vec3 hsv = rgb_to_hsv(COLOR.rgb);
		float s = hsv.g;
		float v = hsv.b;
		vec4 wraparound_sample = texture(tile_wraparound, UV);
		float wraparound_amt = wraparound_sample.r*wraparound_sample.a;
		wraparound_amt *= WRAPAROUND_STRIPES;
		wraparound_amt -= TIME*WRAPAROUND_SPEED;
		wraparound_amt = fract(wraparound_amt);
		//COLOR.r = wraparound_amt;
		if (COLOR.a*wraparound_sample.a > 0.) {
			if ((wraparound_amt < WRAPAROUND_STRIPE_WIDTH || wraparound_sample.a < 0.001) ){
				COLOR.a = 1.;
			}
			//hsv.b = 1.-hsv.b;
			//COLOR.rgb = hsv_to_rgb(hsv);
		}
	}
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
