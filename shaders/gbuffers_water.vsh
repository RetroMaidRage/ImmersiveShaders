#version 120

//--------------------------------------------UNIFORMS------------------------------------------
attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;
varying vec3 vworldpos;
uniform float frameTimeCounter;
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glColor;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;
varying vec4 glcolor;
//--------------------------------------------DEFINE------------------------------------------
#define waves
#define waves_strenght 5 //[1 2 3 4 5 6 7 8 9 10]
#define waving_leaves_speed 0.1 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
#define waving_grass_speed 0.07 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
const float pi = 3.14f;

float tick = frameTimeCounter;

void main() {
		glcolor = gl_Color;
texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	vec4 position = gl_ModelViewMatrix * gl_Vertex;
  vec4 vpos = gbufferModelViewInverse*position;
  vworldpos = vpos.xyz + cameraPosition;


  #ifdef waves
	if (mc_Entity.x == 35.0) {


			 float fy = fract(vworldpos.y + 0.001);

				 if (fy > 0.002) {
	float displacement = 0.0;
				 float wave = 0.05 * sin(2 * pi * (tick*0.75 + vworldpos.x /  7.0 + vworldpos.z / 13.0))
											+ 0.05 * sin(1 * pi * (tick*0.6 + vworldpos.x / 11.0 + vworldpos.z /  5.0));
											displacement = clamp(wave, -fy, 1.0-fy);
											vpos.y += displacement;
	}}
#endif
vpos = gbufferModelView * vpos;
gl_Position = gl_ProjectionMatrix * vpos;
    TexCoords = gl_MultiTexCoord0.st;
    LightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
    LightmapCoords = (LightmapCoords * 33.05f / 32.0f) - (1.05f / 32.0f);
    Normal = gl_NormalMatrix * gl_Normal;
    Color = gl_Color;
}
