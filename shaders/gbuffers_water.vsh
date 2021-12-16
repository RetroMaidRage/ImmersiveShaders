#version 120

//--------------------------------------------UNIFORMS------------------------------------------
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
attribute vec3 mc_Entity;
out float entityId;
varying vec3 viewPos;
varying vec3 worldPos;
varying vec3 normal;
//--------------------------------------------DEFINE------------------------------------------
#define waves
#define waves_strenght 5 //[1 2 3 4 5 6 7 8 9 10]
const float pi = 3.14f;

float tick = frameTimeCounter;

void main() {

	vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
	vec3 feetPlayerPos = eyePlayerPos + gbufferModelViewInverse[3].xyz;
	worldPos = eyePlayerPos + cameraPosition;
		viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	entityId = mc_Entity.x;
	int blockId = int(entityId);
		glcolor = gl_Color;
texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	vec4 position = gl_ModelViewMatrix * gl_Vertex;
  vec4 vpos = gbufferModelViewInverse*position;
  vworldpos = vpos.xyz + cameraPosition;
	normal = gl_NormalMatrix * gl_Normal;

  #ifdef waves
	if (mc_Entity.x == 10001.0) {


			 float fy = fract(vworldpos.y + 0.001);

				 if (fy > 0.002) {
	float displacement = 0.0;
				 float wave = 0.085 * sin(2 * pi * (tick*0.75 + vworldpos.x /  7.0 + vworldpos.z / 13.0))
											+ 0.085 * sin(1 * pi * (tick*0.6 + vworldpos.x / 11.0 + vworldpos.z /  5.0));
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
