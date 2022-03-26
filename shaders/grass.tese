#version 410

layout(isolines, equal_spacing) in;

uniform	mat4 m_projView;

uniform uint bld_levels = 1; 		// Vertical divisions of each grass blade

in Data {

	int blade_id;

	vec3 up;
    vec3 tangent;

	vec4 control_point;

} DataIn[];

out Data {

	int blade_id;

	vec3 up;
    vec3 tangent;

	vec4 control_point;

	vec2 texture_coord;

	vec3 normal;

} DataOut;

void main() {

	float v = gl_TessCoord.x;
	
	DataOut.blade_id = DataIn[0].blade_id;

	DataOut.up = DataIn[1].up;
	DataOut.tangent = DataIn[1].tangent;

	DataOut.control_point = DataIn[1].control_point;
	
	DataOut.texture_coord = vec2(0, v);
	
	// Applying bending
	vec3 a = gl_in[0].gl_Position.xyz + v * (DataIn[1].control_point.xyz - gl_in[0].gl_Position.xyz);
	vec3 b = DataIn[1].control_point.xyz + v * (gl_in[1].gl_Position.xyz - DataIn[1].control_point.xyz);
	vec3 pos = a + v * (b - a);

	vec3 bi_tangent = normalize(b - a);

	DataOut.normal = normalize( cross ( DataIn[1].tangent, bi_tangent) );

	gl_Position = vec4(pos, 1);
}

