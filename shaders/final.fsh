#version 120
//--------------------------------------------INCLUDE------------------------------------------
#include "/files/tonemaps/tonemap_uncharted.glsl"
#include "/files/tonemaps/tonemap_aces.glsl"
#include "/files/tonemaps/tonemap_reinhard2.glsl"
#include "/files/tonemaps/tonemap_lottes.glsl"
#include "/files/filters/dither.glsl"
//--------------------------------------------UNIFORMS------------------------------------------
varying vec4 texcoord;
uniform sampler2D gcolor;
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
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
uniform float viewWidth;
uniform float viewHeight;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;
uniform vec3 previousCameraPosition;
//--------------------------------------------DEFINE------------------------------------------
#define TONEMAPPING
#define TonemappingType Uncharted2TonemapOp //[Uncharted2TonemapOp Aces reinhard2 lottes]
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

#define MOTIONBLUR
#define MOTIONBLUR_AMOUNT 2

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

   float interleavedGradientNoise() {
       return fract(52.9829189 * fract(0.06711056 * gl_FragCoord.x + 0.00583715 * gl_FragCoord.y + 0.00623715)) * 0.25;
   }

void main() {
	vec4 color = texture2D(SkyRenderingType, texcoord.st);
  #ifdef Gaussian_Blur
  float Pi = 6.28318530718; // Pi*2

      // GAUSSIAN BLUR SETTINGS {{{
      float Directions = 16.0; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
      float Quality = 3.0; // BLUR QUALITY (Default 4.0 - More is better but slower)
      float size = 8.0; // BLUR SIZE (Radius)
      // GAUSSIAN BLUR SETTINGS }}}
  vec2 uv = gl_FragCoord.xy / vec2(viewWidth, viewHeight);

      vec2 Radius = size / vec2(viewWidth, viewHeight);

        vec4 Blur = texture(colortex0, uv);

  for( float d=0.0; d<Pi; d+=Pi/Directions)
  {
  for(float i=1.0/Quality; i<=1.0; i+=1.0/Quality)
    {
  Blur += texture( colortex0, uv+vec2(cos(d),sin(d))*Radius*i);
    }
  }
#endif

#ifdef RadialBlur
const int nsamples = 10;
  //vec2 center = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
 float blurStart = 1.0;
   float blurWidth = 0.1;


  vec2 uv = gl_FragCoord.xy / vec2(viewWidth, viewHeight);

  // uv -= center;
   float precompute = blurWidth * (1.0 / float(nsamples - 1));

   vec4 color3 = vec4(0.0);
   for(int i = 0; i < nsamples; i++)
   {
       float scale = blurStart + (float(i)* precompute);
       color3 += texture(colortex0, uv * scale);
   }


   color3 /= float(nsamples);
#endif

#ifdef MOTIONBLUR

	float depth = texture2D(depthtex1, texcoord.st).x;

	float noblur = texture2D(gaux1, texcoord.st).r;


		if (depth > 0.9999999) {
		depth = 1;
		}




		if (depth < 1.9999999) {
		vec4 currentPosition = vec4(texcoord.x * 2.0 - 1.0, texcoord.y * 2.0 - 1.0, 2.0 * depth - 1.0, 1.0);

		vec4 fragposition = gbufferProjectionInverse * currentPosition;
		fragposition = gbufferModelViewInverse * fragposition;
		fragposition /= fragposition.w;
		fragposition.xyz += cameraPosition;

		vec4 previousPosition = fragposition;
		previousPosition.xyz -= previousCameraPosition;
		previousPosition = gbufferPreviousModelView * previousPosition;
		previousPosition = gbufferPreviousProjection * previousPosition;
		previousPosition /= previousPosition.w;

		vec2 velocity = (currentPosition - previousPosition).st * 0.007 * MOTIONBLUR_AMOUNT;
		velocity = velocity;

		int samples = 1;

		if (noblur > 0.9) {
			velocity = vec2(0,0);
		}


		vec2 coord = texcoord.st + velocity;


		for (int i = 0; i < 8; ++i, coord += velocity) {
			if (coord.s > 1.0 || coord.t > 1.0 || coord.s < 0.0 || coord.t < 0.0) {
				break;
			}


			color += texture2D(composite, coord);
			++samples;

		}
			color = (color/1.0)/samples;
		}



#endif




  #ifdef SUNRAYS
  float phi = 1.618;
    float dither2 = fract(fract(worldTime * (1.0 / phi)) + bayer128(gl_FragCoord.st));
     float jitter = fract(worldTime + interleavedGradientNoise());

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

//if (texCoord.x < 0.0 || texCoord.x > 1.0) {
//if (texCoord.y < 0.0 || texCoord.y > 1.0) { break;
  //              }
    //      }

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
  	int ii;
  	vec4 sum = vec4(0);
          float gaux1 = 0;
      for( ii= -BLOOM_QUALITY2 ;ii < BLOOM_QUALITY; ii++) {
          for (j = -BLOOM_QUALITY2; j < BLOOM_QUALITY; j++) {
              vec2 coord = texcoord.st + vec2(j,ii) * 0.001;
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

vec3 gray = vec3( dot( color.rgb , vec3( 0.2126 , 0.7152 , 0.0722 ) ) );

float desaturationFactor = (rainStrength-0.2);
gl_FragColor = vec4( color.rgb , 1.0 );

}
