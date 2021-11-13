#version 120
//godrays and bloom from mrsheepshaders
//--------------------------------------------INCLUDE------------------------------------------
#include "/files/tonemaps/tonemap_uncharted.glsl"
#include "/files/tonemaps/tonemap_aces.glsl"
//#include "tonemaps/tonemap_reinhard.glsl"
//#include "/files/rays/godrays.glsl"
#include "/files/filters/dither.glsl"
//--------------------------------------------UNIFORMS------------------------------------------
varying vec4 texcoord;
uniform sampler2D gcolor;
uniform sampler2D depthtex0;
uniform sampler2D composite;
uniform vec3 sunPosition;
uniform mat4 gbufferProjection;
uniform float worldTime;
uniform float rainStrength;
uniform float aspectRatio;
uniform float near;
uniform float far;
uniform sampler2D gaux1;
uniform vec3 fogColor;
uniform vec3 shadowLightPosition;
uniform float displayWidth;
uniform sampler2D noisetex;
uniform sampler2D colortex0;
varying vec3 sunVector;
//--------------------------------------------DEFINE------------------------------------------
#define TONEMAPPING
#define TonemappingType Uncharted2TonemapOp //[Uncharted2TonemapOp Aces]
#define SUNRAYS
//#define MOONRAYS
#define SkyRenderingType composite //[colortex0 composite]
#define SUNRAYS_DECAY 0.90 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 ]
#define SUNRAYS_LENGHT 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 ]
#define SUNRAYS_BRIGHTNESS 0.2 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 2 3 4 5 6 7 8 9 10]
#define SUNRAYS_SAMPLES 32 //[1 2 3 4 5 6 7 8 9 10 11 12 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 48 64 128 256 512 1024]
#define SUNRAYS_COLOR_RED 3.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define SUNRAYS_TYPE Godrays //[Godrays Crespecular]

//#define BLOOM
#define BLOOM_AMOUNT 5 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define BLOOM_QUALITY 5 //[1 2 3 4 5 6 7 8 9 10 11 12]
#define BLOOM_QUALITY2 -2 //[-1 -2 -3 -4 -5 -6 -7 -8 -9 -10 -11 -12]

#define COLORCORRECT_RED 1.6 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define COLORCORRECT_GREEN 1.4 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define COLORCORRECT_BLUE 1.1 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define GAMMA 1.0 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define CROSSPROCESS

#define Vignette
#define Vignette_Distance 1.7 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.2142 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define Vignette_Strenght 1.0 ///[0.0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define Vignette_Radius 3.0 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]

   float getDepth(vec2 coord) {
       return 2.0 * near * far / (far + near - (2.0 * texture2D(depthtex0, coord).x - 1.0) * (far - near));
   }

   mat4 ditherr = mat4(
      0,       0.5,    0.125,  0.625,
      0.75,    0.25,   0.875,  0.375,
      0.1875,  0.6875, 0.0625, 0.5625,
      0.9375,  0.4375, 0.8125, 0.3125
   );

   float timefract = worldTime;
   float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
   float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
   float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
   float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);


   #ifdef SUNRAYS

   const float GR_DECAY    = 1.0*SUNRAYS_DECAY;
   const float GR_DENSITY  = 1.0*SUNRAYS_LENGHT;
   const float GR_EXPOSURE = 1.0*SUNRAYS_BRIGHTNESS;
   const int GR_SAMPLES    = 1*SUNRAYS_SAMPLES;
   #endif



   void VignetteColor(inout vec3 color) {
   float dist = distance(texcoord.st, vec2(0.5)) * 2.0;
   dist /= Vignette_Distance;

   dist = pow(dist, Vignette_Radius);

   color.rgb *= (1.0f - dist) /Vignette_Strenght;
   }

void main() {
	vec4 color = texture2D(SkyRenderingType, texcoord.st);


  #ifdef SUNRAYS
     float jitter = fract(worldTime + bayer2(gl_FragCoord.xy));
  		vec4 tpos = vec4(sunPosition,1.0)*gbufferProjection;
  		tpos = vec4(tpos.xyz/tpos.w,1.0);
  		vec2 pos1 = tpos.xy/tpos.z;
  		vec2 Godrays = pos1*0.5+0.5;
      float threshold = 0.99 * far;
//
      vec2 Crespecular = sunPosition.xy / -sunPosition.z;
      Crespecular.y *= aspectRatio;
  Crespecular = (Crespecular + 1.0)/2.0;
//
        if ((worldTime < 14000 || worldTime > 22000) && sunPosition.z < 0)

          {
vec2 texCoord = texcoord.st;
vec2 delta = (texCoord - SUNRAYS_TYPE) * GR_DENSITY / float(SUNRAYS_SAMPLES);
float decay = -sunPosition.z / 1000.0;
vec3 colorGR = vec3(0.0);
vec3 sample = vec3(0.0);

for (int i = 0; i < GR_SAMPLES; i++) {
texCoord -= delta;

if (texCoord.x < 0.0 || texCoord.x > 1.0) {
if (texCoord.y < 0.0 || texCoord.y > 1.0) { break;
                }
          }

if (getDepth(texCoord) > threshold) {
sample = texture2D(gaux1, texCoord).rgb;
}
sample *= vec3(decay);

if (distance(texCoord, SUNRAYS_TYPE) > 0.05) sample *= 0.2;
colorGR += sample;
  decay *= GR_DECAY;
                  }

  			colorGR.r = colorGR.r, fogColor;
  			colorGR.g = colorGR.g, fogColor;
  			colorGR.b = colorGR.b, fogColor;
                  color = (color + GR_EXPOSURE * vec4(colorGR.r * SUNRAYS_COLOR_RED, colorGR.g * 1.12, colorGR.b * 0.50, 0.01)*(TimeSunrise+TimeNoon+TimeSunset)* clamp(1.0 - rainStrength,0.1,1.0));
                //  color = (color + GR_EXPOSURE * vec4(colorGR.r * SUNRAYS_COLOR_RED, colorGR.g * 1.12, colorGR.b * 0.50, 0.01)*TimeMidnight* clamp(1.0 - rainStrength,0.1,1.0));
          }
  #endif




  #ifdef BLOOM
  	int j;
  	int i;
  	vec4 sum = vec4(0);
          float gaux1 = 0;
      for( i= -BLOOM_QUALITY2 ;i < BLOOM_QUALITY; i++) {
          for (j = -BLOOM_QUALITY2; j < BLOOM_QUALITY; j++) {
              vec2 coord = texcoord.st + vec2(j,i) * 0.001;
                  if(coord.x > 0 && coord.x < 1 && coord.y > 0 && coord.y < 1){
                      sum += texture2D(composite, coord) * BLOOM_AMOUNT;
                      gaux1 += 1;
                  }
              }
      }
      sum = sum / vec4(gaux1);
  		color += sum*sum*0.012;
  #endif



#ifdef CROSSPROCESS
  color.r = (color.r*COLORCORRECT_RED);
    color.g = (color.g*COLORCORRECT_GREEN);
    color.b = (color.b*COLORCORRECT_BLUE);

  color = color / (color + 2.2) * (1.0+2.0);
#endif

#ifdef TONEMAPPING
color.rgb = TonemappingType(color.rgb)*GAMMA;
#endif

#ifdef Vignette
VignetteColor(color.rgb);
#endif



gl_FragColor = vec4(color.rgb, 1.0f);

}
