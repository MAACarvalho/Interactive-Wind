#version 410

layout(quads, fractional_odd_spacing, ccw) in;

uniform	mat4 m_projView;

in Data {

	int blade_id;

} DataIn[];

out Data {

	int blade_id;
	vec2 texture_coord;

} DataOut;

void main() {

	float u = gl_TessCoord.x;
	float v = gl_TessCoord.y;
	float w = 1 - u - v;
	
	vec4 p1 = mix(gl_in[0].gl_Position, gl_in[1].gl_Position, u);
	vec4 p2 = mix(gl_in[3].gl_Position, gl_in[2].gl_Position, u);
	
	DataOut.blade_id       =    DataIn[0].blade_id;
	DataOut.texture_coord  =    vec2(u, v);

	gl_Position = mix(p1, p2, v);
}

