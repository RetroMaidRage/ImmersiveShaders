#version 120
//--------------------------------------------------------------------------------------------
varying vec4 texcoord;
uniform sampler2D gcolor;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform sampler2D composite;
uniform vec3 sunPosition;
uniform mat4 gbufferProjection;
uniform float worldTime;
uniform float rainStrength;
uniform float aspectRatio;
uniform float near;
uniform float far;
uniform sampler2D gaux1;
uniform vec3 fogColor;
uniform vec3 shadowLightPosition;
uniform float displayWidth;
uniform sampler2D noisetex;
uniform sampler2D colortex0;
varying vec3 sunVector;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;
uniform vec3 previousCameraPosition;
uniform vec3 skyColor;
uniform vec3 SkyPos;
uniform float frameTimeCounter;
uniform float wetness;
uniform int isEyeInWater;
uniform mat4 gbufferModelView;
uniform sampler2D lightmap;
uniform sampler2D texture;
uniform float viewWidth;
uniform float viewHeight;
varying vec2 lmcoord;
//--------------------------------------------------------------------------------------------
#define rainPower 0.2 //[0 1 2 3 4 5]
#define VanillaRain
//--------------------------------------------------------------------------------------------
float Raining = clamp(wetness, 0.0, 1.0);
//--------------------------------------------------------------------------------------------
void main() {
	vec2 uv = gl_FragCoord.xy / vec2(viewWidth, viewHeight);

vec4 color = texture2D(texture, texcoord.st)*wetness*rainPower;
color *= texture2D(lightmap, lmcoord);

color.r = 1.0;
color.g = 1.0;
color.b = 1.0;
//--------------------------------------------------------------------------------------------

/* DRAWBUFFERS:0 */
#ifdef VanillaRain
	gl_FragData[0] = color; //gcolor
	#endif
}

//СДЕЛАТЬ НВОЫЙ ДОЖДЬ
