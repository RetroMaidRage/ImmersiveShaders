#version 120

uniform sampler2D texture;
varying vec2 texcoord;
varying vec4 glcolor;

#define sunColorRed 2.6 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define sunColorGreen 1.4
#define sunColorBlue 11.1
void main() {
	vec4 suncolor = texture2D(texture, texcoord) * glcolor;
	suncolor.r = (suncolor.r*sunColorRed);
	  suncolor.g = (suncolor.g*sunColorGreen);
	  suncolor.b = (suncolor.b*sunColorBlue);
	suncolor = suncolor / (suncolor + 4.2) * (1.0+2.0);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = suncolor; //gcolor
}
