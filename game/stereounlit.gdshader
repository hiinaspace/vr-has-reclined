shader_type spatial;
render_mode unshaded;

render_mode cull_disabled;
render_mode depth_test_disabled, depth_draw_always, fog_disabled;


uniform sampler2D textureL : source_color, repeat_disable;
uniform sampler2D textureR : source_color, repeat_disable;
uniform float separationX;
uniform float zoom;
uniform vec2 offset;

//render_mode skip_vertex_transform;
void vertex() {
//	POSITION = vec4(VERTEX.x, -VERTEX.y, 0.0, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV * zoom + offset;
	vec2 separation = vec2(separationX, 0);
	
	if(VIEW_INDEX==0)
		ALBEDO = texture(textureL,uv - separation).rgb;
	else
		ALBEDO = texture(textureR,uv + separation).rgb;
		

	
	// Place fragment code here.
}