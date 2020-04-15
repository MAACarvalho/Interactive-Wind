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

out vec4 output;

void main() {

	output = vec4 (0.0, 1.0, 1.0, 1.0);
	
}