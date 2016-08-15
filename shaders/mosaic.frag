//=========== Copyright © 2016, Planimeter, All rights reserved. =============//
//
// Purpose: Mosaic pixel shader
//
//===========================================================================//

extern vec2 cellSize;

vec2 mosaic( vec2 coords, vec2 size ) {
	coords.x = floor( coords.x * size.x ) / size.x;
	coords.y = floor( coords.y * size.y ) / size.y;
	return coords;
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	texture_coords = mosaic( texture_coords, cellSize );
	vec4 texcolor = Texel( texture, texture_coords );
	return texcolor * color;
}
