#version 120

uniform sampler2D gcolor;
uniform vec3 sunPosition;
uniform sampler2D gaux1;
uniform float weight;
varying vec2 texcoord;
uniform ivec2 eyeBrightnessSmooth;
uniform ivec2 eyeBrightness;
uniform float frameTimeCounter;
const float eyeBrightnessHalflife = 5.0f;
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
vec3 color = texture2D(gcolor, texcoord).rgb;
#ifdef AutoExpsoure
color.rgb = color.rgb * Auto_ExpsoureY();
color.rgb = color.rgb * Auto_ExpsoureX();
#endif
	gl_FragData[0] = vec4(color.rgb, 1.0);
}
