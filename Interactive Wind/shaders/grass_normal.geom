#version 420
 
#define M_PI 3.1415926535897932384626433832795

layout (triangles) in;
layout (line_strip, max_vertices=100) out;

uniform mat4 m_projView;

in Data {

	flat int blade_id;
	flat vec3 upright_unit_vector;
	flat vec3 torque_joint;
	flat vec3 gravity_joint;
	flat vec3 bending_joint;
	vec2 texture_coord;

} DataIn[];

out Data {

	vec4 color;

} DataOut;


void draw_vector (vec4 pos, vec4 vector) {

	gl_Position = m_projView * pos;
	EmitVertex();

	gl_Position = m_projView * (pos + vector);
	EmitVertex();

	EndPrimitive();

}

void draw_vectors (vec4 vector, vec4 color) {

	DataOut.color = color;

	for (int i=0; i<3; i++) {

		draw_vector(gl_in[i].gl_Position, vector);

	}

}

void main()
{

	vec3 v1 = gl_in[0].gl_Position.xyz - gl_in[1].gl_Position.xyz;
	vec3 v2 = gl_in[2].gl_Position.xyz - gl_in[1].gl_Position.xyz;

	vec3 triangle_normal = cross(normalize(v2), normalize(v1));

	if (length(triangle_normal) > 0.00001) { // Ignoring "invisible" triangles

		// Normal
		//draw_vectors (vec4(triangle_normal.x, triangle_normal.y, triangle_normal.z, 0.0), 
		//		vec4 ( 0.0, 1.0, 1.0, 1.0 )); // Cyan

		// Upright
		//draw_vectors (vec4(DataIn[0].upright_unit_vector.x, DataIn[0].upright_unit_vector.y, DataIn[0].upright_unit_vector.z, 0.0), 
		//		vec4 ( 0.0, 1.0, 0.0, 1.0 )); // Green

		// Torque
		//draw_vectors (vec4(DataIn[0].torque_joint.x, DataIn[0].torque_joint.y, DataIn[0].torque_joint.z, 0.0), 
		//		vec4 ( 1.0, 0.0, 0.0, 1.0 )); // Red

		// Gravity
		//draw_vectors (vec4(DataIn[0].gravity_joint.x, DataIn[0].gravity_joint.y, DataIn[0].gravity_joint.z, 0.0), 
		//		vec4 ( 0.0, 0.0, 1.0, 1.0 )); // Blue

		// Bending
		draw_vectors (vec4(DataIn[0].bending_joint.x, DataIn[0].bending_joint.y, DataIn[0].bending_joint.z, 0.0), 
				vec4 ( 1.0, 0.0, 1.0, 1.0 )); // Pink
		

	}
	
}

