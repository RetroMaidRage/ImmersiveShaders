#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

#define rainPower 1 //[0 1 2 3 4 5]
#define VanillaRain
void main() {
	vec4 color = texture2D(texture, texcoord)*rainPower;
	color *= texture2D(lightmap, lmcoord);
color.r = 12.0;
color.g = 12.0;
color.b = 12.0;
/* DRAWBUFFERS:0 */
#ifdef VanillaRain
	gl_FragData[0] = color; //gcolor
	#endif
}
