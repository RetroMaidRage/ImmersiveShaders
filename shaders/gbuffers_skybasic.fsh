#version 120

uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
varying vec4 starData;
varying vec3 SkyPos;
uniform vec3 upPosition;
uniform vec3 cameraPosition;
uniform vec3 sunPosition;
uniform vec4 texcoord;
uniform vec3 moonPosition;
uniform float frameTimeCounter;
uniform vec3 shadowLightPosition;
uniform int worldTime;
//--------------------------------------------DEFINE------------------------------------------
//#define VanillaSky
#define skyColorFinal = skyColor;
#define SKY_COLOR_RED 0.0 ///[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
#define SKY_COLOR_GREEN 0.2 ///[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
#define SKY_COLOR_BLUE 1.0 ///[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
#define SKY_SKATTERING 0.1  ///[ 0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.010  0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]

#define NewSky
#define UseMieScattering
#define MieScatteringType customFogColor //[customSkyColor]
#define MieScatteringIntense 1.5 ///[ 0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.010  0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
//-------------------------------------------------------------------------------------
float timefract = worldTime;
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);
//-------------------------------------------------------------------------------------
float fogify(float x, float w) { 	return w / (x * x + w);
}
//-------------------------------------------------------------------------------------
vec3 CalculateVanillaSky(vec3 SkyPos) {
	float upDot = dot(SkyPos, gbufferModelView[1].xyz); //not much, what's up with you?
	vec3 skycol = vec3(SKY_COLOR_RED, SKY_COLOR_GREEN, SKY_COLOR_BLUE);
	vec3 OtherSkyColor = mix(skyColor.rgb, fogColor, skycol);
	return mix(OtherSkyColor, fogColor, fogify(max(upDot, 0.0), SKY_SKATTERING));
}
//-------------------------------------------------------------------------------------
vec3 mie(float dist, vec3 sunL){
return max(exp(-pow(dist, 0.55)) * sunL - 0.2, 0.0);
}
//-------------------------------------------------------------------------------------

void main() {
	//-------------------------VANILLA----------------------------------
		//-------------------------VANILLA----------------------------------
			//-------------------------VANILLA----------------------------------
	vec3 color;

	if (starData.a > 0.5) {
		color = starData.rgb;
	}
	else {
		vec4 pos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
		pos = gbufferProjectionInverse * pos;
		color = CalculateVanillaSky(normalize(pos.xyz));
	}
		//-------------------------VANILLA----------------------------------
			//-------------------------VANILLA----------------------------------
				//-------------------------VANILLA----------------------------------

//-------------------------COLOR----------------------------------
vec3 nightColor = vec3(0.1, 0.5, 1.0)*0.51;
vec3 nightFogColor = vec3(0.1, 0.5, 1.0)*0.14;

vec3 sunsetFogColor = vec3(0.8, 0.66, 110.5)*1.2;
vec3 sunsetSkyColor = vec3(0.8, 0.66, 0.5)*skyColor;

vec3 customSkyColor = (sunsetSkyColor*TimeSunrise + skyColor*TimeNoon + skyColor*TimeSunset + nightColor*TimeMidnight);
vec3 customFogColor = (fogColor*TimeSunrise + fogColor*TimeNoon + sunsetFogColor*TimeSunset + fogColor*TimeMidnight);

vec3 o = vec3(1.0);
//-------------------------POSITION----------------------------------
	vec3 viewVec = normalize(SkyPos);
	vec3 horizonVec = normalize(upPosition+viewVec);

	vec3 SunVector = normalize(sunPosition+viewVec);
	vec3 SunNormalise = normalize(sunPosition);
	vec3 MoonVector = normalize(moonPosition+viewVec);
	vec3 LightVector = normalize(moonPosition+viewVec);

	float VectorSky = dot(shadowLightPosition, viewVec);


	float horizon = dot(horizonVec, viewVec);
	float mhorizon = dot(-horizonVec, viewVec);

	float Fac = exp(-pow((VectorSky, horizon), 2.0) * 30.0); //5
	Fac += exp(-pow((VectorSky, mhorizon), 2.0) * 5.0); //10

	float sunDistance = distance(viewVec, clamp(SunVector, -1.0, 1.0));

//-------------------------OUT----------------------------------
#ifdef UseMieScattering
vec3 mieScatter = mie(sunDistance, vec3(MieScatteringIntense));
MieScatteringType+=mieScatter;
#endif

/* DRAWBUFFERS:0 */
	#ifdef NewSky
					gl_FragData[0] = vec4(o, 1.0);
					gl_FragData[0].rgb = mix(customSkyColor, customFogColor, Fac);
   #endif

#ifdef VanillaSky
	        gl_FragData[0] = vec4(color, 1.0); //gcolor
	#endif
	}
