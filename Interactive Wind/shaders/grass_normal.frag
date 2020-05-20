#version 410

in Data {

	vec4 color;

} DataIn;

out vec4 output;

void main() {

	output = DataIn.color;
	
}