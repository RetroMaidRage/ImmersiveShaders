#version 120

//--------------------------------------------INCLUDE------------------------------------------

#include "/files/filters/distort.glsl"
#include "/files/filters/distort2.glsl"
#include "/files/filters/dither.glsl"
#include "/files/filters/noises.glsl"

//--------------------------------------------UNIFORMS------------------------------------------
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;
uniform sampler2D colortex5;
uniform sampler2D colortex6;
uniform sampler2D colortex7;
uniform sampler2D colortex8;
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
varying vec4 shadowPos;
varying vec3 pos;
in vec2 textureCoordinates;
uniform sampler2D gnormal;
uniform mat4 gbufferModelView;
in  float entityId;
//--------------------------------------------CONST------------------------------------------

/*
const int colortex0Format = RGBA16F;
const int colortex1Format = RGB16;
const int colortex2Format = RGB16;
const int colortex6Format = RGB16;
const int colortex8Format = RGBA32F;
const int colortex7Format = RGBA32F;
*/
#define ShadowRenderDistance 100.0f //[10.0f 20.0f 30.0f 40.0f 50.0f 60.0f 70.0f 80.0f 90.0f 100.0f 110.0f 120.0f 130.0f 140.0f 150.0f 160.0f 170.0f 180.0f]
#define NoiseTextureResolution 256 //[10.0f 20.0f 30.0f 40.0f 50.0f 60.0f 70.0f 80.0f 90.0f 100.0f 110.0f 120.0f 130.0f 140.0f 150.0f 160.0f 170.0f 180.0f]

const float sunPathRotation = -40.0f;
const int shadowMapResolution = 2048;
const int noiseTextureResolution = 1*NoiseTextureResolution;
const float shadowDistance = 1.0f*ShadowRenderDistance;
const float ambientOcclusionLevel = 0.0f;

//--------------------------------------------DEFINE------------------------------------------
#define shadowResolution 2048 //[512 1024 1536 2048 3072 4096 8192]
#define SHADOW_SAMPLES 2 //[1 2 3 4 5 6]
#define ColShadowBoost 7 //[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 223 24 25 26 27 28 29 30]
#define GrassShadow ShadowOff //[ShadowOn ShadowOff]

#define TerrainColorType DynamicTime //[DynamicTime StaticTime]
#define LIGHT_STRENGHT 6 //[1 2 3 4 5 6 7 8 9 10]
#define Ambient 0.085 ///[0.1 0.11 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]

#define ColorSettings Summertime //[Summertime Default Composition]

#define SkyLightingStrenght 0.5 //[/[0.1 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0] 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 223 24 25 26 27 28 29 30]

#define VanillaAmbientOcclusion

#define specularLight

#define volumetric_Fog
#define VL_Samples 64 //[12 16 18 20 24 28 32 48 64 128 256]
#define VL_Strenght 0.5 //[0.1 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]
#define VL_UseJitter NoJitter //[jitter]
#define VL_Color  StaticVolumetricColor //[DynamicVolumetricColor]

#define OUTPUT Diffuse //[Normal Albedo specular DiffuseAndSpecular]
#define GammaSettings 2.2 //[0.1 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]
//#define TonemappingType Uncharted2TonemapOpComposite //[Uncharted2TonemapOp Aces reinhard2 lottes]

#define SSR_WaterNormals NormalWater //[NormalWater]
#define WaterSSR
#define WaterAbsorption
#define WaterAbsorptionStrenght 1.0 //[0.1 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0]

//#define RainPuddles
//--------------------------------------------------------------------------------------------
float timefract = worldTime;
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);
//--------------------------------------------------------------------------------------------
    bool isHand = texture2D(colortex7, TexCoords).x > 1.1f;
vec3 sunsetSkyColor = vec3(0.07f, 0.15f, 0.3f);
vec3 daySkyColor = vec3(0.3, 0.5, 1.1)*0.2;
vec3 nightSkyColor = vec3(0.001,0.0015,0.0025);
vec3 DynamicSkyColor = (sunsetSkyColor*TimeSunrise + skyColor*TimeNoon + sunsetSkyColor*TimeSunset + nightSkyColor*TimeMidnight);
vec3 diag3(mat4 mat) { return vec3(mat[0].x, mat[1].y, mat[2].z); }
vec3 projMAD3(mat4 mat, vec3 v) { return diag3(mat) * v + mat[3].xyz;  }
vec3 transMAD3(mat4 mat, vec3 v) { return mat3(mat) * v + mat[3].xyz; }
//--------------------------------------------------------------------------------------------
const float stp = 1.2;			//size of one step for raytracing algorithm
const float ref = 0.1;			//refinement multiplier
const float inc = 2.2;			//increasement factor at each step
const int maxf = 4;				//number of refinements

