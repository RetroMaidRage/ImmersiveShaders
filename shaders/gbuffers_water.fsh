#version 120
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
uniform sampler2D depthtex2;
varying vec2 lmcoord;

varying vec4 glcolor;
uniform sampler2D gnormal;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D depthtex1;
uniform mat4 gbufferProjection;
uniform sampler2D composite;
#define WaterType Texture //[Custom]


void main() {
	vec4 color = texture2D(texture, texcoord.st);
//	color *= texture2D(lightmap, lmcoord);
//	vec4 Vanilla = texture2D(texture, texcoord) * glcolor;
vec4 Texture = color;
vec4 Custom = vec4(1.0);

	vec4 cwater = vec4(2.0)*glcolor*WaterType;
//	vec3 fragpos = vec3(texcoord.st, texture2D(depthtex2, texcoord.st).r);
//	fragpos = nvec3(gbufferProjectionInverse * nvec4(fragpos * 2.0 - 1.0));


	cwater.r = (cwater.r*1);
	  cwater.g = (cwater.g*1);
	  cwater.b = (cwater.b*0.8);
	cwater = cwater / (cwater + 4.2) * (1.0+2.0);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = cwater; //gcolor
}
