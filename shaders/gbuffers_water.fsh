#version 120
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
//--------------------------------------------DEFINE------------------------------------------
#define WaterType Custom //[Custom]
#define FrenselTexture Frensel //[FrenselUseTexture]
//--------------------------------------------------------------------------------------
void main() {
	int id = int(entityId + 0.5);

	vec4 color = texture2D(texture, texcoord.st);
vec4 Frensel =  vec4(1.0,1.0,1.0,1.0);
vec4 FrenselUseTexture = texture2D(texture, texcoord.st);

vec4 fresnelColor =  FrenselTexture;
vec4 Texture = color;
vec4 Custom = vec4(0.6);

	vec4 cwater = vec4(2.0)*glcolor*WaterType;
	cwater.r = (cwater.r*1);
	  cwater.g = (cwater.g*1);
	  cwater.b = (cwater.b*0.8);
	cwater = cwater / (cwater + 4.2) * (1.0+2.0);

  float fog = length(viewPos);
float frensel =  exp(-fog * 0.01);


/* DRAWBUFFERS:0 */
if (id == 35) {
gl_FragData[0] = mix(fresnelColor, cwater, frensel); //gcolor
}else{
gl_FragData[0] = mix(fresnelColor, cwater, frensel); //gcolor
}}
