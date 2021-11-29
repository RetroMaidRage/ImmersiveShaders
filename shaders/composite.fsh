#version 120

//--------------------------------------------INCLUDE------------------------------------------

#include "/files/filters/distort.glsl"
#include "/files/filters/distort2.glsl"
#include "/files/filters/dither.glsl"
#include "/files/filters/noises.glsl"
#include "/files/tonemaps/tonemap_uncharted.glsl"

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
uniform mat4 gbufferProjection;
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
uniform sampler2D depthtex1;
uniform float heightScale;
uniform float rainStrength;
uniform sampler2D gdepth;
uniform sampler2D gaux1;
uniform sampler2D gcolor;
flat in int water;
varying vec4 vertexpos;
//--------------------------------------------CONST------------------------------------------


const float sunPathRotation = -40.0f;
const int shadowMapResolution = 2048;
const int noiseTextureResolution = 256;
const float shadowDistance = 80.0f;
const float ambientOcclusionLevel = 0.0f;

//--------------------------------------------DEFINE------------------------------------------
#define shadowResolution 2048 //[512 1024 1536 2048 3072 4096 8192]
#define SHADOW_SAMPLES 2 //[1 2 3 4 5 6]
#define ColShadowBoost 7 //[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 223 24 25 26 27 28 29 30]
#define LIGHT_STRENGHT 6 //[1 2 3 4 5 6 7 8 9 10]
#define Ambient 0.11 ///[0.1 0.11 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define GrassShadow ShadowOn //[ShadowOn ShadowOff]
#define ColorSettings Default //[Summertime Default]
#define SkyColorType DynamicSkyColor //[DynamicSkyColor StaticSkyColor]
#define TerrainColorType DynamicTime //[DynamicTime StaticTime]

#define VanillaAmbientOcclusion
#define specularLight

#define VL_STEPS 12

#define OUTPUT Diffuse //[Normal Albedo specular DiffuseAndSpecular]
#define GammaType OldGamma //[OldGamma NewGamma]
//#define TonemappingType Uncharted2TonemapOpComposite //[Uncharted2TonemapOp Aces reinhard2 lottes]

float timefract = worldTime;
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);


    vec3 sunsetSkyColor = vec3(0.07f, 0.15f, 0.3f);
  	vec3 daySkyColor = vec3(0.3, 0.5, 1.1)*0.2;
  	vec3 nightSkyColor = vec3(0.001,0.0015,0.0025);
    vec3 DynamicSkyColor = (sunsetSkyColor*TimeSunrise + skyColor*TimeNoon + sunsetSkyColor*TimeSunset + nightSkyColor*TimeMidnight);



float AdjustLightmapTorch(in float torch) {


       float K =LIGHT_STRENGHT;
       float P = 10.06f;
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
    const vec3 TorchColor = vec3(1.0f, 0.25f, 0.08f);

  const vec3 StaticSkyColor = vec3(0.05f, 0.15f, 0.3f);

    vec3 TorchLighting = Lightmap.x * TorchColor;
    vec3 SkyLighting = Lightmap.y * SkyColorType;
    vec3 LightmapLighting = TorchLighting + SkyLighting;
    return LightmapLighting;
}

float Visibility(in sampler2D ShadowMap, in vec3 SampleCoords) {
    return step(SampleCoords.z - 0.001f, texture2D(ShadowMap, SampleCoords.xy).r);
}

//Calculates shadow coordinates
vec3 calculate_shadow_coord(vec4 world_position)
{
    vec4 shadow_projection = shadowProjection * shadowModelView * world_position;  //Convert world position into position in shadow projection space
    shadow_projection.xyz = distort(shadow_projection.xyz); //Apply distortion

    vec3 shadow_coords = shadow_projection.xyz * 0.5 + 0.5; //Convert it into screen space
    return shadow_coords;
}

float calculate_shadow(vec3 shadow_coords)
{
   return step(shadow_coords.z -  0.001f, texture2D(shadowtex0, shadow_coords.xy).x);
}

//Calculates shadow coordinates


