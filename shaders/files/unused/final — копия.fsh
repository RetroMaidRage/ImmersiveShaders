#version 120
//--------------------------------------------INCLUDE------------------------------------------
#include "/files/tonemaps/tonemap_uncharted.glsl"
#include "/files/tonemaps/tonemap_aces.glsl"
//#include "tonemaps/tonemap_reinhard.glsl"
#include "/files/filters/dither.glsl"
//#include "/files/rays/godrays.glsl"
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
uniform float displayHeight;
uniform sampler2D sampler0;
uniform sampler2D sampler1;
uniform sampler2D sampler2;
//--------------------------------------------DEFINE------------------------------------------
#define TONEMAPPING
#define TonemappingType Uncharted2TonemapOp //[Uncharted2TonemapOp Aces]
#define GODRAYS
//#define MOONRAYS

#define GODRAYS_DECAY 0.90 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 ]
#define GODRAYS_LENGHT 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 ]
#define GODRAYS_BRIGHTNESS 0.2 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 2 3 4 5 6 7 8 9 10]
#define GODRAYS_SAMPLES 14 //[1 2 3 4 5 6 7 8 9 10 11 12 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 21 48 64 128]
#define GODRAYS_COLOR_RED 1.85 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define GODRAYS_DITHER dither //[1.0 dither]

#define CRESPECULAR_RAYS

#define BLOOM
#define BLOOM_AMOUNT 5 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define BLOOM_QUALITY 2 //[1 2 3 4 5 6 7 8 9 10 11 12]
#define BLOOM_QUALITY2 -2 //[-1 -2 -3 -4 -5 -6 -7 -8 -9 -10 -11 -12]

#define COLORCORRECT_RED 1.6 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define COLORCORRECT_GREEN 1.4 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define COLORCORRECT_BLUE 1.1 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define GAMMA 1.0 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]

#define Vignette
#define Vignette_Distance 1.5142 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.2142 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define Vignette_Strenght 1.0 ///[0.0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define Vignette_Radius 3.0 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]

   float dither = bayer64(gl_FragCoord.xy);

   float getDepth(vec2 coord) {
       return 2.0 * near * far / (far + near - (2.0 * texture2D(depthtex0, coord).x - 1.0) * (far - near));
   }

vec2 getDepthCR(vec2 coord);

vec2 getDepthCR(vec2 coord) {
	float depth = texture2D(sampler1, coord).x;
	float depth2 = texture2D(sampler2, coord).x;
	float fg = -1.0;
	if (depth2 < 1.0) {
		depth = depth2;
		fg = 1.0;
	}

    return vec2(2.0 * near * far / (far + near - (2.0 * depth - 1.0) * (far - near)), fg);
}


   float timefract = worldTime;
   float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
   float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
   float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
   float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);


   #ifdef GODRAYS

   const float GR_DECAY    = 1.0*GODRAYS_DECAY;
   const float GR_DENSITY  = 1.0*GODRAYS_LENGHT;
   const float GR_EXPOSURE = 1.0*GODRAYS_BRIGHTNESS;
   const int GR_SAMPLES    = 4*GODRAYS_SAMPLES;
   #endif

   #ifdef CRESPECULAR_RAYS

   const float CR_DECAY 	= 10.95;
   const float CR_DENSITY 	= 10.5;
   const float CR_EXPOSURE = 10.2;
   const int CR_SAMPLES 	= 32;

   #endif

   void VignetteColor(inout vec3 color) {
   float dist = distance(texcoord.st, vec2(0.5)) * 2.0;
   dist /= Vignette_Distance;

   dist = pow(dist, Vignette_Radius);

   color.rgb *= (1.0f - dist) /Vignette_Strenght;
   }

