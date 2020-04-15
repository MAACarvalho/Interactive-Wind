#version 420
 
layout (triangles) in;
layout (line_strip, max_vertices=2) out;

uniform mat4 m_projView;

void main()
{

	vec3 v1 = gl_in[0].gl_Position.xyz - gl_in[1].gl_Position.xyz;
	vec3 v2 = gl_in[2].gl_Position.xyz - gl_in[1].gl_Position.xyz;

	vec3 triangle_normal = normalize(cross(normalize(v2), normalize(v1)));

	gl_Position = m_projView * gl_in[0].gl_Position;
	EmitVertex();

	gl_Position = m_projView * (gl_in[0].gl_Position + 1 * vec4(triangle_normal.x, triangle_normal.y, triangle_normal.z, 0.0));
	EmitVertex();

	EndPrimitive();
	
}

