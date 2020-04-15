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

	emitFrontFace ();
	emitBackFace ();
	
}