#version 430

uniform sampler2D wind_tex;

in vec4 texCoord;

uniform float wind_scale;
uniform vec3 wind_direction;

out vec4 outColor;

void main()
{

	vec4 tex = texture(wind_tex, texCoord.xy);

	//outColor = vec4(float(tex.x) / wind_scale / wind_direction.x, float(tex.y) / wind_scale / wind_direction.y, float(tex.z) / wind_scale / wind_direction.z, 1.0);

	outColor = vec4(float(tex.x) / wind_scale, float(tex.y) / wind_scale, float(tex.z) / wind_scale, 1.0);

}
