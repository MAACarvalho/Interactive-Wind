#version 410

layout(quads, fractional_odd_spacing, ccw) in;

uniform	mat4 m_projView;

uniform uint bld_levels = 1; 		// Vertical divisions of each grass blade
uniform float bld_height;           // Height of each grass blade
uniform float bld_width;            // Width of each grass blade
uniform float bld_separation;       // Distance between blades
uniform float bld_stiffness; 		// Base stiffness of a grass blade
uniform float bld_stiffness_var; 	// Variation in the stiffness of a grass blade
uniform float bld_stiffness_comp; 	// Compensation for the stiffness of a grass blade

uniform float rnd_seed;             // Seed used for variation of the blades

in Data {

	int blade_id;

} DataIn[];

out Data {

	flat int blade_id;
	flat vec3 upright_unit_vector;
	flat vec3 torque_joint;
	flat vec3 gravity_joint;
	flat vec3 bending_joint;
	vec2 texture_coord;

} DataOut;

/////////////////////////////////////////////////////////////////////////////
// Description: Generic GLSL 1D Noise function							   //	
// Author: Patricio Gonzalez Vivo										   //	
// Link: https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83 //
/////////////////////////////////////////////////////////////////////////////

float rand(float n) {return fract(sin(n) * 43758.5453123);}

float noise(float p){
	float fl = floor(p);
    float fc = fract(p);
	return mix(rand(fl), rand(fl + 1.0), fc);
}
/////////////////////////////////////////////////////////////////////////////

void main() {

	float u = gl_TessCoord.x;
	float v = gl_TessCoord.y;
	float w = 1 - u - v;
	
	vec4 p1 = mix(gl_in[0].gl_Position, gl_in[1].gl_Position, u);
	vec4 p2 = mix(gl_in[3].gl_Position, gl_in[2].gl_Position, u);
	
	DataOut.blade_id = DataIn[0].blade_id;
	DataOut.texture_coord = vec2(u, v);

	// Applying bending
	vec3 gravitational_acceleration = vec3 (0.0, -9.80665, 0.0);
	DataOut.gravity_joint = (1.0 - v) * bld_height * gravitational_acceleration; // * density

	DataOut.upright_unit_vector = normalize(gl_in[2].gl_Position.xyz - gl_in[1].gl_Position.xyz);
	
	DataOut.torque_joint  = ((1.0 - v) * bld_height * DataOut.upright_unit_vector) + DataOut.gravity_joint;
	//DataOut.torque_joint  = cross((1.0 - v) * bld_height * DataOut.upright_unit_vector, DataOut.gravity_joint);

	float stiffness = bld_stiffness + (noise(DataIn[0].blade_id * rnd_seed * 7816) - 0.5) * bld_stiffness_var;
	float stiffness_joint = stiffness / (bld_height * v + bld_stiffness_comp);

	DataOut.bending_joint = DataOut.torque_joint * stiffness_joint;

	gl_Position = mix(p1, p2, v);
}

