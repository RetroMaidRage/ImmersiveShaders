#version 120

//--------------------------------------------INCLUDE------------------------------------------

#include "distort.glsl"




//--------------------------------------------UNIFORMS------------------------------------------
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform sampler2D depthtex;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
varying vec2 texcoord;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform float fogDensity;
uniform vec3 fogColor;
uniform vec3 sunPosition;
uniform vec3 moonPosition;
varying vec2 TexCoords;
uniform float worldTime;
uniform vec3 shadowLightPosition;
uniform vec3 skyColor;
uniform vec3 cameraPosition;
uniform float near;
uniform float far;
uniform float frameTimeCounter;
varying vec4 heldLightColor;
//--------------------------------------------CONST------------------------------------------


const float sunPathRotation = -40.0f;
const int shadowMapResolution = 2048;
const int noiseTextureResolution = 256;
const float shadowDistance = 80.0f;
const float ambientOcclusionLevel = 0.0f;

//--------------------------------------------DEFINE------------------------------------------
#define shadowResolution 2048 //[512 1024 1536 2048 3072 4096 8192]
#define SHADOW_SAMPLES 2 //[1 2 3 4]
#define ColShadowBoost 7 //[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 223 24 25 26 27 28 29 30]
#define OUTPUT Diffuse //[Normal Albedo NewDiffuse]
#define LIGHT_STRENGHT 6 //[1 2 3 4 5 6 7 8 9 10]
//#define grass_fix
#define Ambient 0.11 ///[0.1 0.11 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define SkyColorType DynamicSkyColor //[DynamicSkyColor StaticSkyColor]
#define ShadowRenderDistance 160.0
#define VanillaAmbientOcclusion
//#define Dynamic_Flicker
float timefract = worldTime;
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);

float tick = frameTimeCounter;

float AdjustLightmapTorch(in float torch) {

  float tick2 = sin(tick*1);

  float tick3 = fract(tick2);



       float K =LIGHT_STRENGHT;
       float P = 5.06f;
#ifdef Dynamic_Flicker
    return K * tick3* pow(torch, P);
    #endif
        return K * pow(torch, P);
}




float AdjustLightmapSky(in float sky){
    float sky_2 = sky * sky;
    return sky * sky_2;
}



vec2 AdjustLightmap(in vec2 Lightmap){
    vec2 NewLightMap;
    NewLightMap.x = AdjustLightmapTorch(Lightmap.x);
    NewLightMap.y = AdjustLightmapSky(Lightmap.y);
    return NewLightMap;
}

vec3 GetLightmapColor(in vec2 Lightmap){
    Lightmap = AdjustLightmap(Lightmap);
    const vec3 TorchColor = vec3(0.5f, 0.25f, 0.08f);


//custom_skyLighting--------------------------------------------------------------------------------------------------------------------------------------
    vec3 sunsetSkyColor = vec3(0.05f, 0.15f, 0.3f);
  	vec3 daySkyColor = vec3(0.3, 0.5, 1.1)*0.2;
  	vec3 nightSkyColor = vec3(0.001,0.0015,0.0025);
    vec3 DynamicSkyColor = (sunsetSkyColor*TimeSunrise + daySkyColor*TimeNoon + sunsetSkyColor*TimeSunset + nightSkyColor*TimeMidnight);
//custom_skyLighting--------------------------------------------------------------------------------------------------------------------------------------
  const vec3 StaticSkyColor = vec3(0.05f, 0.15f, 0.3f);
//vec3 CustomSkyColor = vec3;


    vec3 TorchLighting = Lightmap.x * TorchColor;
    vec3 SkyLighting = Lightmap.y * SkyColorType;
    vec3 LightmapLighting = TorchLighting + SkyLighting;
    return LightmapLighting;
}

float Visibility(in sampler2D ShadowMap, in vec3 SampleCoords) {
    return step(SampleCoords.z - 0.001f, texture2D(ShadowMap, SampleCoords.xy).r);
}

