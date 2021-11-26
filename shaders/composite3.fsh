#version 120

uniform sampler2D gcolor;
uniform vec3 sunPosition;
uniform sampler2D gaux1;
uniform float weight;
varying vec2 texcoord;
uniform ivec2 eyeBrightnessSmooth;
uniform ivec2 eyeBrightness;
uniform float frameTimeCounter;
const float eyeBrightnessHalflife = 10.0f;
#define AutoExpsoure

float TimeMidnight = ((clamp(frameTimeCounter, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(frameTimeCounter, 23000.0, 24000.0) - 23000.0) / 1000.0);

float eyeAdaptY = eyeBrightnessSmooth.y / 240.0;
float eyeAdaptX = eyeBrightnessSmooth.x / 170.0;

float Auto_ExpsoureY() {

	const float exposureAmount = 2.5;

	float aE_lightmap	= 1.0 - eyeAdaptY;
				aE_lightmap = mix(aE_lightmap, 1.0, pow(TimeMidnight, 2.5));

	return 1.0 + aE_lightmap * exposureAmount;

}

float Auto_ExpsoureX() {

	const float exposureAmount = 2.5;

	float aE_lightmap	= 1.0 - eyeAdaptX;
				aE_lightmap = mix(aE_lightmap, 1.0, pow(TimeMidnight, 2.5));

	return 1.0 + aE_lightmap * exposureAmount;

}
void main() {
vec3 color = texture2D(gcolor, texcoord).rgb;
#ifdef AutoExpsoure
color.rgb = color.rgb * Auto_ExpsoureY();
color.rgb = color.rgb * Auto_ExpsoureX();
#endif
	gl_FragData[0] = vec4(color.rgb, 1.0);
}
