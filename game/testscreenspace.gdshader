shader_type spatial;
render_mode skip_vertex_transform;
render_mode cull_disabled;
render_mode unshaded;

void vertex() {
		// i.e. stretch quad across the entire screen.
	    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
//VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.)).xyz;
}

void fragment() {
	ALBEDO = vec3(1,0,0);
	ALPHA = 1.0;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
