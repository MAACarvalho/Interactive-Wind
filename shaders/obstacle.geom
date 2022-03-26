#version 420
 
layout (triangles) in;
layout (triangle_strip, max_vertices=3) out;

uniform mat4 m_projView_camY;

in Data {

	vec3 normal;
	vec2 texture_coord;

} DataIn[3];

out Data {

	vec4 world_position;
	vec3 normal;
	vec2 texture_coord;

} DataOut;


void main()
{

	mat4 m_projView = m_projView_camY;

	// Should expand triangle here
	
	// Emit vertices
	DataOut.world_position 	= gl_in[0].gl_Position;
	DataOut.normal 			= DataIn[0].normal;
	DataOut.texture_coord 	= DataIn[0].texture_coord;
	gl_Position 			= m_projView * gl_in[0].gl_Position;
	EmitVertex();

	DataOut.world_position 	= gl_in[1].gl_Position;
	DataOut.normal 			= DataIn[1].normal;
	DataOut.texture_coord 	= DataIn[1].texture_coord;
	gl_Position 			= m_projView * gl_in[1].gl_Position;
	EmitVertex();

	DataOut.world_position 	= gl_in[2].gl_Position;
	DataOut.normal 			= DataIn[2].normal;
	DataOut.texture_coord 	= DataIn[2].texture_coord;
	gl_Position 			= m_projView * gl_in[2].gl_Position;
	EmitVertex();

	EndPrimitive();

}