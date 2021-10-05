#version 120
#extension GL_EXT_gpu_shader4 : enable
#define FXAA_GLSL_120 1
#include "tonemaps/tonemap_uncharted.glsl"
//#include "tonemaps/tonemap_aces.glsl"
//#include "tonemaps/tonemap_reinhard.glsl"
#define VIGNETTECOLOR
#ifdef VIGNETTECOLOR
#include "tonemaps/vignette.glsl"
#endif
varying vec4 texcoord;

uniform sampler2D gcolor;



void main() {

vec3 color = texture2D(gcolor, texcoord.st).rgb;

color.r = (color.r*1.6);
  color.g = (color.g*1.4);
  color.b = (color.b*1.1);
color = color / (color + 2.2) * (1.0+2.0);

color.rgb = Uncharted2TonemapOp(color);

vec3 color2 = vec3(0.0, 0.0, 0.0);

vec3 customColor = color + color2;
#ifdef VIGNETTECOLOR
#endif

gl_FragColor = vec4(customColor.rgb,  1.0f);

}
