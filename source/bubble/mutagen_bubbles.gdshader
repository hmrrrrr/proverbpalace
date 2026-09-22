shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float bubble_thresh_lower : hint_range(0,1) = 0;
uniform float bubble_thresh_upper : hint_range(0,1) = 1.0;
uniform float shine_threshold_percent : hint_range(0.0, 1.0) = 0.7170000340575;

uniform vec4 color_a : source_color;
uniform vec4 color_b : source_color;


void fragment() {
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
	
	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}
	vec4 c2 = vec4(0,0,0,0);
	
	float t = TIME*1.5;
	float val_r = (sin(t)*.5+.5);
	float val_g = (sin(t+PI)*.5+.5);
	val_r = 1.-(1.-val_r)*(1.-val_r);
	val_g = 1.-(1.-val_g)*(1.-val_g);
	
	if (val_r > val_g) {
		val_g = 0.;
	} else {
		val_r = 0.;
	}
	
	float shine_threshold = mix(bubble_thresh_lower,bubble_thresh_upper,shine_threshold_percent);
	
	if (c.r > bubble_thresh_lower+(1.-val_r*val_r) && c.r < bubble_thresh_upper) {
		c2 += color_a;
	}
	if (c.g > bubble_thresh_lower+(1.-val_g*val_g) && c.g < bubble_thresh_upper) {
		c2 += color_b;
	}
	COLOR = c2;
	if ((c.r < shine_threshold) && (c.g < shine_threshold)) {
		c += .5;
		COLOR.rgb = mix(c2.rgb,1.-c.rgb*.5,(sin(2.*t+SCREEN_UV.x*3.)));
	}
	
	
}