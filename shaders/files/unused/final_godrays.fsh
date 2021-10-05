#version 120
#include "tonemaps/tonemap_uncharted.glsl"
//#include "tonemaps/tonemap_aces.glsl"
//#include "tonemaps/tonemap_reinhard.glsl"

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

#define GODRAYS
//#define MOONRAYS  //Very buggy!
   #define GODRAYS_DECAY 0.90
   #define GODRAYS_LENGHT 1.0
   #define GODRAYS_BRIGHTNESS 0.2
   #define GODRAYS_SAMPLES 32

   float getDepth(vec2 coord) {
       return 2.0 * near * far / (far + near - (2.0 * texture2D(depthtex0, coord).x - 1.0) * (far - near));
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
   const int GR_SAMPLES    = 1*GODRAYS_SAMPLES;
   #endif


void main() {
	vec4 color = texture2D(composite, texcoord.st);
  #ifdef GODRAYS
  		vec4 tpos = vec4(sunPosition,1.0)*gbufferProjection;
  		tpos = vec4(tpos.xyz/tpos.w,1.0);
  		vec2 pos1 = tpos.xy/tpos.z;
  		vec2 lightPos = pos1*0.5+0.5;
      float threshold = 0.99 * far;
      bool foreground = true;
      float depthGR = getDepth(texcoord.st);

          {
                  vec2 texCoord = texcoord.st;
                  vec2 delta = (texCoord - lightPos) * GR_DENSITY / float(GR_SAMPLES);
                  float decay = -sunPosition.z / 100.0;
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
                                  sample = texture2D(composite, texCoord).rgb;
                          }
                          sample *= vec3(decay);
                          if (distance(texCoord, lightPos) > 0.05) sample *= 0.2;
                          colorGR += sample;
                          decay *= GR_DECAY;
                  }

  			colorGR.r = colorGR.r, 2.0;
  			colorGR.g = colorGR.g, 2.0;
  			colorGR.b = colorGR.b, 2.0;
                  color = (color + GR_EXPOSURE * vec4(colorGR.r * 2.55, colorGR.g * 1.12, colorGR.b * 0.50, 0.01)*(TimeSunrise+TimeNoon+TimeSunset)* clamp(1.0 - rainStrength,0.1,1.0));
                  color = (color + GR_EXPOSURE * vec4(colorGR.r * 2.55, colorGR.g * 1.12, colorGR.b * 0.50, 0.01)*TimeMidnight* clamp(1.0 - rainStrength,0.1,1.0));
          }
  #endif



color.r = (color.r*1.6);
  color.g = (color.g*1.4);
  color.b = (color.b*1.1);
color = color / (color + 2.2) * (1.0+2.0);

//color.rgb = Uncharted2TonemapOp(color);


gl_FragColor = vec4(color.rgb,  1.0f);

}
