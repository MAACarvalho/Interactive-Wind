#version 410

#define M_PI 3.1415926535897932384626433832795

in vec4 position;

out Data {

    int blade_id;

} DataOut;

uniform uint instance_count;
uniform float bld_height;           // Height of each grass blade
uniform float bld_height_var;       // Variation in blade height
uniform float bld_width;            // Width of each grass blade
uniform float bld_width_var;        // Variation in blade width
uniform float bld_separation;       // Distance between blades
uniform float bld_separation_var;   // Variation in blade separation
uniform float bld_inclination;      // Blade inclination
uniform float bld_inclination_var;  // Variation in blade inclination
uniform float bld_rotation;         // Blade rotation around Y axis
uniform float bld_rotation_var;     // Variation in blade rotation

uniform float rnd_seed;             // Seed used for variation of the blades

uniform mat4 m_model;

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

vec4 transform (vec4 pos) {

    // Scaling
    float width = bld_width  + (noise(gl_InstanceID * rnd_seed * 2982) - 0.5) * bld_width_var;
    float height = bld_height + (noise(gl_InstanceID * rnd_seed * 4751) - 0.5) * bld_height_var;

    pos.x *= width;
    pos.y *= height;

    // Translating & Centering based on instance ID
    int lines = int(floor(sqrt(instance_count)));

    int x_index = int(floor(gl_InstanceID / lines));
    int z_index = int(mod(gl_InstanceID, lines));

    float separation = bld_separation + (noise(gl_InstanceID * rnd_seed * 7644) - 0.5) * bld_separation_var;

    pos.x += (x_index - (lines - 1) / 2.0) * (bld_width + separation);
    pos.z += (z_index - (lines - 1) / 2.0) * (bld_width + separation);

    // Inclining top vertices
    if (gl_VertexID == 2 || gl_VertexID == 3) {

        float random_inclination = bld_inclination + (noise (gl_InstanceID * rnd_seed * 8072) - 0.5) * bld_inclination_var;

	    pos.y -= height * (1-0 - cos(M_PI * 0.5 * random_inclination));
	    pos.z -= height * sin(M_PI * 0.5 * random_inclination);

    }

    // Rotating
    float random_angle = bld_rotation + (noise (gl_InstanceID * rnd_seed * 6153) - 0.5) * bld_rotation_var;

    float x_rotation = width * (1 - cos (random_angle * 2 * M_PI));
    float z_rotation = width * sin (random_angle * 2 * M_PI);

	pos.x += (gl_VertexID == 0 || gl_VertexID == 3) ? x_rotation : - x_rotation;
	pos.z += (gl_VertexID == 0 || gl_VertexID == 3) ? z_rotation : - z_rotation;

    return pos;

}

void main() {

    DataOut.blade_id = gl_InstanceID;

    gl_Position = transform(position) * m_model;

}



