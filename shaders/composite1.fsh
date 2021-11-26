#version 150 compatibility
//--------------------------------------------UNIFORMS------------------------------------------
uniform sampler2D depthtex0;
uniform sampler2D colortex0;
uniform vec3 skyColor;
uniform float far;
uniform float near;
uniform float frameTimeCounter;
varying vec4 texcoord;
uniform int isEyeInWater;
uniform int worldTime;
uniform vec3 fogColor;
uniform float rainStrength;
flat in int water;
//--------------------------------------------DEFINE------------------------------------------
#define CustomFog
#define fogSetting customFogColor//[skyColor fogColor]
#define fogDistance 0.35  ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define fogDensityNight 1.84 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.14 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.2142 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define fogDensitySunset 1.2 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.2142 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]

#define WaterFog
#define LavaFog


float interpolateSmooth1(float x) { return x * x * (3.0 - 2.0 * x); }
vec2  interpolateSmooth2(vec2  v) { return v * v * (3.0 - 2.0 * v); }
vec3  interpolateSmooth3(vec3  v) { return v * v * (3.0 - 2.0 * v); }

float     GetDepthLinear(in vec2 coord) {
   return 2.0f * near * far / (far + near - (2.0f * texture2D(depthtex0, coord).x - 1.0f) * (far - near));
}


float timefract = worldTime;
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);

void main() {

    vec3 color = texture2D(colortex0, texcoord.st).rgb;

    float depth = texture2D(depthtex0, texcoord.st).r;

    vec3 nightFogCol = vec3(0.2, 0.3, 0.5)*fogDensityNight;

    vec3 sunsetFogCol = vec3(0.8, 0.66, 0.5)*fogDensitySunset;



    vec3 fogCol = skyColor;
    vec3 customFogColor = interpolateSmooth3(sunsetFogCol*TimeSunrise + fogCol*TimeNoon + sunsetFogCol*TimeSunset + nightFogCol*TimeMidnight);

    vec3 waterfogColor = pow(vec3(0, 255, 355) / 255.0, vec3(2.2));

    vec3 lavafogColor = pow(vec3(195, 87, 0) / 255.0, vec3(2.2));

    bool isTerrain = depth < 1.0;
#ifdef WaterFog
    if (isEyeInWater == 1) {
        color = mix(color, waterfogColor, min(GetDepthLinear(texcoord.st) * 2.3 / far, 1.0));
    }
#endif

#ifdef LavaFog
    if (isEyeInWater == 2) {
        color = mix(color, lavafogColor, min(GetDepthLinear(texcoord.st) * 2.3 / far, 1.0));
    }
#endif

    #ifdef CustomFog
    if (isTerrain) color = mix(color, fogSetting, min(GetDepthLinear(texcoord.st) * fogDistance / far, 1.0));
    #endif
color = mix(color, fogSetting, min(GetDepthLinear(texcoord.st) * rainStrength / far, 1.0));
color = mix(color, fogSetting, min(GetDepthLinear(texcoord.st) * TimeMidnight / far, 1.0));


    gl_FragData[0] = vec4(color, 1.0);

}
