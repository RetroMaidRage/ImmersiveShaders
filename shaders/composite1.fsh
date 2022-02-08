#version 120
//--------------------------------------------UNIFORMS------------------------------------------
uniform sampler2D depthtex0;
uniform sampler2D colortex0;
uniform vec3 skyColor;
uniform vec2 TexCoords;
uniform float far;
uniform float near;
uniform float frameTimeCounter;
varying vec4 texcoord;
uniform int isEyeInWater;
uniform int worldTime;
uniform vec3 fogColor;
uniform float rainStrength;
flat in int water;
in  float entityId;
/*
const int colortex0Format = RGBA16F;
const int colortex1Format = RGB16;
const int colortex2Format = RGB16;
*/
//-----------------------------------------DEFINE------------------------------------------------
#define RainFog
#define RainFogDensity 0.8 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define fogDensityNight 0.24 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.14 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.2142 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define fogDensitySunset 1.2 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.2142 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
//-------------------------------------------------------------------------------------------
float     GetDepthLinear(in vec2 coord) {
   return 2.0f * near * far / (far + near - (2.0f * texture2D(depthtex0, coord).x - 1.0f) * (far - near));
}
//-------------------------------------------------------------------------------------------

float timefract = worldTime;
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);
//-------------------------------------------------------------------------------------------

void main() {

    vec3 color = texture2D(colortex0, texcoord.st).rgb;
    vec3 color2 = texture2D(colortex0, texcoord.st).rgb;


    vec3 nightFogCol = vec3(0.2, 0.3, 0.5)*fogDensityNight;
    vec3 sunsetFogCol = vec3(0.8, 0.66, 0.5)*fogDensitySunset;

    vec3 customFogColor = (sunsetFogCol*TimeSunrise + skyColor*TimeNoon + sunsetFogCol*TimeSunset + nightFogCol*TimeMidnight);
        vec3 RainFogColor = (sunsetFogCol*TimeSunrise + skyColor*TimeNoon + sunsetFogCol*TimeSunset + nightFogCol*TimeMidnight)*RainFogDensity;
    float depth = texture2D(depthtex0, texcoord.st).r;
  	bool isTerrain = depth < 1.0;



//-------------------------------------------------------------------------------------------
#ifdef RainFog
if (isTerrain) color = mix(color, RainFogColor, min(GetDepthLinear(texcoord.st) * (rainStrength*1) / far, 1.0));
#endif
if (isTerrain) color = mix(color, customFogColor, min(GetDepthLinear(texcoord.st) * TimeMidnight / far, 1.0));
//if (isTerrain) color = mix(color, customFogColor, min(GetDepthLinear(texcoord.st) * 0.15 / far, 1.0));
if (isEyeInWater > 0) color = mix(color, nightFogCol, min(GetDepthLinear(texcoord.st) *5 / far, 1.0));
//-------------------------------------------------------------------------------------------
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(color, 1.0);

}