//--------------------------------------------------------------------------------------------
vec3 nvec3(vec4 pos){
    return pos.xyz/pos.w;
}
//--------------------------------------------------------------------------------------------
vec4 nvec4(vec3 pos){
    return vec4(pos.xyz, 1.0);
}
//--------------------------------------------------------------------------------------------
float cdist(vec2 coord) {
	return max(abs(coord.s-0.5),abs(coord.t-0.5))*2.0;
}
//--------------------------------------------------------------------------------------------
    float get_linear_depth(in float depth)
    {
        return 2.0 * near * far / (far + near - (2.0 * depth - 1.0) * (far - near));
    }
//--------------------------------------------------------------------------------------------
    float lD(in float d, in float zNear, in float zFar) {
    float zN = 2.0 * d - 1.0;

    return 2.0 * zNear * zFar / (zFar + zNear - zN * (zFar - zNear));
}

//--------------------------------------------------------------------------------------------
float AdjustLightmapTorch(in float torch) {

       float K =LIGHT_STRENGHT;
       float P = 8.06f;
        return K * pow(torch, P);
}
//--------------------------------------------------------------------------------------------
float AdjustLightmapSky(in float sky){
    float sky_2 = sky * sky;
    return sky * sky_2;
}
//--------------------------------------------------------------------------------------------
vec2 AdjustLightmap(in vec2 Lightmap){
    vec2 NewLightMap;
    NewLightMap.x = AdjustLightmapTorch(Lightmap.x);
    NewLightMap.y = AdjustLightmapSky(Lightmap.y);
    return NewLightMap;
}
//--------------------------------------------------------------------------------------------
vec3 GetLightmapColor(in vec2 Lightmap){

    Lightmap = AdjustLightmap(Lightmap);

    const vec3 TorchColor = vec3(1.0f, 0.25f, 0.08f);

    vec3 TorchLighting = Lightmap.x * TorchColor;
    vec3 SkyLighting = Lightmap.y * DynamicSkyColor * SkyLightingStrenght;

    vec3 LightmapLighting = TorchLighting + SkyLighting;

    return LightmapLighting;
}
//--------------------------------------------------------------------------------------------
float Visibility(in sampler2D ShadowMap, in vec3 SampleCoords) {
    return step(SampleCoords.z - 0.001f, texture2D(ShadowMap, SampleCoords.xy).r);
}
//--------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------
vec3 TransparentShadow(in vec3 SampleCoords){

vec3 NfogColor = fogColor*1.5;

vec3 Summertime =  NfogColor;
Summertime.r = NfogColor.r*2;

vec3 Default = fogColor*1.5;
Default.r +=0.5;

vec3 Composition = NfogColor*1.5;
Composition.r +=2.8;
Composition.b +=1.2;

    float ShadowVisibility0 = Visibility(shadowtex0, SampleCoords);
    float ShadowVisibility1 = Visibility(shadowtex1, SampleCoords);


float ShadowVisibility3 = ShadowVisibility1 * ColShadowBoost;
    vec4 ShadowColor0 = texture2D(shadowcolor0, SampleCoords.xy);
    vec3 TransmittedColor = ShadowColor0.rgb * (1.0 - ShadowColor0.a);

    return mix(ShadowVisibility3 * TransmittedColor, vec3(1.0)*ColorSettings, ShadowVisibility0);
}
//--------------------------------------------------------------------------------------------

