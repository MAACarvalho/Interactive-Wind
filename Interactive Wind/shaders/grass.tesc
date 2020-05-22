#version 410

layout(vertices = 2) out;

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

} DataOut[];

uniform uint bld_levels = 1; // Vertical divisions of each grass blade

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

void main() {
	
	if (gl_InvocationID == 0) {

		// Frustum Culling

		// Calculating bounding box points
		float width = bld_width  + (noise(DataIn[0].blade_id * rnd_seed * 2982) - 0.5) * bld_width_var;
		vec4 p[6] = vec4[6]( gl_in[0].gl_Position - width * 0.5 * vec4(DataIn[0].tangent, 0),
					  		 gl_in[0].gl_Position + width * 0.5 * vec4(DataIn[0].tangent, 0),
					  		 DataIn[1].control_point - width * 0.5 * vec4(DataIn[0].tangent, 0),
					  		 DataIn[1].control_point + width * 0.5 * vec4(DataIn[0].tangent, 0),
					  		 gl_in[1].gl_Position - width * 0.5 * vec4(DataIn[0].tangent, 0),
					  		 gl_in[1].gl_Position + width * 0.5 * vec4(DataIn[0].tangent, 0));

		bool outside = false;

		for (int i=0; i<6 && !outside; i++) {

			bool inside = false;

			for (int j=0; j<4 && !inside; j++) {

				vec4 pos = m_projView * p[j];

				switch (i) {

					case 0:
						if (pos.x >= -pos.w) inside = true; 
						break;
					case 1:
						if (pos.x <= pos.w)  inside = true;
						break;
					case 2:
						if (pos.y >= -pos.w) inside = true;
						break;
					case 3:
						if (pos.y <= pos.w)  inside = true;
						break;
					case 4:
						if (pos.z >= -pos.w) inside = true;
						break;
					case 5:
						if (pos.z <= pos.w)  inside = true;
						break;
				}

			}

			if (!inside) outside = true;

		}

		// Tessellating blade 
		if (!outside) {

			gl_TessLevelOuter[0] = 1;
			gl_TessLevelOuter[1] = bld_levels;
			
		// Culling blade
		} else {

			gl_TessLevelOuter[0] = 0;
			gl_TessLevelOuter[1] = 0;

		}
	
	}

	DataOut[gl_InvocationID].blade_id = DataIn[gl_InvocationID].blade_id;

	DataOut[gl_InvocationID].up = DataIn[1].up;
	DataOut[gl_InvocationID].tangent = DataIn[1].tangent;

	DataOut[gl_InvocationID].control_point = DataIn[1].control_point;

	gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
}