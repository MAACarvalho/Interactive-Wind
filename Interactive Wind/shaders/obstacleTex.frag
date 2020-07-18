#version 430

uniform sampler2D tex;

in vec4 texCoord;

out vec4 outColor;

void main()
{

	vec4 text = texture(tex, texCoord.xy);

	outColor = vec4(float(text.x), float(text.y), float(text.z), 1.0);

}