const int ShadowSamplesPerSize = 2 * SHADOW_SAMPLES + 1;
const int TotalSamples = ShadowSamplesPerSize * ShadowSamplesPerSize;
//--------------------------------------------------------------------------------------------
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
//--------------------------------------------------------------------------------------------
#ifdef volumetric_Fog
vec3 computeVL(vec3 viewPos) {
    vec3 color = vec3(0.0);
    vec3 colorr = vec3(0.0, 0.0,0.0);
     colorr = fogColor*1.5;

    vec3 colorVL =  colorr;
    colorVL.r = colorr.r*2;

    vec3 DynamicVolumetricColor = (colorVL*TimeSunrise+ fogColor*TimeNoon+colorVL*TimeSunset+vec3(0.0)*TimeMidnight);
    vec3 StaticVolumetricColor=vec3(1.0);

    float INV_SAMPLES = 1.0 /  VL_Samples;

    vec3 startPos = projMAD3(shadowProjection, transMAD3(shadowModelView, gbufferModelViewInverse[3].xyz));
    vec3 endPos   = projMAD3(shadowProjection, transMAD3(shadowModelView, mat3(gbufferModelViewInverse) * viewPos));

    float jitter = fract(frameTimeCounter + bayer16(gl_FragCoord.xy));
    float NoJitter = 1.0;

    float dist   = distance(startPos, endPos);
    vec3 rayDir  = (normalize(endPos - startPos) * dist) * INV_SAMPLES*VL_UseJitter;

    vec3 rayPos = startPos;
    for(int i = 0; i < VL_Samples; i++) {
        rayPos += rayDir;

        vec3 samplePos = vec3(DistortPosition(rayPos.xy), rayPos.z) * 0.5 + 0.5;

        float shadowVisibility0 = step(samplePos.z - 1e-3, texture(shadowtex0, samplePos.xy).r);
        float shadowVisibility1 = step(samplePos.z - 1e-3, texture(shadowtex1, samplePos.xy).r);

        vec4 shadowColor      = texture(shadowcolor0, samplePos.xy);
        vec3 transmittedColor = shadowColor.rgb * (1.0 - shadowColor.a);
        if ((worldTime < 22000 || worldTime > 500)){
  VL_Color = vec3(0.2, 0.0, 0.0);
}
        float extinction = 1.0 - exp(-dist * 1);
        color += (mix(transmittedColor * shadowVisibility1, VL_Color, shadowVisibility0) + shadowVisibility0) * extinction*fogColor;

      //  color *= colorVL;
    }
    return color * INV_SAMPLES;
}
#endif
//--------------------------------------------------------------------------------------------
vec3 fresnel(vec3 raydir, vec3 normal){
    vec3 F0 = vec3(1.0);
    return F0+(1.0-F0)*pow(1.0-dot(-raydir, normal), 5.0);
}
//--------------------------------------------------------------------------------------------
#ifdef WaterAbsorption
vec3 Water_Absorbtion(vec2 TexCoords)
{

    vec3 WATER_FOG_COLOR = vec3(0.4, 0.07, 0.03);

vec3 w2 = vec3(0.08);

    float depth_solid = get_linear_depth(texture2D(depthtex0, TexCoords).x);
    float depth_translucent = get_linear_depth(texture2D(depthtex1, TexCoords).x);

    float dist_fog = distance(depth_solid, depth_translucent);

    vec3 absorption = exp(-w2 * dist_fog)*WaterAbsorptionStrenght;

    return max(absorption,  0.7);
}
#endif
//--------------------------------------------------------------------------------------------
#ifdef WaterSSR
vec4 raytrace(vec3 viewdir, vec3 normal){
  if(isHand){
  //http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/2381727-shader-pack-datlax-onlywater-only-water
    vec4 color = vec4(0.0);
    vec4 watercolor_buffer = texture2D(colortex6, texcoord);
    float jitter = fract(frameTimeCounter + bayer256(gl_FragCoord.xy));

    vec3 rvector = normalize(reflect(normalize(viewdir), normalize(normal)));
    vec3 vector = stp * rvector;
    vec3 oldpos = viewdir;
    viewdir += vector;
    int sr = 0;

    for(int i = 0; i < 40; i++){
    vec3 pos = nvec3(gbufferProjection * nvec4(viewdir)) * 0.5 + 0.5;

        if(pos.x < 0 || pos.x > 1 || pos.y < 0 || pos.y > 1 || pos.z < 0 || pos.z > 1.0) break;

        vec3 spos = vec3(pos.st, texture2D(depthtex0, pos.st).r);
        spos = nvec3(gbufferProjectionInverse * nvec4(spos * 2.0 - 1.0));
	    	float err = abs(viewdir.z-spos.z);

		if(err < pow(length(vector)*1.85,1.15) && texture2D(gaux1,pos.st).g < 0.01)
    {      sr++;   if(sr >= maxf){

  float border = clamp(1.0 - pow(cdist(pos.st), 1.0), 0.0, 1.0);
  color = texture2D(gcolor, pos.st);
					float land = texture2D(gaux1, pos.st).g;
					land = float(land < 0.03);
					spos.z = mix(viewdir.z,2000.0*(0.4+1.0*0.6),land);
					color.a = 1.0;
                    color.a *= border;
                    break;
                }
                viewdir = oldpos;
                vector *=ref;
        }
        vector *= inc;
        oldpos = viewdir;
        viewdir += vector;
    }
    return color;
  }
}


#endif

