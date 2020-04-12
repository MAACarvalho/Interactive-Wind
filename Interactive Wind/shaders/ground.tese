#version 410

layout(quads, fractional_odd_spacing, cw) in;

out Data {

	vec2 texture_coord;

} DataOut;

uniform mat4 m_projView;

void main() {
	
	// Getting position

	vec4 p1 = mix(gl_in[0].gl_Position, gl_in[1].gl_Position, gl_TessCoord.x);
	vec4 p2 = mix(gl_in[3].gl_Position, gl_in[2].gl_Position, gl_TessCoord.x);
	
	vec4 position = mix(p1, p2, gl_TessCoord.y); // Global space

	DataOut.texture_coord = vec2(gl_TessCoord.x, gl_TessCoord.y);

	gl_Position = m_projView * position;

}