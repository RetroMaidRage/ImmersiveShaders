#version 120


#include "/files/sky/SkyScatter.glsl"
//--------------------------------------------UNIFORMS-----------------------------------------
uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferProjectionInverse;
varying vec4 starData;
varying vec3 SkyPos;
uniform vec3 upPosition;
uniform vec3 cameraPosition;
uniform vec3 sunPosition;
uniform vec4 texcoord;
uniform vec3 moonPosition;
uniform float frameTimeCounter;
uniform float rainStrength;
uniform vec3 shadowLightPosition;
uniform int worldTime;
uniform mat4 gbufferModelViewInverse;
//--------------------------------------------DEFINE------------------------------------------
#define CustomSun
#define SunDiameter 0.08 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
//#define VanillaSky
#define skyColorFinal = skyColor;
#define NewSky
#define UseMieScattering
#define UseRayleighScattering
#define MieScatteringType customFogColor //[customSkyColor]
#define MieScatteringIntense 1.5 ///[ 0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.010  0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
//-------------------------------------------------------------------------------------
float timefract = worldTime;
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);
//-------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
vec3 L = mat3(gbufferModelViewInverse) * normalize(shadowLightPosition.xyz);

vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * SkyPos;
vec3 feetPlayerPos = eyePlayerPos + gbufferModelViewInverse[3].xyz;

vec3 V = mat3(gbufferModelViewInverse) * SkyPos;
#ifdef CustomSun
vec3 simple_sun(vec3 dir, vec3 sunvec)
{
    float a = acos(dot(dir, sunvec));
    float t = 0.005;
    float e = smoothstep(SunDiameter*1.2 + t, SunDiameter*0.5, a);
  //  float e2 = smoothstep(SunDiameter*2.5 + t, SunDiameter*1.5, a);
  //vec3 two
    return vec3(2,1,1) * e;
}
#endif
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

vec3 sunsetFogColor = vec3(0.8, 0.66, 1.5)*1.2;
vec3 sunsetSkyColor = vec3(0.8, 0.66, 0.5)*skyColor;

vec3 customSkyColor = (sunsetSkyColor*TimeSunrise + skyColor*TimeNoon + sunsetSkyColor*TimeSunset + skyColor*TimeMidnight);
vec3 customFogColor = (sunsetSkyColor*TimeSunrise + fogColor*TimeNoon + sunsetFogColor*TimeSunset + fogColor*TimeMidnight);

vec3 o = vec3(1.0);
vec3 sssun;
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

//	float Fac = exp(-pow((VectorSky, horizon), 2.0) * 30.0); //5
	float Fac = exp(-pow((VectorSky, mhorizon), 2.0) * 12.5); //10 pow(sunDistance, 1.5));

	float sunDistance = distance(viewVec, clamp(SunVector, -1.0, 1.0));
	 sunDistance = distance(viewVec, clamp(SunVector, -1.0, 1.0));
//-------------------------OUT----------------------------------
float cosTheta = dot(viewVec, normalize(sunPosition));

#ifdef UseMieScattering
vec3 mieScatter = mie(sunDistance, vec3(MieScatteringIntense));
MieScatteringType+=mieScatter;
#endif
//-------------------------OUT----------------------------------
#ifdef UseRayleighScattering
float p = Rayleigh(cosTheta);
MieScatteringType += p;
#endif
//-------------------------OUT----------------------------------
MieScatteringType += phaseHG(0.8, cosTheta);
//-------------------------OUT----------------------------------

vec3 nviewvec = normalize(viewVec);

   float density = exp(VectorSky * 3.0) * (1.0 - VectorSky)  * 0.2;
   vec3 transmittance = vec3(1,1,1);
   vec3 col = vec3(0,0,0);

   float dotProduct = -cos(frameTimeCounter * 0.1 -VectorSky * 2.0) * (1.0 - VectorSky)  * 0.35 + 0.35;
   vec3 scatter = vec3(0.25, 0.45, .75) * (1.0 - dotProduct) + vec3(0.3, 0.3, 0.3) * dotProduct; // Net in-scatter.



   for (int i = 0; i < 60; i++)
   {

       col += scatter * density * transmittance;
       transmittance -= transmittance * density * vec3(0.3, 0.55, 1); // Through-scatter: Light scattered into the camera but re-scattered out.
   }


#ifdef CustomSun
 sssun = simple_sun(viewVec,SunVector)*phaseHG(0.8, cosTheta)*p*mieScatter;
#endif
//-------------------------OUT----------------------------------
/* DRAWBUFFERS:0 */
	#ifdef NewSky
					gl_FragData[0] = vec4(o, 1.0);
					gl_FragData[0].rgb = mix(customSkyColor, customFogColor, Fac)+sssun;
   #endif

#ifdef VanillaSky
	        gl_FragData[0] = vec4(color, 1.0); //gcolor
	#endif


	}