vec4 raytraceGround(vec3 viewdir, vec3 normal){
  //http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/2381727-shader-pack-datlax-onlywater-only-water
      vec4 color = vec4(0.0);
    if(isHand){
     color = vec4(0.0);
  }else{
    vec4 watercolor_buffer = texture2D(colortex6, texcoord);

    vec3 rvector = normalize(reflect(normalize(viewdir), normalize(normal)));
    vec3 vector = stp * rvector;
    vec3 oldpos = viewdir;
    viewdir += vector;
    int sr = 0;

    for(int i = 0; i < 40; i++){
    vec3 pos = nvec3(gbufferProjection * nvec4(viewdir)) * 0.5 + 0.5;

        if(pos.x < 0 || pos.x > 1 || pos.y < 0 || pos.y > 1 || pos.z < 0 || pos.z > 1.0) break;

        vec3 spos = vec3(pos.st, texture2D(depthtex0, pos.st).r);
        spos = nvec3(gbufferProjectionInverse * nvec4(spos * 2.0 - 1.0));
	    	float err = abs(viewdir.z-spos.z);

		if(err < pow(length(vector)*1.85,1.15) && texture2D(gaux1,pos.st).g < 0.01)
    {      sr++;   if(sr >= maxf){

  float border = clamp(1.0 - pow(cdist(pos.st), 1.0), 0.0, 1.0);
  color = texture2D(gcolor, pos.st);
					float land = texture2D(gaux1, pos.st).g;
					land = float(land < 0.03);
					spos.z = mix(viewdir.z,2000.0*(0.4+1.0*0.6),land);
					color.a = 1.0;
                    color.a *= border;
                    break;
                }
                viewdir = oldpos;
                vector *=ref;
        }
        vector *= inc;
        oldpos = viewdir;
        viewdir += vector;
    }
    return color;
}}