vec3 TransparentShadow(in vec3 SampleCoords){

  vec3 NfogColor = fogColor*1.5;

vec3 Summertime =  NfogColor;
Summertime.r = NfogColor.r*2;

vec3 Default = fogColor*1.5;
Default.r +=0.5;


    float ShadowVisibility0 = Visibility(shadowtex0, SampleCoords);
    float ShadowVisibility1 = Visibility(shadowtex1, SampleCoords);


float ShadowVisibility3 = ShadowVisibility1 * ColShadowBoost;
    vec4 ShadowColor0 = texture2D(shadowcolor0, SampleCoords.xy);
    vec3 TransmittedColor = ShadowColor0.rgb * (1.0 - ShadowColor0.a);

    return mix(ShadowVisibility3 * TransmittedColor, vec3(1.0)*ColorSettings, ShadowVisibility0);
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

vec3 viewToShadow(vec3 viewPos) {
    vec4 shadowPos = gbufferModelViewInverse * vec4(viewPos, 1.0); // Convert the view space position to a player space position
         shadowPos = shadowModelView  * shadowPos; // Multiply by the shadow view matrix
         shadowPos = shadowProjection * shadowPos; // Multiply by the shadow projection matrix

        // /!\ Always place the matrix before the vector in a matrix multiplication

    return vec3(DistortPosition(shadowPos.xy), shadowPos.z); // Distort the XY coordinates (not the Z!!) using the function you probably already have
}

//float calculate_shadow(sampler2D shadowtex0, vec3 viewPos) {
  //vec4 shadowPos = gbufferModelViewInverse * vec4(viewPos, 1.0); // Convert the view space position to a player space position
    //   shadowPos = shadowModelView  * shadowPos; // Multiply by the shadow view matrix
    //   shadowPos = shadowProjection * shadowPos; // Multiply by the shadow projection matrix
  //  float sampleShadow = texture2D(shadowtex0, shadowPos.xy).r;
  //  return sampleShadow;
//}


////////////////////////////////////////////////////////////////////////////////////////


//feet position at input viewPos
//float volumetric_light(vec3 viewPos)
//{
//    int SAMPLES = 128;
//    float accum_density = 10.0;

  //  vec4 start_position = shadowProjection * shadowModelView * gbufferModelViewInverse * vec4(0.0, 0.0, 0.0, 1.0);
  //  vec4 end_position = shadowProjection * shadowModelView * gbufferModelViewInverse * vec4(viewPos, 1.0);

  //  float ray_length = length(end_position.xyz - start_position.xyz) / float(SAMPLES);
  //  vec3 ray_increment = normalize(end_position.xyz - start_position.xyz) * ray_length;
  //  vec3 ray_position = start_position.xyz;


  //  for(int i = 0; i < SAMPLES; ++i)
  //  {

  //      vec3 shadow_position = distort(ray_position.xyz) * 0.5 + 0.5;

    //    accum_density += calculate_shadow(shadowtex0, shadow_position);

    //    ray_position += ray_increment;
  //  }

  //  accum_density /= float(SAMPLES);
  //  return accum_density*0.1;
//}
////////////////////////////////////////////////////////////////////////////////////////
void main(){

float NewGamma = 1.0f;
float OldGamma = 2.2f;

    vec3 Albedo = pow(texture2D(colortex0, TexCoords).rgb, vec3(GammaType));


    float Depth = texture2D(depthtex0, TexCoords).r;
    if(Depth == 1.0f){
        gl_FragData[0] = vec4(Albedo, 1.0f);
        return;
    }

    vec3 Normal = normalize(texture2D(colortex1, TexCoords).rgb * 2.0f - 1.0f);
    vec2 Lightmap = texture2D(colortex2, TexCoords).rg;
  //  Normal = normalize(Normal * 211.0 - 1.0);
    vec3 LightmapColor = GetLightmapColor(Lightmap);
    float NdotL = max(dot(Normal, normalize(shadowLightPosition)), 0.0f);

////////////////////////////////////////////////////////////////////////////////////
#ifdef specularLight

vec3 ClipSpacee = vec3(TexCoords, Depth) * 2.0f - 1.0f;
vec4 ViewWw = gbufferProjectionInverse * vec4(ClipSpacee, 1.0f);
vec3 Vieww = ViewWw.xyz / ViewWw.w;

vec3 lightDir = normalize(shadowLightPosition + Vieww.xyz);
     vec3 viewDir = normalize(lightDir - Vieww.xyz);
       float specularStrength = 0.0;
if (rainStrength == 1){
     specularStrength = 1.0;
}
  //float specularStrength = 0.0;
  vec3 testLight = vec3(0.5, 0.25, 0.0);

  testLight.r = (testLight.r*2.6);
    testLight.g = (testLight.g*1.4);
    testLight.b = (testLight.b*11.1);
  testLight = testLight / (testLight + 4.2);

    vec4 fragPos = gbufferProjectionInverse * vec4(TexCoords, texture2D(depthtex1, TexCoords).r, 1.0);
      fragPos = vec4(fragPos.xyz/fragPos.w, fragPos.w);


       vec3 reflectDir = reflect(-lightDir, Normal);
       float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);

       vec3 specular = specularStrength * spec * testLight;


#endif
////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////

float ShadowOn = NdotL;
float ShadowOff = 0.25;

#ifdef VanillaAmbientOcclusion
const float ambientOcclusionLevel = 0.5f;
#endif
 float depthh = texture2D(depthtex0, texcoord).x; //Sample depth buffer
vec3 screenPos = vec3(texcoord, texture2D(depthtex, texcoord).r);
vec3 clipPos = screenPos * 2.0 - 1.0;
   vec3 clip_position = vec3(texcoord, depthh) * 2.0 - 1.0; //Clip space position
vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
vec3 viewPos = tmp.xyz / tmp.w;
 vec4 world_position = gbufferModelViewInverse * vec4(viewPos, 1.0);

 float depth = texture2D(depthtex0, texcoord).x; //Sample depth buffer

    //Positions


 //View space position

  vec3 Diffuse = Albedo * (LightmapColor + GrassShadow * GetShadow(Depth) + Ambient);
    vec3 DiffuseAndSpecular = Diffuse + specular;

    gl_FragData[0] = vec4(OUTPUT, 1.0f);

}
