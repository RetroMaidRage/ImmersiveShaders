#version 120
/*
const int colortex0Format = RGBA16F;
const int colortex1Format = RGB16;
const int colortex2Format = RGB16;
*/
//--------------------------------------------UNIFORMS------------------------------------------
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
uniform int isEyeInWater;
uniform mat4 gbufferModelView;
varying vec2 TexCoords;
//------------------------
uniform float weight;

uniform ivec2 eyeBrightnessSmooth;
uniform ivec2 eyeBrightness;

const float eyeBrightnessHalflife = 5.0f;
//--------------------------------------------DEFINE------------------------------------------
#define AutoExpsoure
#define exposureAmountSky 2.5
#define exposureAmountBlock 0.25

float eyeAdaptY = eyeBrightnessSmooth.y / 240.0; //sky
float eyeAdaptX = eyeBrightnessSmooth.x / 180.0; //block

float Auto_ExpsoureY() { //sky
	float aE_lightmap	= 1.0 - eyeAdaptY;
	return 1.0 + aE_lightmap * exposureAmountSky;

}

float Auto_ExpsoureX() { //block
	float aE_lightmap	= 1.0 - eyeAdaptX;
	return 1.0 + aE_lightmap * exposureAmountBlock;

}
void main() {
	vec3 screenPos = vec3(texcoord.st, texture2D(depthtex0, texcoord.st).r);
	vec3 clipPos = screenPos * 2.0 - 1.0;
	vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
	vec3 viewPos = tmp.xyz / tmp.w;
	vec4 world_position = gbufferModelViewInverse * vec4(viewPos, 1.0);

float distancefog = length(world_position.xyz);


vec3 color = texture2D(gcolor, texcoord.st).rgb;


#ifdef AutoExpsoure
color.rgb = color.rgb * Auto_ExpsoureY();
color.rgb = color.rgb * Auto_ExpsoureX();

#endif
    /* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color.rgb, 1.0);
}
