#version 120
//--------------------------------------------INCLUDE------------------------------------------
#include "/files/filters/noises.glsl"
//--------------------------------------------UNIFORMS------------------------------------------
uniform float frameTimeCounter;
uniform sampler2D gcolor;
uniform sampler2D shadowcolor0;
uniform sampler2D colortex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D depthtex0;
uniform vec3 cameraPosition;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D gaux3;
uniform sampler2D noisetex;
uniform sampler2D texture;
uniform int worldTime;
uniform sampler2D gaux4;
uniform vec3 fogColor;
uniform vec3 skyColor;
varying vec2 texcoord;
varying vec2 TexCoords;
uniform vec3 shadowLightPosition;
uniform sampler2D colortex1;
uniform vec3 upPosition;
const int noiseTextureResolution = 512;
uniform float rainStrength;
/*
const int colortex0Format = RGBA16F;
const int colortex1Format = RGB16;
const int colortex2Format = RGB16;
*/


//------------------------------------------------------------------------------------------
#define Cloud
#define CloudDestiny 7.604 //[1 2 3 4 5 6 7 8 9 10 11 12 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 48 64 128 256 512 1024]
#define CloudSpeed 0.03 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define CloudGlobalMove
#define CloudNoiseType fbm //[noise]
//------------------------------------------------------------------------------------------
float timefract = worldTime;
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);

//--------------------------------------------MAIN-----------------------------------------
void main() {
//--------------------------------------------POS------------------------------------------
    vec3 screenPos = vec3(texcoord, texture2D(depthtex0, texcoord).r);
    vec3 clipPos = screenPos * 2.0 - 1.0;
    vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
    vec3 viewPos = tmp.xyz / tmp.w;
    vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
    vec3 feetPlayerPos = eyePlayerPos + gbufferModelViewInverse[3].xyz;
    vec3 worldPos = feetPlayerPos + cameraPosition;
//--------------------------------------------POS_USED--------------------------------------
    vec3 screenPoss = vec3(texcoord.st, texture2D(depthtex0, texcoord.st).r);
  	vec3 clipPoss = screenPoss * 2.0 - 1.0;
  	vec4 tmps = gbufferProjectionInverse * vec4(clipPoss, 1.0);
  	vec3 viewPoss = tmps.xyz / tmps.w;
  	vec4 world_position = gbufferModelViewInverse * vec4(viewPoss, 1.0);
//------------------------------------------------------------------------------------------
  float awan = 0.0;
  float d = 1.400;
  vec4 Clouds = vec4(0.0);
  vec3 FinalDirection = vec3(0.0);
  vec3 FinalDirection2 = vec3(0.0);
  float speed = frameTimeCounter * CloudSpeed;
  float speedNoise = frameTimeCounter * 0.003; // Глеб мэски
  float CloudMove = speed * 0.127 * pow(d, 0.9);
  vec4 color = texture2D(gcolor, texcoord);
//-----------------------------------------------------------------------------------------

if(texture2D(depthtex0, texcoord).r == 1.0) {
//if(texture2D(depthtex0, texcoord).r == 1.0 && sign(FinalDirection + cameraPosition.y) == sign(eyePlayerPos.y)) {

FinalDirection = world_position.xyz / world_position.y;
FinalDirection2 = world_position.xyz / world_position.y;
FinalDirection.y *= 8000.0;
FinalDirection2.y *= 8000.0;
//-----------------------------------------------------------------------------------------
#ifdef CloudGlobalMove
FinalDirection -=  CloudMove;
#endif
//-----------------------------------CLOUD_NOISE-------------------------------------------
vec3 rd = normalize(vec3(worldPos.x,worldPos.y,worldPos.z));
vec3 L = mat3(gbufferModelViewInverse) * normalize(shadowLightPosition.xyz);


  vec2 pos = FinalDirection.zx*3.1;

       for(int i = 0; i < 15; i++) {   //CLOUD SAMPLES

       awan += CloudNoiseType(pos) / d;
       pos *= 2.040;
       d *= 2.064;
       pos -= CloudMove*(speedNoise)*2;
}
//-----------------------------------CLOUD_NOISE-------------------------------------------
vec3 Normal = normalize(texture2D(colortex1, TexCoords).rgb * 2.0f - 1.0f);
float NdotL = max(dot(Normal, normalize(shadowLightPosition)), 0.0f);
float sunAmount = max(dot(rd, L), 0.0);
//-----------------------------------INSIDE------------------------------------------------
    vec3 nightFogCol = vec3(0.0,0.0,0.0);
    vec3 sunsetFogCol = vec3(0.3,0.2,0.2)*2;
//-----------------------------------OUTSIDE-----------------------------------------------
    vec3 nightFogColOut = vec3(0.0, 0.0,0.0);
    vec3 sunsetFogColOut = vec3(0.2, 0.2,0.2)*2;
//-----------------------------------------------------------------------------------------
    vec3 CloudColorSun = (sunsetFogCol*TimeSunrise + skyColor*TimeNoon + sunsetFogCol*TimeSunset + nightFogCol*TimeMidnight);
    vec3 CloudColorOutSun = (sunsetFogColOut*TimeSunrise + skyColor*TimeNoon + sunsetFogColOut*TimeSunset + nightFogColOut*TimeMidnight);
//-----------------------------------------------------------------------------------------
    vec4 fogColor = mix( vec4(CloudColorOutSun, 1.0), vec4(CloudColorSun, 1.0), pow(sunAmount,1.0) );
//-----------------------------------------------------------------------------------------
		color.r = (color.r*2);
    color.g = (color.g*3);
    color.b = (color.b*5);
    color = color / (color + 40.2) * (1.0+2.0);
//----------------------------------------------------------------------------------------
    Clouds = mix(color, fogColor, pow(abs(awan), (CloudDestiny-(1.0 + rainStrength))));
//----------------------------------------------------------------------------------------
#ifdef Cloud
color = color + Clouds;
#endif
//----------------------------------------------------------------------------------------
}

//----------------------------------------------------------------------------------------
/* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}
