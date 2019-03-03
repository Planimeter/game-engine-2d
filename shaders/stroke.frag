//=========== Copyright © 2018, Planimeter, All rights reserved. =============//
//
// Purpose:
//
//============================================================================//

uniform vec2  resolution;
uniform float width;

const   int   samples = 20;
const   float pi      = 3.1415926535898f;

vec4 effect( vec4 vcolor, Image tex, vec2 texcoord, vec2 pixcoord )
{
	// Stroke
	float alpha = 0.0f;
	float angle = 0.0f;
	for( int i = 0; i < samples; i++ )
	{
		angle += 1.0f / ( float( samples ) / 2.0f ) * pi;

		float x = ( width / resolution.x ) * cos( angle );
		float y = ( width / resolution.y ) * sin( angle );
		vec2 offset = vec2( x, y );

		float sampleAlpha = Texel( tex, texcoord + offset ).a;
		alpha = max( alpha, sampleAlpha );
	}

	// Texture
	vec4 FragColor = vcolor * alpha;
	vec4 texel     = Texel( tex, texcoord );
	FragColor      = mix( FragColor, texel, texel.a );
	return FragColor;
}
