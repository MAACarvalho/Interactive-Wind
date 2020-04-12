#version 420
 
layout(points) in;

layout (line_strip, max_vertices=2) out;

uniform	mat4 m_projView;

void main()
{

	//emitGrassBlade(gl_in[0].gl_Position);
	
	gl_Position = m_projView * gl_in[0].gl_Position;
	EmitVertex();

	gl_Position = m_projView * (gl_in[0].gl_Position + vec4(0, 0.5, 0, 0));
	EmitVertex();

	EndPrimitive();


}

