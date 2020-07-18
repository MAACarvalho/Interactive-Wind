#version 420

layout(rgba32f) uniform writeonly image2D imageUnit;

in Data {

	vec4 world_position;
	vec3 normal;
	vec2 texture_coord;

} DataIn;

out vec4 output;

void main() {

	ivec2 posInTex = ivec2 ( (DataIn.world_position.xz + 15.0) / 30.0 * 256 ) ;
	
	imageStore(imageUnit, posInTex, vec4(DataIn.normal * 0.5 + 0.5, 1.0));
	
	output = vec4(DataIn.normal * 0.5 + 0.5, 1.0);
	
}