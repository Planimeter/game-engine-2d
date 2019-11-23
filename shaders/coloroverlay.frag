//=========== Copyright © 2019, Planimeter, All rights reserved. =============//
//
// Purpose:
//
//============================================================================//

vec4 effect( vec4 color, Image tex, vec2 texcoord, vec2 pixcoord )
{
	return vec4( color.rgb, Texel( tex, texcoord ).a );
}
