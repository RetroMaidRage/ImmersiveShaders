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
#define CloudDestiny 7.604 //[1 2 3 4 5 6 7 8 9 10]
#define CloudSpeed 0.15 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 2 3 4 5 6 7 8 9 10]
//------------------------------------------------------------------------------------------
float timefract = worldTime;
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);

//--------------------------------------------MAIN------------------------------------------
void main() {

    vec4 color = texture2D(gcolor, texcoord);

//--------------------------------------------POS------------------------------------------
    vec3 screenPos = vec3(texcoord, texture2D(depthtex0, texcoord).r);
    vec3 clipPos = screenPos * 2.0 - 1.0;
    vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
    vec3 viewPos = tmp.xyz / tmp.w;
    vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
    vec3 feetPlayerPos = eyePlayerPos + gbufferModelViewInverse[3].xyz;
    vec3 worldPos = feetPlayerPos + cameraPosition;

    vec4 Clouds = vec4(0.0);
    vec3 FinalDirection = vec3(0.0);
    vec4 colorr = vec4(0., 0., 0.1, 1.0);
//-----------------------------------------------------------------------------------------

    if(texture2D(depthtex0, texcoord).r == 1.0) {


    FinalDirection = worldPos.xyz / worldPos.y;
    FinalDirection.y *= 8000.0;
        if (FinalDirection.y > 8000.0){

        }
//-----------------------------------------------------------------------------------------


//-----------------------------------CLOUD_NOISE-------------------------------------------
vec3 rd = normalize(vec3(worldPos.x,worldPos.y,worldPos.z));
	vec3 L = mat3(gbufferModelViewInverse) * normalize(shadowLightPosition.xyz);


    float speed = frameTimeCounter * CloudSpeed;
    vec2 pos = FinalDirection.zx*3.1;

    float awan = 0.0;
    float d = 1.400;

    for(int i = 0; i < 15; i++){

       awan += fbm(pos) / d;
       pos *= 2.040;
       d *= 2.064;
       pos -= speed * 0.127 * pow(d, 0.9);
    }
//-----------------------------------CLOUD_NOISE-------------------------------------------
  vec3 Normal = normalize(texture2D(colortex1, TexCoords).rgb * 2.0f - 1.0f);
    float NdotL = max(dot(Normal, normalize(shadowLightPosition)), 0.0f);
      float sunAmount = max(dot(rd, L), 0.0);
//-----------------------------------INSIDE-------------------------------------------
    vec3 nightFogCol = vec3(0.0,0.0,0.0);
    vec3 sunsetFogCol = vec3(0.3,0.2,0.2);
//-----------------------------------OUTSIDE-------------------------------------------
    vec3 nightFogColOut = vec3(0.0, 0.0,0.0);
    vec3 sunsetFogColOut = vec3(0.2, 0.2,0.2);
//-------------------------------------------------------------------------------------
    vec3 CloudColorSun = (sunsetFogCol*TimeSunrise + skyColor*TimeNoon + sunsetFogCol*TimeSunset + nightFogCol*TimeMidnight);
    vec3 CloudColorOutSun = (sunsetFogColOut*TimeSunrise + skyColor*TimeNoon + sunsetFogColOut*TimeSunset + nightFogColOut*TimeMidnight);
//-------------------------------------------------------------------------------------
    vec4  fogColor  = mix( vec4(CloudColorOutSun, 1.0), vec4(CloudColorSun, 1.0), pow(sunAmount,1.0) );
//-------------------------------------------------------------------------------------
		color.r = (color.r*2);
    color.g = (color.g*3);
    color.b = (color.b*5);
  color = color / (color + 40.2) * (1.0+2.0);
//-------------------------------------------------------------------------------------
    Clouds = mix(color, fogColor, pow(abs(awan), (CloudDestiny-(1.0 + rainStrength))));
//-------------------------------------------------------------------------------------

#ifdef Cloud
color = color + Clouds;
#endif

}


/* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}
