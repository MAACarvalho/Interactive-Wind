#version 410

#define M_PI 3.1415926535897932384626433832795

in vec4 position;
in vec2 texCoord;

out Data {

    int blade_id;
  
    vec3 up;
    vec3 tangent;

    vec4 control_point;

} DataOut;

uniform float rnd;  

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
uniform float bld_stiffness; 		    // Base stiffness of a grass blade
uniform float bld_stiffness_var; 	  // Variation in the stiffness of a grass blade


uniform float rnd_seed;             // Seed used for variation of the blades

uniform mat4 m_model;

uniform float timer;

uniform sampler2D wind_tex;


/////////////////////////////////////////////////////////////////////////////
// Description: Generic GLSL 1D Noise function							   //	
// Author: Patricio Gonzalez Vivo										   //	
// Link: https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83 //
/////////////////////////////////////////////////////////////////////////////

//	Simplex 3D Noise 
//	by Ian McEwan, Ashima Arts
//
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
float snoise(vec3 v){ 
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

  // First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

  // Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //  x0 = x0 - 0. + 0.0 * C 
  vec3 x1 = x0 - i1 + 1.0 * C.xxx;
  vec3 x2 = x0 - i2 + 2.0 * C.xxx;
  vec3 x3 = x0 - 1. + 3.0 * C.xxx;

  // Permutations
  i = mod(i, 289.0 ); 
  vec4 p = permute( permute( permute( 
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

  // Gradients
  // ( N*N points uniformly over a square, mapped onto an octahedron.)
  float n_ = 1.0/7.0; // N=7
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

  //Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

  // Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
                                dot(p2,x2), dot(p3,x3) ) );
}


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

    float separation = bld_separation + (noise(gl_InstanceID * rnd_seed + 7644) - 0.5) * bld_separation_var;

    if (separation != 0) {
        
        pos.x += (x_index - (lines - 1) / 2.0) * (bld_width + separation);
        pos.z += (z_index - (lines - 1) / 2.0) * (bld_width + separation);

    }

    return pos;

}

vec4 calculate_tip () {

    // Scaling, Rotating & Inclining
    float height = max(0, bld_height + (noise(gl_InstanceID * rnd_seed + 4751) - 0.5) * bld_height_var);
    float rotation = (bld_rotation + (noise (gl_InstanceID * rnd_seed + 6153) - 0.5) * bld_rotation_var) * 2 * M_PI;
    float inclination = min(1, max(0, (bld_inclination + (noise (gl_InstanceID * rnd_seed + 8072) - 0.5) * bld_inclination_var))) * 0.5 * M_PI;
    
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

    // Translating base & tip in the world
    vec4 translated_base = translate(vec4(0,0,0,0));
    vec4 translated_tip = translate(tip);

    // Calculating texture coordinates & checking wind texture
    int lines = int(floor(sqrt(instance_count)));
	int x_index = int(floor(gl_InstanceID / lines));
    int z_index = int(mod(gl_InstanceID, lines));

    vec4 wind = texture (wind_tex, vec2((translated_base.xz + 15.0) / 30.0));

    // Applying wind force to the grass
    if (wind.xyz != vec3(0,0,0)) {

        float fd = 1 - abs ( dot( normalize(wind.xyz), normalize(translated_tip.xyz - translated_base.xyz)));
        float fr = dot (translated_tip.xyz - translated_base.xyz, DataOut.up) / height;
        float theta = fd *  fr;

        vec4 wind_force = wind * theta;

        tip.xyz += vec3(wind_force.x, wind_force.y, wind_force.z);
        
    }

    // Calculating recovery
    float stiffness = min(1, max(0, bld_stiffness - noise(gl_InstanceID * rnd_seed + 4274) * bld_stiffness_var));
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
    DataOut.control_point = vec4(translate(DataOut.control_point).xyz, 1);

    return tip;

}

void main() {

    DataOut.blade_id = gl_InstanceID;

    vec4 pos = position;

    // Transforming tip based on forces and blade properties
    if (gl_VertexID == 1) pos = calculate_tip ();

    gl_Position = m_model * translate(pos);

}



