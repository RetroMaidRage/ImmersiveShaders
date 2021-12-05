#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;
uniform sampler2D depthtex2;
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
uniform sampler2D gnormal;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D depthtex1;
uniform mat4 gbufferProjection;
uniform sampler2D composite;
#define WaterType Texture //[Custom]


void main() {
	vec4 color = texture2D(texture, texcoord);
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
