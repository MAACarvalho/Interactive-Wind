#version 420

layout(binding=0, rgba32f) uniform writeonly image2D imageUnit;

in Data {

	vec4 world_position;
	vec3 normal;
	vec2 texture_coord;

} DataIn;

out vec4 output;

void main() {

	ivec2 posInTex = ivec2 ( (DataIn.world_position.xz + 7.5) / 15.0 * 256 ) ;
	//ivec2 posInTex = ivec2 ( gl_FragCoord.x ) ;

	//if (DataIn.normal.x >= 0.5) 
		//imageStore(imageUnit, posInTex, vec4(1.0, 1.0, 0.0, 1.0));
	//else if (DataIn.normal.x <= -0.5) 
		//imageStore(imageUnit, posInTex, vec4(0.0, 1.0, 1.0, 1.0));
	//else if (DataIn.normal.z >= 0.5) 
		//imageStore(imageUnit, posInTex, vec4(1.0, 0.0, 1.0, 1.0));
	//else if (DataIn.normal.z <= -0.5) 
		//imageStore(imageUnit, posInTex, vec4(1.0, 1.0, 1.0, 1.0));
	//else
		//imageStore(imageUnit, posInTex, vec4(DataIn.normal * 0.5 + 0.5, 1.0));

	imageStore(imageUnit, posInTex, vec4(DataIn.normal * 0.5 + 0.5, 1.0));
	
	//imageStore(imageUnit, ivec2 (128, 128), vec4(1.0, 1.0, 1.0, 1.0));

	output = vec4 (1.0, 0.0, 0.0, 1.0);
	
}