#version 420
 
layout (triangles) in;
//layout (line_strip, max_vertices=100) out;
layout (triangle_strip, max_vertices=3) out;

uniform mat4 m_projView_test;
uniform mat4 m_projView_camX;
uniform mat4 m_projView_camZ;

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

	// Calculate triangle normal
	vec4 v1 = gl_in[1].gl_Position - gl_in[0].gl_Position;
	vec4 v2 = gl_in[2].gl_Position - gl_in[0].gl_Position;
	
	vec3 normal = abs(cross(v1.xyz, v2.xyz));

	// Set the projection view matrix by choosing the camera that better "sees" the object
	float m = max(normal.x, normal.z);

	mat4 m_projView;

	if (m == normal.x) m_projView = m_projView_camX;
	else m_projView = m_projView_camZ;

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

	// gl_Position = m_projView_test * gl_in[0].gl_Position;
	// EmitVertex();
	// gl_Position = m_projView_test * vec4(gl_in[0].gl_Position.xyz + 2 * DataIn[0].normal, gl_in[0].gl_Position.w);
	// EmitVertex();
	// EndPrimitive();

	// gl_Position = m_projView_test * gl_in[1].gl_Position;
	// EmitVertex();
	// gl_Position = m_projView_test * vec4(gl_in[1].gl_Position.xyz + 2 * DataIn[1].normal, gl_in[1].gl_Position.w);
	// EmitVertex();
	// EndPrimitive();

	// gl_Position = m_projView_test * gl_in[2].gl_Position;
	// EmitVertex();
	// gl_Position = m_projView_test * vec4(gl_in[2].gl_Position.xyz + 2 * DataIn[2].normal, gl_in[2].gl_Position.w);
	// EmitVertex();
	// EndPrimitive();

}