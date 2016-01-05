//========= Copyright © 2013-2016, Planimeter, All rights reserved. ==========//
//
// Purpose: Alpha Mask pixel shader
//
//===========================================================================//

extern Image mask;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec4 texColor = Texel( texture, texture_coords );
	if ( texColor.a == 0 ) {
		discard;
	}

	vec4 blendColor = texColor;
	blendColor.rgb  = color.rgb * texColor.rgb;
	blendColor.a    = color.a   * texColor.a * Texel( mask, texture_coords ).a;
	return blendColor;
}
