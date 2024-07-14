shader_type spatial;
render_mode unshaded;

render_mode cull_disabled;
render_mode depth_test_disabled, fog_disabled;

uniform int eye_index;
uniform sampler2D imageTexture;

void fragment() {
	if (VIEW_INDEX != eye_index) discard;
	ALBEDO = texture(imageTexture, UV.xy).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
