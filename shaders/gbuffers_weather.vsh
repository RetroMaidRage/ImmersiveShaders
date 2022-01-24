#version 120
//--------------------------------------------UNIFORMS------------------------------------------
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
uniform float frameTimeCounter;
//--------------------------------------------DEFINE------------------------------------------
#define waves
#define waves_rain_strenght 5 //[1 2 3 4 5 6 7 8 9 10]

void main() {

	const float pi = 3.14159265f;
	float tick = frameTimeCounter;

		vec4 position = gl_Vertex;
	//	position.y += tick;
	#ifdef waves
			float speed = 0.1;

				position.x += sin((tick * pi / (28.0 * speed)) + (position.x + 0.0) * 0.1 + (position.z + waves_rain_strenght) * 0.1);
						position.z += 1.0;
						#endif
gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * position);
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

}
