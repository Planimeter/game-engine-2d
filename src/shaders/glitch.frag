//========= Copyright © 2013-2015, Planimeter, All rights reserved. ==========//
//
// Purpose: Glitch pixel shader
//
//===========================================================================//

extern vec2 cellSize;
extern vec2 offset;

vec2 mosaic( vec2 coords, vec2 size ) {
	coords.x = floor( coords.x * size.x ) / size.x;
	coords.y = floor( coords.y * size.y ) / size.y;
	return coords;
}

float luminance( vec3 color ) {
	return dot( color, vec3( 0.299, 0.587, 0.114 ) );
}

vec2 glitch( vec3 color, vec2 coords, vec2 offset ) {
	float glitch = luminance( color );
	coords = coords + vec2( glitch * offset.x, glitch * offset.y );
	return coords;
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
{
	vec2 pixelatedCoords = mosaic( texture_coords, cellSize );
	vec3 pixelatedColor  = Texel( texture, pixelatedCoords ).rgb;
	texture_coords       = glitch( pixelatedColor, texture_coords, offset );
	vec4 texcolor        = Texel( texture, texture_coords );
	return texcolor * color;
}