void main() {
	vec4 color = texture2D(composite, texcoord.st);

  #ifdef GODRAYS
  		vec4 tpos = vec4(sunPosition,1.0)*gbufferProjection;
  		tpos = vec4(tpos.xyz/tpos.w,1.0);
  		vec2 pos1 = tpos.xy/tpos.z;
  		vec2 lightPos = pos1*0.5+0.5;
      float threshold = 0.99 * far;


      #ifdef MOONRAYS

      #else
        if ((worldTime < 14000 || worldTime > 22000) && sunPosition.z < 0)
      #endif

          {
                  vec2 texCoord = texcoord.st;
                  vec2 delta = (texCoord - lightPos) * GR_DENSITY / float(GODRAYS_SAMPLES);
                  float decay = -sunPosition.z / 1000.0;
                  vec3 colorGR = vec3(0.0);
                  for (int i = 0; i < GR_SAMPLES; i++) {
                          texCoord -= delta;
                          if (texCoord.x < 0.0 || texCoord.x > 1.0) {
                                  if (texCoord.y < 0.0 || texCoord.y > 1.0) {
                                          break;
                                  }
                          }
                          vec3 sample = vec3(0.0);
                          if (getDepth(texCoord) > threshold) {
                                  sample = texture2D(gaux1, texCoord).rgb;
                          }
                          sample *= vec3(decay);
                          if (distance(texCoord, lightPos) > 0.05) sample *= 0.2;
                          colorGR += sample* GODRAYS_DITHER;
                          decay *= GR_DECAY;
                  }

  			colorGR.r = colorGR.r, fogColor;
  			colorGR.g = colorGR.g, fogColor;
  			colorGR.b = colorGR.b, fogColor;
                  color = (color + GR_EXPOSURE * vec4(colorGR.r * GODRAYS_COLOR_RED, colorGR.g * 1.12, colorGR.b * 0.50, 0.01)*(TimeSunrise+TimeNoon+TimeSunset)* clamp(1.0 - rainStrength,0.1,1.0));
                  color = (color + GR_EXPOSURE * vec4(colorGR.r * GODRAYS_COLOR_RED, colorGR.g * 1.12, colorGR.b * 0.50, 0.01)*TimeMidnight* clamp(1.0 - rainStrength,0.1,1.0));
          }
  #endif

  #ifdef CRESPECULAR_RAYS
  vec4 tpos = vec4(sunPosition,1.0)*gbufferProjection;
  tpos = vec4(tpos.xyz/tpos.w,1.0);
  vec2 pos1 = tpos.xy/tpos.z;
  vec2 lightPos = pos1*0.5+0.5;


  		vec2 texCoord = texcoord.st;
  	float thresholdc = 0.99 * far;
  //	bool foreground = false;
  	vec2 depth = getDepthCR(texCoord.st);




  		vec2 delta = (texCoord - lightPos) * CR_DENSITY / float(CR_SAMPLES);
  		float decay = -sunPosition.z / 1000.0;
  		vec3 colorCR = vec3(0.0);

  		for (int i = 0; i < CR_SAMPLES; i++)
  		{
  			texCoord -= delta;
        if (texCoord.x < 0.0 || texCoord.x > 1.0) {
                if (texCoord.y < 0.0 || texCoord.y > 1.0) {
                        break;
                }
        }
        vec3 sample = vec3(0.0);
        if (getDepth(texCoord) > thresholdc) {
                sample = texture2D(gaux1, texCoord).rgb;
        }
        sample *= vec3(decay);
        if (distance(texCoord, lightPos) > 0.05) sample *= 0.2;
        colorCR += sample* GODRAYS_DITHER;
        decay *= CR_DECAY;
  		}
      colorCR.r = colorCR.r, fogColor;
      colorCR.g = colorCR.g, fogColor;
      colorCR.b = colorCR.b, fogColor;
                color = (color + CR_EXPOSURE * vec4(colorCR.r * GODRAYS_COLOR_RED, colorCR.g * 1.12, colorCR.b * 0.50, 0.01)*(TimeSunrise+TimeNoon+TimeSunset)* clamp(1.0 - rainStrength,0.1,1.0));
                color = (color + CR_EXPOSURE * vec4(colorCR.r * GODRAYS_COLOR_RED, colorCR.g * 1.12, colorCR.b * 0.50, 0.01)*TimeMidnight* clamp(1.0 - rainStrength,0.1,1.0));
  	

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



color.r = (color.r*COLORCORRECT_RED);
  color.g = (color.g*COLORCORRECT_GREEN);
  color.b = (color.b*COLORCORRECT_BLUE);
color = color / (color + 2.2) * (1.0+2.0);

#ifdef TONEMAPPING
color.rgb = TonemappingType(color.rgb)*GAMMA;
#endif

#ifdef Vignette
VignetteColor(color.rgb);
#endif



gl_FragColor = vec4(color.rgb, 1.0f);

}
