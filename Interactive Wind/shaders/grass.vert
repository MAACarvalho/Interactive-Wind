#version 410

#define M_PI 3.1415926535897932384626433832795

in vec4 position;

out Data {

    int blade_id;
    float blade_height;
    float blade_rotation;

    vec3 up;
    vec3 direction;
    vec3 tangent;

    vec3 normal;
    vec4 control_point;
    vec4 initial_tip;

} DataOut;

uniform uint instance_count;
uniform float bld_height;           // Height of each grass blade
uniform float bld_height_var;       // Variation in blade height
uniform float bld_width;            // Width of each grass blade
uniform float bld_width_var;        // Variation in blade width
uniform float bld_separation;       // Distance between blades
uniform float bld_separation_var;   // Variation in blade separation
uniform float bld_rotation;         // Blade rotation around Y axis
uniform float bld_rotation_var;     // Variation in blade rotation
uniform float bld_inclination;      // Blade inclination
uniform float bld_inclination_var;  // Variation in blade inclination
uniform float bld_stiffness; 		// Base stiffness of a grass blade
uniform float bld_stiffness_var; 	// Variation in the stiffness of a grass blade

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

vec4 transform_tip () {

        // Scaling, Rotating & Inclining
        DataOut.blade_height = bld_height + (noise(gl_InstanceID * rnd_seed * 4751) - 0.5) * bld_height_var;
        DataOut.blade_rotation = (bld_rotation + (noise (gl_InstanceID * rnd_seed * 6153) - 0.5) * bld_rotation_var) * 2 * M_PI;
        float inclination = (bld_inclination + (noise (gl_InstanceID * rnd_seed * 8072) - 0.5) * bld_inclination_var) * 0.5 * M_PI;
        
        DataOut.up = normalize (vec3 (sin(DataOut.blade_rotation) * sin(inclination), 
                                      cos(inclination), 
                                      cos(DataOut.blade_rotation) * sin(inclination)) - vec3(0, 0, 0));

        DataOut.tangent = normalize (vec3 (cos(DataOut.blade_rotation), 
                                           0, 
                                           - sin(DataOut.blade_rotation)));

        DataOut.initial_tip = vec4(vec3(0, 0, 0) + DataOut.blade_height * DataOut.up, 1);
        
        // Calculating normal vector
        DataOut.normal = normalize(
                    vec3(DataOut.blade_height * sin(M_PI + DataOut.blade_rotation) * sin(- M_PI * 0.5 + inclination), 
                         DataOut.blade_height * cos(M_PI * 0.5 + inclination), 
                         DataOut.blade_height * cos(M_PI + DataOut.blade_rotation) * sin(- M_PI * 0.5 + inclination)) 
                -   vec3(0, 0, 0));

        // Calculating new tip
        vec4 tip = DataOut.initial_tip;

        // Applying gravity
        float grass_mass = 1.0f; // Ignoring it for now
        vec3 environment_gravity = grass_mass * (vec3(0, -1, 0) * 9.80665);
        vec3 front_gravity = 0.25 * length (environment_gravity) * DataOut.normal.xyz;
        
        tip.xyz += (environment_gravity + front_gravity);

        // Applying wind
        

        // Calculating recovery
        float stiffness = bld_stiffness + (noise(gl_InstanceID * rnd_seed * 4274) - 0.5) * bld_stiffness_var;
        vec3 recovery = (DataOut.initial_tip.xyz - tip.xyz) * stiffness;

        tip.xyz += recovery;        

        // Calculating control point for Bezier Curve
        float length_proj = length(tip.xyz - vec3(0, 0, 0) - DataOut.up * dot (tip.xyz - vec3(0, 0, 0), DataOut.up));

        DataOut.control_point.xyz = vec3(0, 0, 0) + DataOut.blade_height * DataOut.up * max (1 - length_proj / DataOut.blade_height, 0.05 * max (length_proj / DataOut.blade_height, 1));

        // Correcting points to ensure blade length is mantained
        vec3 fstSegment = DataOut.control_point.xyz - vec3(0, 0, 0);
        vec3 sndSegment = tip.xyz - DataOut.control_point.xyz;

        float L0 = length(tip.xyz - vec3(0, 0, 0));
        float L1 = length(fstSegment) + length(sndSegment);
        float bezier_length = (2 * L0 + L1) / 3.0f;

        float ratio = DataOut.blade_height / bezier_length;
        DataOut.control_point.xyz = vec3(0, 0, 0) + ratio * fstSegment;
        tip.xyz = DataOut.control_point.xyz + ratio * sndSegment;

        return tip;

}

vec4 transform (vec4 pos) {

    // It's tip point
    if (gl_VertexID == 1) pos = transform_tip();

    // Translating & Centering based on instance ID
    // int lines = int(floor(sqrt(instance_count)));

    // int x_index = int(floor(gl_InstanceID / lines));
    // int z_index = int(mod(gl_InstanceID, lines));

    // float separation = bld_separation + (noise(gl_InstanceID * rnd_seed * 7644) - 0.5) * bld_separation_var;

    // pos.x += (x_index - (lines - 1) / 2.0) * (bld_width + separation);
    // pos.z += (z_index - (lines - 1) / 2.0) * (bld_width + separation);

    return pos;

}

void main() {

    DataOut.blade_id = gl_InstanceID;

    gl_Position = transform(position) * m_model;

}



