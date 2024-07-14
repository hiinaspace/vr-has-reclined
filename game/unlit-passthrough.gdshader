shader_type spatial;
render_mode unshaded;

render_mode cull_disabled;
render_mode depth_test_disabled, fog_disabled;

uniform sampler2D texturePassthrough : source_color, repeat_disable;

//render_mode skip_vertex_transform;
void vertex() {
//	POSITION = vec4(VERTEX.x, -VERTEX.y, 0.0, 1.0);
}

void fragment() {
		vec4 tex = texture(texturePassthrough,UV);
		ALBEDO = tex.rgb;
		ALPHA = tex.a;
		
	//ALBEDO = vec3(SCREEN_UV,0);
	
	// Place fragment code here.
}