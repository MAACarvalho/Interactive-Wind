#version 420
 
#define M_PI 3.1415926535897932384626433832795

layout (lines) in;
layout (triangle_strip, max_vertices=100) out;
//layout (line_strip, max_vertices=100) out;

uniform float bld_width;            // Width of each grass blade
uniform float bld_width_var;        // Variation in blade width

uniform float rnd_seed;             // Seed used for variation of the blades

uniform mat4 m_projView;

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

in Data {

	int blade_id;
	float blade_height;
    float blade_rotation;
	vec2 texture_coord;

	vec3 up;
    vec3 direction;
    vec3 tangent;

	vec4 normal;

	vec4 control_point;

	vec4 initial_tip;

} DataIn[];

out Data {

	flat int blade_id;
	vec2 texture_coord;

} DataOut;

void emitBladeSegment (vec4 p[4], float u[4], float v[4]) {

	DataOut.texture_coord = vec2(u[0] , v[0]);
	gl_Position = m_projView * p[0];
	EmitVertex();

	DataOut.texture_coord = vec2(u[1] , v[1]);
	gl_Position = m_projView * p[1];
	EmitVertex();

	DataOut.texture_coord = vec2(u[2] , v[2]);
	gl_Position = m_projView * p[2];
	EmitVertex();

	DataOut.texture_coord = vec2(u[3] , v[3]);
	gl_Position = m_projView * p[3];
	EmitVertex();

	EndPrimitive();

}

void generateBladeSegment () {

	// Width Scaling
    float width = bld_width  + (noise(DataIn[0].blade_id * rnd_seed * 2982) - 0.5) * bld_width_var;

	// Segment points based o width
	vec4 p0 = gl_in[0].gl_Position - width * 0.5 * vec4(DataIn[0].tangent, 0);
	vec4 p1 = gl_in[0].gl_Position + width * 0.5 * vec4(DataIn[0].tangent, 0);
	vec4 p2 = gl_in[1].gl_Position + width * 0.5 * vec4(DataIn[0].tangent, 0);;
	vec4 p3 = gl_in[1].gl_Position - width * 0.5 * vec4(DataIn[0].tangent, 0);;

	// Emiting front-face segment
	vec4 ff_p[4] = {p0, p1, p3, p2};
	float ff_u[4] = {0, 1, 0, 1};
	float ff_v[4] = {DataIn[0].texture_coord.y, DataIn[0].texture_coord.y, DataIn[1].texture_coord.y, DataIn[1].texture_coord.y};
	emitBladeSegment (ff_p, ff_u, ff_v);

	// Emiting back-face segment
	vec4 bf_p[4] = {p1, p0, p2, p3};
	float bf_u[4] = {1, 0, 1, 0};
	float bf_v[4] = {DataIn[0].texture_coord.y, DataIn[0].texture_coord.y, DataIn[1].texture_coord.y, DataIn[1].texture_coord.y};
	emitBladeSegment (bf_p, bf_u, bf_v);
	
}

void generateBladeLine() {

	// DataOut.texture_coord = vec2(0, 0);
	// gl_Position = m_projView * (gl_in[0].gl_Position + DataIn[1].normal);
	// EmitVertex();

	DataOut.texture_coord = vec2(0, 0);
	gl_Position = m_projView * gl_in[0].gl_Position;
	EmitVertex();

	DataOut.texture_coord = vec2(0, 0);
	gl_Position = m_projView * DataIn[1].control_point;
	EmitVertex();

	DataOut.texture_coord = vec2(0, 0);
	gl_Position = m_projView * gl_in[1].gl_Position;
	EmitVertex();

	// DataOut.texture_coord = vec2(0, 0);
	// gl_Position = m_projView * (gl_in[1].gl_Position + DataIn[1].normal);
	// EmitVertex();

	EndPrimitive();

}

void generateLine () {

	DataOut.texture_coord = vec2(0, 0);
	gl_Position = m_projView * gl_in[0].gl_Position;
	EmitVertex();

	DataOut.texture_coord = vec2(0, 0);
	gl_Position = m_projView * gl_in[1].gl_Position;
	EmitVertex();

	EndPrimitive();

}

void main()
{

	DataOut.blade_id = DataIn[0].blade_id;

	generateBladeSegment();
	//generateBladeLine();
	//generateLine();


}