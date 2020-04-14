#version 410

// Blade textures
uniform sampler2D bld_tex_1;
uniform sampler2D bld_tex_2; 	
uniform sampler2D bld_tex_3; 	
uniform sampler2D bld_tex_4; 	
uniform sampler2D bld_tex_5; 	
uniform sampler2D bld_tex_6; 	
uniform sampler2D bld_tex_7;	

uniform float rnd_seed;             // Seed used for variation of the blades

in Data {

	flat int blade_id;
	vec2 texture_coord;

} DataIn;

out vec4 output;

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

	// Getting texture coordinates
	vec2 texture_coord = DataIn.texture_coord;

	// Generating a random number [0,1] with the grass blade original position
	float random = noise(DataIn.blade_id * rnd_seed * 1235);

	// Choosing random grass blade texture based on the random generated
	vec4 tex;
	if 	   (random < 0.14285) 	tex = texture (bld_tex_1, texture_coord);
	else if (random < 0.28571) 	tex = texture (bld_tex_2, texture_coord);
	else if (random < 0.42857) 	tex = texture (bld_tex_3, texture_coord);
	else if (random < 0.57142) 	tex = texture (bld_tex_4, texture_coord);
	else if (random < 0.71428) 	tex = texture (bld_tex_5, texture_coord);
	else if (random < 0.85714) 	tex = texture (bld_tex_6, texture_coord);
	else 						tex = texture (bld_tex_7, texture_coord);

	if (tex.a < 0.8f) discard;
	
	output = tex;
	
}