#version 410

layout(vertices = 4) out;

in Data {

	int blade_id;

} DataIn[];

out Data {

	int blade_id;

} DataOut[];

uniform uint bld_levels = 1;

uniform mat4 m_projView;

void main() {
	
	if (gl_InvocationID == 0) {

		// Frustum Culling

		bool outside = false;

		for (int i=0; i<6 && !outside; i++) {

			bool inside = false;

			for (int j=0; j<4 && !inside; j++) {

				vec4 pos = m_projView * gl_in[j].gl_Position;

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
			gl_TessLevelOuter[1] = 1;
			gl_TessLevelOuter[2] = 1;
			gl_TessLevelOuter[3] = 1;
			gl_TessLevelInner[0] = 1;
			gl_TessLevelInner[1] = float(bld_levels);
			
		// Culling blade
		} else {

			gl_TessLevelOuter[0] = 0;
			gl_TessLevelOuter[1] = 0;
			gl_TessLevelOuter[2] = 0;
			gl_TessLevelOuter[3] = 0;
		
			gl_TessLevelInner[0] = 0;
			gl_TessLevelInner[1] = 0;

		}
	
	}

	DataOut[gl_InvocationID].blade_id = DataIn[gl_InvocationID].blade_id;

	gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
}