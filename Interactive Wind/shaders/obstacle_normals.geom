#version 420
 
layout (triangles) in;
layout (line_strip, max_vertices=100) out;

uniform mat4 m_projView;

uniform image2D writeonly obstacleTex;

vec2 posToTex (vec4 position) {

	return floor((position.xz + 15.0 / 2.0) / 15.0 * 256.0);

}

void main()
{

	// Calculate normal
	vec4 v1 = gl_in[1].gl_Position - gl_in[0].gl_Position;
	vec4 v2 = gl_in[2].gl_Position - gl_in[0].gl_Position;
	vec4 v3 = gl_in[2].gl_Position - gl_in[0].gl_Position;

	vec3 normal = normalize(cross(normalize(v1.xyz), normalize(v2.xyz)));

	// Store texture in points
	//imageStore(obstacleTex, posToTex(gl_in[0].gl_Position), normal)
	

	//float min_texel_size = min (15.0 / 256.0, 15.0 / 256.0);

	//for (int i=0; i < 256; i++) {




	//}


	// Emit normals
	gl_Position = m_projView * gl_in[0].gl_Position;
	EmitVertex();
	gl_Position = m_projView * vec4(gl_in[0].gl_Position.xyz + 2 * normal, gl_in[0].gl_Position.w);
	EmitVertex();
	EndPrimitive();

	gl_Position = m_projView * gl_in[1].gl_Position;
	EmitVertex();
	gl_Position = m_projView * vec4(gl_in[1].gl_Position.xyz + 2 * normal, gl_in[1].gl_Position.w);
	EmitVertex();
	EndPrimitive();

	gl_Position = m_projView * gl_in[2].gl_Position;
	EmitVertex();
	gl_Position = m_projView * vec4(gl_in[2].gl_Position.xyz + 2 * normal, gl_in[2].gl_Position.w);
	EmitVertex();
	EndPrimitive();

}