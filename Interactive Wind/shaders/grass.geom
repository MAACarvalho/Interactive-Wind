#version 420
 
layout (triangles) in;
layout (triangle_strip, max_vertices=6) out;

uniform mat4 m_projView;

in Data {

	int blade_id;
	vec2 texture_coord;

} DataIn[];

out Data {

	flat int blade_id;
	vec2 texture_coord;

} DataOut;

void emitFrontFace () {

	// Front-face
	DataOut.texture_coord = DataIn[0].texture_coord;
	gl_Position = m_projView * gl_in[0].gl_Position;
	EmitVertex();

	DataOut.texture_coord = DataIn[1].texture_coord;
	gl_Position = m_projView * gl_in[1].gl_Position;
	EmitVertex();

	DataOut.texture_coord = DataIn[2].texture_coord;
	gl_Position = m_projView * gl_in[2].gl_Position;
	EmitVertex();

	EndPrimitive();

}

void emitBackFace () {

	// Back-face
	DataOut.texture_coord = DataIn[0].texture_coord;
	gl_Position = m_projView * gl_in[0].gl_Position;
	EmitVertex();

	DataOut.texture_coord = DataIn[2].texture_coord;
	gl_Position = m_projView * gl_in[2].gl_Position;
	EmitVertex();

	DataOut.texture_coord = DataIn[1].texture_coord;
	gl_Position = m_projView * gl_in[1].gl_Position;
	EmitVertex();

	EndPrimitive();

}

void main()
{

	DataOut.blade_id = DataIn[0].blade_id;

	vec3 v1 = gl_in[0].gl_Position.xyz - gl_in[1].gl_Position.xyz;
	vec3 v2 = gl_in[2].gl_Position.xyz - gl_in[1].gl_Position.xyz;

	vec3 triangle_normal = cross(normalize(v2), normalize(v1));

	// Ignoring "invisible" triangles
	if (length(triangle_normal) > 0.000001) { emitFrontFace(); emitBackFace();}
	else EndPrimitive();


}