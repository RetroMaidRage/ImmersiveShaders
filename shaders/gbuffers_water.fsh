#version 120
#include "/files/filters/noises.glsl"
//--------------------------------------------UNIFORMS------------------------------------------
varying vec4 texcoord;
uniform sampler2D gcolor;
uniform sampler2D depthtex0;

uniform vec3 sunPosition;

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
uniform float viewWidth;
uniform float viewHeight;

uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;
uniform vec3 previousCameraPosition;
uniform vec3 skyColor;
uniform float frameTimeCounter;
uniform int isEyeInWater;

uniform sampler2D lightmap;
uniform sampler2D texture;
uniform sampler2D colortex1;
uniform sampler2D depthtex2;
varying vec2 lmcoord;
in  float entityId;
varying vec4 glcolor;
uniform sampler2D gnormal;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D depthtex1;
uniform mat4 gbufferProjection;
uniform sampler2D composite;
varying vec2 TexCoords;
varying vec3 viewPos;
varying vec3 normal;
//--------------------------------------------DEFINE------------------------------------------
#define WaterType Custom //[Custom Texture]
#define WaterTransparent 2.0  //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5]
#define FrenselTexture Frensel //[FrenselUseTexture]
#define FrensStrenght 0.01   //[[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define SpecularTexture SpecularCustom //[SpecularCustom SpecularUseTexture]
#define specularDistance 50 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 11 12 13 14 15 16 17 18 19 20]
#define specularTextureStrenght 0.7 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 11 12 13 14 15 16 17 18 19 20]
#define SpecularCustomStrenght 1 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 11 12 13 14 15 16 17 18 19 20]
//--------------------------------------------------------------------------------------

void main() {
	int id = int(entityId + 0.5);

	vec4 color = texture2D(texture, texcoord.st);
vec4 Frensel =  vec4(1.7,1.0,1.0,1.0);
vec4 FrenselUseTexture = texture2D(texture, texcoord.st);

vec4 fresnelColor =  FrenselTexture;
vec4 Texture = color;
vec4 Custom = vec4(0.6);

	vec4 cwater = vec4(WaterTransparent)*glcolor*WaterType;
	cwater.r = (cwater.r*1);
	  cwater.g = (cwater.g*1);
	  cwater.b = (cwater.b*0.8);
	cwater = cwater / (cwater + 4.2) * (1.0+2.0);
//--------------------------------------------------------------------------------------
  float fog = length(viewPos);
float frensel =  exp(-fog * FrensStrenght);


vec3 ShadowLightPosition = normalize(shadowLightPosition);
vec3 Normal = normalize(normal);
vec3 lightDir = normalize(ShadowLightPosition);

vec3 viewDir = -normalize(viewPos);
vec3 halfDir = normalize(lightDir + viewDir);
vec3 reflectDir = reflect(lightDir, viewDir);

 float SpecularAngle = pow(max(dot(halfDir, Normal), 0.0), specularDistance);

 if (isEyeInWater == 1) {
 SpecularAngle = 0;
}

if (rainStrength == 1) {
SpecularAngle = 0;
}

vec4 SpecularCustom= vec4(1.0, 1.0, 1.0, 1.0)*SpecularCustomStrenght;
vec4 SpecularUseTexture = texture2D(colortex0, texcoord.st)*specularTextureStrenght;




//--------------------------------------------------------------------------------------


  vec4 output = mix(fresnelColor, cwater, frensel)+(SpecularAngle*SpecularTexture);
/* DRAWBUFFERS:0 */
if (id == 35) {
gl_FragData[0] = output; //gcolor
}else{
gl_FragData[0] = mix(fresnelColor, cwater, frensel); //gcolor
}}
