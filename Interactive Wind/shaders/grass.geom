#version 420
 
#define M_PI 3.1415926535897932384626433832795

layout(points) in;

layout (triangle_strip, max_vertices=113) out;

out Data {
    
	vec2 texture_coord;
	vec3 origin_point;

} DataOut;

uniform mat4 m_projView;
uniform float blade_width;
uniform float blade_height;
uniform float max_height_variation;
uniform int blade_levels;
uniform int grass_density;
uniform vec3 grass_size;
uniform float max_rotation_angle; 	 // In Degrees
uniform float max_inclination_angle; // In Degrees

/////////////////////////////////////////////////////////////////////////////
// Description: Generic GLSL 3D Noise function							   //	
// Author: Patricio Gonzalez Vivo										   //	
// Link: https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83 //
/////////////////////////////////////////////////////////////////////////////


float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float noise(vec3 p){
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

/////////////////////////////////////////////////////////////////////////////

vec4 transformPoint (vec4 pos, int level, bool left_right) {

	// Generating random height modifier
	float random_height_scaler = noise (pos.xyz * 4751) * max_height_variation + 1 - max_height_variation * 0.5;
	float level_height = random_height_scaler * blade_height / float(blade_levels);

	vec4 height = vec4 (0, level_height * level, 0, 0);

	// Generating a random angle for rotation
	float random_angle = (noise (pos.xyz * 7537) * 2 - 1) * max_rotation_angle; // [-max_rotation_angle, max_rotation_angle]

	float x_offset = cos (random_angle * M_PI) * blade_width * 0.5;
	float z_offset = sin (random_angle * M_PI) * blade_width * 0.5;

	vec4 rotation = ((left_right) ? vec4 (x_offset, 0, z_offset, 0) : vec4 (- x_offset, 0, - z_offset, 0));

	// Generating a random inclination
	float random_inclination = (noise (pos.xyz * 8072) * 2 - 1) * max_inclination_angle; // [-max_inclination_angle, max_inclination_angle]

	vec3 v1 = normalize(vec3 (x_offset, 0, z_offset) - vec3 (-x_offset, 0, -z_offset)), v2 = vec3 (0, 1, 0);
	vec3 inclination_direction = cross(v1, v2);

	vec4 inclination = vec4 (height.y * cos(M_PI * 0.5 - random_inclination) * inclination_direction.x, 
							 height.y * sin(M_PI * 0.5 - random_inclination), 
							 height.y * cos(M_PI * 0.5 - random_inclination) * inclination_direction.z, 0);

	// Generating a random displacement
	float max_blade_displacement_x = grass_size.x / grass_density - blade_width; 
	float max_blade_displacement_z = grass_size.y / grass_density - blade_width; 

	float random_displacement_x = (noise (pos.xyz * 5246) * 2 - 1) * max_blade_displacement_x;
	float random_displacement_z = (noise (pos.xyz * 2351) * 2 - 1) * max_blade_displacement_z;

	vec4 displacement = vec4 (random_displacement_x, 0, random_displacement_z, 0);

	vec4 position = pos + 
					height + 
					rotation + 
					inclination + 
					displacement;

	return position;

}

void emitGrassBlade (vec4 pos) 
{
	// Front face

	for (int i=0; i <= blade_levels; i++) {

		// "Left" vertex of each level
		DataOut.texture_coord = vec2 (0, float(i) / float(blade_levels));
		DataOut.origin_point  = pos.xyz;

	 	gl_Position = m_projView * transformPoint( pos, i, false );
		EmitVertex();

		// "Right" vertex of each level
		DataOut.texture_coord = vec2 (1, float(i) / float(blade_levels));
		DataOut.origin_point  = pos.xyz;  

		gl_Position = m_projView * transformPoint( pos, i, true );
		EmitVertex();

	}

	EndPrimitive();

	// Back face

	for (int i=0; i <= blade_levels; i++) {

		// "Left" vertex of each level
		DataOut.texture_coord = vec2 (1, float(i) / float(blade_levels));
		DataOut.origin_point  = pos.xyz;  

		gl_Position = m_projView * transformPoint( pos, i, true );
		EmitVertex();

		// "Right" vertex of each level
		DataOut.texture_coord = vec2 (0, float(i) / float(blade_levels));
		DataOut.origin_point  = pos.xyz;  

		gl_Position = m_projView * transformPoint( pos, i, false );
	 	EmitVertex();

	}

	EndPrimitive();
}

void main()
{

	emitGrassBlade(gl_in[0].gl_Position);

}