float getRainPuddles(vec3 worldpos, vec3 Normal){

	vec2 coord = (worldpos.xz/10000);

	float rainPuddles = texture2D(noisetex, (coord.xy*8)).x;
	rainPuddles += texture2D(noisetex, (coord.xy*4)).x;
	rainPuddles += texture2D(noisetex, (coord.xy*2)).x;
	rainPuddles += texture2D(noisetex, (coord.xy/2)).x;

	float strength = max(rainPuddles-2.15,0.0);

  vec3 reflectDir = reflect(worldpos, Normal);


	return strength;
}
//--------------------------------------------------------------------------------------------
void main(){
    vec3 Albedo = pow(texture2D(colortex0, TexCoords).rgb, vec3(GammaSettings));

    float Depth = texture2D(depthtex0, TexCoords).r;
    if(Depth == 1.0f){
        gl_FragData[0] = vec4(Albedo, 1.0f);
        return;
    }

    vec3 ClipSpacee = vec3(TexCoords, Depth) * 2.0f - 1.0f;
    vec4 ViewWw = gbufferProjectionInverse * vec4(ClipSpacee, 1.0f);
    vec3 Vieww = ViewWw.xyz / ViewWw.w;

    vec3 lightDir = normalize(shadowLightPosition + Vieww.xyz);
    vec3 viewDir = normalize(lightDir - Vieww.xyz);

    vec3 Normal = normalize(texture2D(colortex1, TexCoords).rgb * 2.0f - 1.0f);
    vec3 NormalWater = normalize(texture2D(colortex5, TexCoords).rgb * 2.0f - 1.0f);

    vec2 Lightmap = texture2D(colortex2, TexCoords).rg;

    vec3 LightmapColor = GetLightmapColor(Lightmap);
    float NdotL = max(dot(Normal, normalize(shadowLightPosition)), 0.0f);

    bool isWater = texture2D(colortex7, TexCoords).x > 1.1f;
    vec3 specular;
//--------------------------------------------------------------------------------------------
#ifdef specularLight

if(isWater){

  vec3 testLight3 = fogColor*1.5;

  vec3 Summertime3 =  testLight3;
  Summertime3.r = testLight3.r*2;

vec4 testLight = vec4(0.5, 0.25, 0.0, 1.0);//*vec4(skyColor, 1.0);
vec4 testLight2 = vec4(0.75, 0.25, 0.25, 1.0);//*vec4(skyColor, 1.0);

vec3 reflectDir = reflect(-lightDir, NormalWater);
float spec = pow(max(dot(viewDir, reflectDir), 0.0), 512);
 specular = 1.5 * spec *Summertime3;
}
#endif
//--------------------------------------------------------------------------------------------
vec3 screenPos1 = vec3(texcoord, texture2D(depthtex, texcoord).r);
vec3 clipPos1 = screenPos1 * 2.0 - 1.0;
vec4 tmp1 = gbufferProjectionInverse * vec4(clipPos1, 1.0);
vec3 viewPos1 = tmp1.xyz / tmp1.w;
vec4 world_position = gbufferModelViewInverse * vec4(viewPos1, 1.0);
vec3 ViewDir = normalize(viewPos1);

//--------------------------------------------------------------------------------------------
vec3 ClipSpace = vec3(TexCoords, texture2D(depthtex0, TexCoords).x) * 2.0f - 1.0f;

vec4 ClipSpaceToViewSpace = gbufferProjectionInverse * vec4(ClipSpace, 1.0f);

vec3 ViewSpace = ClipSpaceToViewSpace.xyz / ClipSpaceToViewSpace.w;

vec3 ViewDirect = normalize(ViewSpace);

vec3 screenPos5 = vec3(texcoord, texture2D(depthtex0, texcoord).r);
vec3 clipPos5 = screenPos5 * 2.0 - 1.0;
vec4 tmp5 = gbufferProjectionInverse * vec4(clipPos5, 1.0);
vec3 viewPos5 = tmp5.xyz / tmp5.w;
vec3 eyePlayerPos5 = mat3(gbufferModelViewInverse) * viewPos5;
vec3 feetPlayerPos5 = eyePlayerPos5 + gbufferModelViewInverse[3].xyz;
vec3 worldPos5 = feetPlayerPos5 + cameraPosition;

vec3 rd = normalize(vec3(world_position.x,world_position.y,world_position.z));
//--------------------------------------------------------------------------------------------
float ShadowOn = NdotL;
float ShadowOff = 0.25;
//--------------------------------------------------------------------------------------------
vec3 Diffuse = Albedo * (LightmapColor + GrassShadow * GetShadow(Depth) + Ambient);

//--------------------------------------------------------------------------------------------
#ifdef VanillaAmbientOcclusion
const float ambientOcclusionLevel = 1.0f;
#endif
//--------------------------------------------------------------------------------------------
vec3 frenselcolor = fresnel(rd, SSR_WaterNormals)*2;
//--------------------------------------------------------------------------------------------
vec4 reflection = vec4(1.0);
vec4 reflection2 = vec4(1.0);
vec4 reflectionRain = vec4(1.0);
vec4 reflection2Rain = vec4(1.0);
vec4 absorbtion = vec4(1.0);
float VL_Strenght2;
vec4 rainpuddles;
//--------------------------------------------------------------------------------------------
#ifdef WaterSSR
if(isWater){

 reflection = raytrace(ViewDirect, SSR_WaterNormals);
 reflection.rgb * fresnel(rd, SSR_WaterNormals);
 	reflection2.rgb = mix(texture2D(gcolor, TexCoords).rgb, reflection.rgb,frenselcolor*reflection.a * (vec3(1.0) - texture2D(gcolor, TexCoords).rgb));
 }else{

     reflection2 = vec4(1.0);
 }
#endif
//--------------------------------------------------------------------------------------------
#ifdef WaterAbsorption
if(isWater){
absorbtion.rgb *=Water_Absorbtion(TexCoords);
}
#endif
//--------------------------------------------------------------------------------------------
#ifdef volumetric_Fog
if ((worldTime < 14000 || worldTime > 22000)) {
Diffuse += computeVL(ViewSpace)*VL_Strenght;
}
#endif

//-----------------------------------------------------------------------------------------
#ifdef RainPuddles

float rainpuddleee = getRainPuddles(worldPos5, Normal);
vec4 reflectionpuddle = raytraceGround(ViewDirect, Normal);
reflectionpuddle.rgb*=fresnel(rd, SSR_WaterNormals);
vec4 rainPuddles = vec4(0.0, 0.0, 0.0, 1.0);
vec4 rainPuddles2 = vec4(0.0, 0.0, 0.0, 1.0);

 reflectionRain = raytraceGround(ViewDirect, Normal);
 reflectionRain.rgb * fresnel(rd, Normal);
 reflection2Rain.rgb = mix(texture2D(gcolor, TexCoords).rgb, reflectionRain.rgb,col3*reflectionRain.a * (vec3(1.0) - texture2D(gcolor, TexCoords).rgb));

    rainPuddles +=rainpuddleee*reflection2Rain;
    rainpuddles = mix(rainPuddles,rainPuddles2, rainpuddleee)*reflection2Rain;

#endif
//--------------------------------------------------------------------------------------------
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(OUTPUT, 1.0)*absorbtion*reflection2+vec4(specular, 1.0)+rainpuddles;

}
