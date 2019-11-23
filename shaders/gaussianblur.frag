//=========== Copyright © 2019, Planimeter, All rights reserved. =============//
//
// Purpose: Gaussian blur fragment reference shader
// https://developer.nvidia.com/gpugems/GPUGems3/gpugems3_ch40.html
//
//============================================================================//

uniform float sigma;   // Gaussian sigma
uniform vec2  dir;     // horiz=(1.0, 0.0), vert=(0.0, 1.0)
uniform int   support; // int(sigma * 3.0) truncation
vec4 effect( vec4 color, Image tex, vec2 texcoord, vec2 pixcoord )
{
	vec2 loc   = texcoord;     // center pixel cooordinate
	vec4 acc   = vec4( 0.0f ); // accumulator
	float norm = 0.0f;
	for (int i = -support; i <= support; i++) {
		float coeff = exp(-0.5 * float(i) * float(i) / (sigma * sigma));
		acc += (Texel(tex, loc + float(i) * dir)) * coeff;
		norm += coeff;
	}
	acc *= 1/norm;             // normalize for unity gain
	return acc;
}
