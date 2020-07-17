#version 410

layout(triangles, equal_spacing, cw) in;

uniform mat4 m_projView;

void main() {
	
	// Getting position
	vec4 p0 = gl_in[0].gl_Position * (1 - gl_TessCoord.x - gl_TessCoord.y);
	vec4 p1 = gl_in[1].gl_Position * gl_TessCoord.x;
	vec4 p2 = gl_in[2].gl_Position * gl_TessCoord.y;

	vec4 position = p0 + p1 + p2;

	//gl_Position = m_projView * position;
	gl_Position = position;

}