vec3 TransparentShadow(in vec3 SampleCoords){
    float ShadowVisibility0 = Visibility(shadowtex0, SampleCoords);
    float ShadowVisibility1 = Visibility(shadowtex1, SampleCoords);


float ShadowVisibility3 = ShadowVisibility1 * ColShadowBoost;
    vec4 ShadowColor0 = texture2D(shadowcolor0, SampleCoords.xy);
    vec3 TransmittedColor = ShadowColor0.rgb * (1.0 - ShadowColor0.a);
    return mix(ShadowVisibility3 * TransmittedColor, vec3(1.0), ShadowVisibility0);
}


const int ShadowSamplesPerSize = 2 * SHADOW_SAMPLES + 1;
const int TotalSamples = ShadowSamplesPerSize * ShadowSamplesPerSize;

vec3 GetShadow(float depth) {
    vec3 ClipSpace = vec3(TexCoords, depth) * 2.0f - 1.0f;
    vec4 ViewW = gbufferProjectionInverse * vec4(ClipSpace, 1.0f);
    vec3 View = ViewW.xyz / ViewW.w;
    vec4 World = gbufferModelViewInverse * vec4(View, 1.0f);
    vec4 ShadowSpace = shadowProjection * shadowModelView * World;
    ShadowSpace.xy = DistortPosition(ShadowSpace.xy);
    vec3 SampleCoords = ShadowSpace.xyz * 0.5f + 0.5f;
    float RandomAngle = texture2D(noisetex, TexCoords * 20.0f).r * 100.0f;
    float cosTheta = cos(RandomAngle);
	float sinTheta = sin(RandomAngle);
    mat2 Rotation =  mat2(cosTheta, -sinTheta, sinTheta, cosTheta) / shadowResolution;
    vec3 ShadowAccum = vec3(0.0f);
    for(int x = -SHADOW_SAMPLES; x <= SHADOW_SAMPLES; x++){
        for(int y = -SHADOW_SAMPLES; y <= SHADOW_SAMPLES; y++){
            vec2 Offset = Rotation * vec2(x, y);
            vec3 CurrentSampleCoordinate = vec3(SampleCoords.xy + Offset, SampleCoords.z);
            ShadowAccum += TransparentShadow(CurrentSampleCoordinate);
        }
    }
    ShadowAccum /= TotalSamples;
    return ShadowAccum;
}

//getlocate

vec3 screenPos = vec3(texcoord, texture2D(depthtex, texcoord).r);
vec3 clipPos = screenPos * 2.0 - 1.0;
vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
vec3 viewPos = tmp.xyz / tmp.w;
vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
vec3 worldPos = feetPlayerPos + cameraPosition;
void main(){

    vec3 Albedo = pow(texture2D(colortex0, TexCoords).rgb, vec3(2.2f));
    float Depth = texture2D(depthtex0, TexCoords).r;
    if(Depth == 1.0f){
        gl_FragData[0] = vec4(Albedo, 1.0f);
        return;
    }

    vec3 Normal = normalize(texture2D(colortex1, TexCoords).rgb * 2.0f - 1.0f);
    vec2 Lightmap = texture2D(colortex2, TexCoords).rg;
    vec3 LightmapColor = GetLightmapColor(Lightmap);
    float NdotL = max(dot(Normal, normalize(shadowLightPosition)), 0.0f);


#ifdef grass_fix
vec3 lightreflect = reflect(-shadowLightPosition, Normal);
//vec3 eyeVectorWorld= normalize(genType v)
float s = dot(lightreflect, eyePlayerPos);
s = pow(s, 4);
vec3 specularLighting = vec3(s, 0, 0);
//vec3 grass_fixing = vec3(s, s, s);
//grass_fixing.r = 0.1;
#endif
    vec3 Diffuse = Albedo * (LightmapColor + NdotL * GetShadow(Depth) + Ambient);



vec3 NewDiffuse = mix(Diffuse, fogColor, fogDensity);

#ifdef VanillaAmbientOcclusion
const float ambientOcclusionLevel = 1.0f;
#endif
    gl_FragData[0] = vec4(OUTPUT, 1.0f);
}
