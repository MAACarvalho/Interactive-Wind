#version 410

uniform sampler2D blade_1;
uniform sampler2D blade_2; 	
uniform sampler2D blade_3; 	
uniform sampler2D blade_4; 	
uniform sampler2D blade_5; 	
uniform sampler2D blade_6; 	
uniform sampler2D blade_7;	

in Data {

	//vec3 normal;
	//float height;
	//vec3 eye;
	//vec3 light_dir;
	vec2 texture_coord;
	vec3 origin_point;
	//float inclination;

} DataIn;

out vec4 output;

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

void main() {

	// Setting the specular term to black
	/*vec4 spec = vec4(0.0);

	float intensity = max(dot(DataIn.normal, DataIn.light_dir), 0.0);

	// If the vertex is lit compute the specular color
	if (intensity > 0.0) {
		// Computing the half vector
		vec3 h = normalize(DataIn.light_dir + DataIn.eye);	
		// compute the specular intensity
		float intSpec = max(dot(h,DataIn.normal), 0.0);
		// compute the specular term into spec
		spec = specular * pow(intSpec, shininess);
	}*/

	// Getting texture coordinates
	vec2 texture_coord = DataIn.texture_coord;

	// Generating a random number [0,1] with the grass blade original position
	float random = noise(DataIn.origin_point * 1235);

	// Choosing random grass blade texture based on the random generated
	vec4 tex;
	if 		(random < 0.14285) 	tex = texture (blade_1, texture_coord);
	else if (random < 0.28571) 	tex = texture (blade_2, texture_coord);
	else if (random < 0.42857) 	tex = texture (blade_3, texture_coord);
	else if (random < 0.57142) 	tex = texture (blade_4, texture_coord);
	else if (random < 0.71428) 	tex = texture (blade_5, texture_coord);
	else if (random < 0.85714) 	tex = texture (blade_6, texture_coord);
	else 						tex = texture (blade_7, texture_coord);

	if  (tex.a < 0.5f) discard;

	//outputF = max(intensity *  tex + spec, tex * 0.25);
	output = tex;

}