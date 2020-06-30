#version 410

in Data {

 	vec2 texture_coord;

} DataIn;

out vec4 output;

uniform sampler2D ground;

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

	// Choosing random grass blade texture based on the random generated
	vec4 tex = texture (ground, texture_coord);
	
	output = tex - vec4(0.2, 0.2, 0.2, 0);
	//output = vec4 (0.30980, 0.22353, 0.14118, 0);

}