#version 120

uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform vec3 sunPosition;
varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.
//--------------------------------------------DEFINE------------------------------------------
#define skyColorFinal = skyColor;
#define SKY_COLOR_RED 0.0 ///[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
#define SKY_COLOR_GREEN 0.2 ///[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
#define SKY_COLOR_BLUE 1.0 ///[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
#define SKY_SKATTERING 0.1  ///[ 0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.010  0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]

float fogify(float x, float w) { 	return w / (x * x + w);
}

vec3  interpolateSmooth3(vec3  v) { return v * v * (3.0 - 2.0 * v); }


vec3 calcSkyColor(vec3 pos) {

	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	vec3 skycol = vec3(0.0f, 0.0f, 0.0f);


	skycol.r = SKY_COLOR_RED;
	skycol.g = SKY_COLOR_GREEN;
	skycol.b = SKY_COLOR_BLUE;
	vec3 OtherSkyColor = mix(skyColor.rgb, fogColor, skycol);
	return interpolateSmooth3(mix(OtherSkyColor, fogColor, fogify(max(upDot, 0.0), SKY_SKATTERING)));
}



void main() {



		vec4 pos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
		pos = gbufferProjectionInverse * pos;
vec4 posNorm = normalize(pos);
float upDot = dot(vec3(pos), gbufferModelView[1].xyz); //not much, what's up with you?
		vec2 uv = vec2(gl_FragCoord.xy / vec2(viewWidth, viewHeight));
vec3 normalSunPos = normalize(sunPosition);
	vec3 sky_horizonColor = mix(vec3(0.8,0.4,0.1),vec3(0.6,0.6,1.0),pow(normalSunPos.y,0.3));
vec3 sky_Color = mix(vec3(0.1,0.1,0.3),vec3(0.2,0.2,0.7),pow(normalSunPos.y,0.3));
vec3 skyGradient = mix(sky_horizonColor,sky_Color,pow(uv.y,0.5));
vec3 SkyCol = mix(skyGradient, skyColor, fogColor);
vec3 arar =(mix(skyGradient, fogColor, fogify(max(upDot, 0.0), SKY_SKATTERING)));
/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(skyGradient, 1.0); //gcolor
}
