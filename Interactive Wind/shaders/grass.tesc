#version 410

layout(vertices = 4) out;

uniform int grass_density;

void main() {

	if (gl_InvocationID == 0) {

		gl_TessLevelOuter[0] = grass_density;
		gl_TessLevelOuter[1] = grass_density;
		gl_TessLevelOuter[2] = grass_density;
		gl_TessLevelOuter[3] = grass_density;
		
		gl_TessLevelInner[0] = grass_density;
		gl_TessLevelInner[1] = grass_density;
	
	}

	gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;

}