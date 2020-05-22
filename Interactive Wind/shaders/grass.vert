#version 410

#define M_PI 3.1415926535897932384626433832795

in vec4 position;

out Data {

    int blade_id;
  
    vec3 up;
    vec3 tangent;

    vec4 control_point;

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

vec4 translate (vec4 pos) {

    // Translating & Centering based on instance ID
    int lines = int(floor(sqrt(instance_count)));

    int x_index = int(floor(gl_InstanceID / lines));
    int z_index = int(mod(gl_InstanceID, lines));

    float separation = bld_separation + (noise(gl_InstanceID * rnd_seed * 7644) - 0.5) * bld_separation_var;

    pos.x += (x_index - (lines - 1) / 2.0) * (bld_width + separation);
    pos.z += (z_index - (lines - 1) / 2.0) * (bld_width + separation);

    return pos;

}

vec4 calculate_tip () {

        // Scaling, Rotating & Inclining
        float height = bld_height + (noise(gl_InstanceID * rnd_seed * 4751) - 0.5) * bld_height_var;
        float rotation = (bld_rotation + (noise (gl_InstanceID * rnd_seed * 6153) - 0.5) * bld_rotation_var) * 2 * M_PI;
        float inclination = (bld_inclination + (noise (gl_InstanceID * rnd_seed * 8072) - 0.5) * bld_inclination_var) * 0.5 * M_PI;
        
        DataOut.up = normalize (vec3 (sin(rotation) * sin(inclination), 
                                      cos(inclination), 
                                      cos(rotation) * sin(inclination)) - vec3(0, 0, 0));

        DataOut.tangent = normalize (vec3 (cos(rotation), 
                                           0, 
                                           - sin(rotation)));

        vec4 initial_tip = vec4(vec3(0, 0, 0) + height * DataOut.up, 1);
        
        // Calculating normal vector to the inclined blade
        vec3 normal = normalize(
                    vec3(height * sin(M_PI + rotation) * sin(- M_PI * 0.5 + inclination), 
                         height * cos(M_PI * 0.5 + inclination), 
                         height * cos(M_PI + rotation) * sin(- M_PI * 0.5 + inclination)) 
                -   vec3(0, 0, 0));

        // Calculating new tip
        vec4 tip = initial_tip;

        // Applying gravity
        float grass_mass = 1.0f; // Ignoring it for now
        vec3 environment_gravity = grass_mass * (vec3(0, -1, 0) * 9.80665);
        vec3 front_gravity = 0.25 * length (environment_gravity) * normal.xyz;
        
        tip.xyz += (environment_gravity + front_gravity);

        // Applying wind
        

        // Calculating recovery
        float stiffness = bld_stiffness + (noise(gl_InstanceID * rnd_seed * 4274) - 0.5) * bld_stiffness_var;
        vec3 recovery = (initial_tip.xyz - tip.xyz) * stiffness;

        tip.xyz += recovery;        

        // Calculating control point for Bezier Curve
        float length_proj = length(tip.xyz - vec3(0, 0, 0) - DataOut.up * dot (tip.xyz - vec3(0, 0, 0), DataOut.up));

        DataOut.control_point.xyz = vec3(0, 0, 0) + height * DataOut.up * max (1 - length_proj / height, 0.05 * max (length_proj / height, 1));

        // Correcting points to ensure blade length is mantained
        vec3 fstSegment = DataOut.control_point.xyz - vec3(0, 0, 0);
        vec3 sndSegment = tip.xyz - DataOut.control_point.xyz;

        float L0 = length(tip.xyz - vec3(0, 0, 0));
        float L1 = length(fstSegment) + length(sndSegment);
        float bezier_length = (2 * L0 + L1) / 3.0f;

        float ratio = height / bezier_length;
        DataOut.control_point.xyz = vec3(0, 0, 0) + ratio * fstSegment;
        tip.xyz = DataOut.control_point.xyz + ratio * sndSegment;

        // Translating control point as well
        DataOut.control_point = translate(DataOut.control_point);

        return tip;

}

void main() {

    DataOut.blade_id = gl_InstanceID;

    vec4 pos = position;

    // Transforming tip based on forces and blade properties
    if (gl_VertexID == 1) pos = calculate_tip ();

    gl_Position = translate(pos) * m_model;

}



