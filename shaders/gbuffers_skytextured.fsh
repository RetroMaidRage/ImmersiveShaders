#version 120

#include "/files/sky/SkyScatter.glsl"
//--------------------------------------------UNIFORMS------------------------------------------
uniform sampler2D texture;
varying vec2 texcoord;
varying vec4 glcolor;
uniform sampler2D gcolor;
uniform sampler2D gaux1;
uniform sampler2D colortex0;
varying vec3 SkyPos;
uniform vec3 sunPosition;
//--------------------------------------------DEFINE------------------------------------------
#define sunColorRed 11.1 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define sunColorGreen 7.4
#define sunColorBlue 11.1
#define SunDiskSize 1
#define SunDisk Vanilla //[Vanilla Custom]
/* rou
const int colortex0Format = RGBA16F;
const int colortex1Format = RGB16;
const int colortex2Format = RGB16;
*/




void main() {
		vec3 viewVec = normalize(SkyPos);
vec3 SunVector = normalize(sunPosition+viewVec);

	vec4 Vanilla = texture2D(texture, texcoord) * glcolor;
	vec4 Custom = vec4(0.0);
	vec4 suncolor = SunDisk;

	suncolor.r = (suncolor.r*sunColorRed);
	  suncolor.g = (suncolor.g*sunColorGreen);
	  suncolor.b = (suncolor.b*sunColorBlue);
	suncolor = suncolor / (suncolor + 4.2) * (1.0+2.0);

	float dist = distance(texcoord.st, vec2(0.5)) * 2.0;
	dist /= 1;




	float sunDistance = distance(viewVec, clamp(SunVector, -1.0, 1.0));
vec3 mieScatter = mie(sunDistance, vec3(1.5));
		    suncolor.rgb *= (2.0f - dist) *mieScatter;
/* DRAWBUFFERS:0 */
	gl_FragData[0] = suncolor; //gcolor
}
