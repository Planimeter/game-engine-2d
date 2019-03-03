//=========== Copyright © 2019, Planimeter, All rights reserved. =============//
//
// Purpose:
//
//============================================================================//

vec4 effect( vec4 vcolor, Image tex, vec2 texcoord, vec2 pixcoord )
{
	return vec4( vcolor.rgb, Texel( tex, texcoord ).a );
}
