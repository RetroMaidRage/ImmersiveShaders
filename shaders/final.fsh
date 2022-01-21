#version 120
//--------------------------------------------INCLUDE------------------------------------------
#include "/files/tonemaps/tonemap_uncharted.glsl"
#include "/files/tonemaps/tonemap_aces.glsl"
#include "/files/tonemaps/tonemap_reinhard2.glsl"
#include "/files/tonemaps/tonemap_lottes.glsl"

#include "/files/filters/dither.glsl"
#include "/files/filters/noises.glsl"
#include "/files/filters/blur.glsl"

#include "/files/antialiasing/fxaa.glsl"

#include "/files/positions/biomes.glsl"
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
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;
uniform vec3 previousCameraPosition;
uniform vec3 skyColor;
uniform vec3 SkyPos;
uniform float frameTimeCounter;
uniform int isEyeInWater;
uniform mat4 gbufferModelView;

/*
const int colortex0Format = RGBA16F;
const int colortex1Format = RGB16;
const int colortex2Format = RGB16;
*/

//--------------------------------------------DEFINE------------------------------------------
#define TONEMAPPING
#define TonemappingType Uncharted2TonemapOp //[Uncharted2TonemapOp Aces reinhard2 lottes]
#define SUNRAYS

#define SkyRenderingType composite //[colortex0 composite]
#define SUNRAYS_DECAY 0.90 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 ]
#define SUNRAYS_LENGHT 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 ]
#define SUNRAYS_BRIGHTNESS 1.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 2 3 4 5 6 7 8 9 10]
#define SUNRAYS_SAMPLES 64 //[1 2 3 4 5 6 7 8 9 10 11 12 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 48 64 128 256 512 1024]
#define SUNRAYS_COLOR_RED 3.0 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define SUNRAYS_TYPE Godrays //[Godrays Crespecular]
#define SR_Color_Type SunRaysFogColor //[SunRaysCustomColor SunRaysFogColor SunRaysSkyColor]
#define BLOOM
#define BLOOM_AMOUNT 0.00010 ///[0.00018 0.0002 0.0003 0.0004 0.0005 0.0006 0.0007 0.0008 0.0009 0.001]
#define BLOOM_QUALITY 10 //[1 2 3 4 5 6 7 8 9 10 11 12]
#define BLOOM_QUALITY2 -5 //[-1 -2 -3 -4 -5 -6 -7 -8 -9 -10 -11 -12]
#define BLOOM_BLUR FastBlur //[FastBlur QuallityBlur]

#define COLORCORRECT_RED 1.6 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define COLORCORRECT_GREEN 1.4 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define COLORCORRECT_BLUE 1.1 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define GAMMA 1.0 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]

#define CROSSPROCESS
#define ColorSettings Summertime //[Summertime Default]

#define Vignette
#define Vignette_Distance 1.7 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.2142 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define Vignette_Strenght 1.0 ///[0.0 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define Vignette_Radius 3.0 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]

//#define MOTIONBLUR
#define MOTIONBLUR_AMOUNT 2 //[1 2 3 4 5 6 7 8 9 10 11 12]
//#define RadialBlur
//#define Gaussian_Blur
//#define ScreenSpaceRain
#define RainDrops

//#define FilmGrain
#define FilmGrainRain

#define FilmGrainStrenght 20 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 11 12 13 14 15 16 17 18 19 20]

//#define CinematicBorder
#define CinematicBorderIntense 0.05  //[[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]

//#define LensFlare

#define RainDesaturation
#define RainDesaturationFactor 0.3 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9]

//#define Chromation_Abberation
#define ChromaOffset 0.001 ///[0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.2142 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]

//#define FXAA

//#define Sharpening
#define Offset_Strength 0.8 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 11 12 13 14 15 16 17 18 19 20]
#define Sharpening_Amount 0.2 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 11 12 13 14 15 16 17 18 19 20]

//#define WarmEffect

#define UnderWater

#define SnakingCamera

   float getDepth(vec2 coord) {
       return 2.0 * near * far / (far + near - (2.0 * texture2D(depthtex0, coord).x - 1.0) * (far - near));
   }

   float timefract = worldTime;
   float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
   float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
   float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
   float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);

   const float GR_DECAY    = 1.0*SUNRAYS_DECAY;
   const float GR_DENSITY  = 1.0*SUNRAYS_LENGHT;
   const float GR_EXPOSURE = 1.0*SUNRAYS_BRIGHTNESS;
   const int GR_SAMPLES    = 1*SUNRAYS_SAMPLES;

//------------------------------------------------------------------------------------------------------------------
   void VignetteColor(inout vec3 color) {
   float dist = distance(texcoord.st, vec2(0.5)) * 2.0;
   dist /= Vignette_Distance;

   dist = pow(dist, Vignette_Radius);

   color.rgb *= (1.0f - dist) /Vignette_Strenght;
   }
//------------------------------------------------------------------------------------------------------------------
vec2 RainDropCalc(vec2 p) {

    p += simplex2D(p*0.1) * 3.; // distort drops

    float t = frameTimeCounter;

    p *= vec2(.025, .025 * .25);

    p.y += t * .25; // make drops fall

    vec2 rp = round(p);
    vec2 dropPos = p - rp;
    vec2 noise = hash22(rp);

    dropPos.y *= 4.;

    t = t * noise.y + (noise.x*6.28);

    vec2 trailPos = vec2(dropPos.x, fract((dropPos.y-t)*2.) * .5 - .25 );

    dropPos.y += cos( t + cos(t) );  // make speed vary

    float trailMask = clamp(dropPos.y*2.5+.5,0.,1.); // hide trail in front of drop

    float dropSize  = dot(dropPos,dropPos)/3;

    float trailSize = clamp(trailMask*dropPos.y-0.5,0.,1.) + 0.5;
    trailSize = dot(trailPos,trailPos) * trailSize * trailSize;

    float drop  = clamp(dropSize  * -60.+ 3.*noise.y, 0., 1.);
    float trail = clamp(trailSize * -60.+ .5*noise.y, 0., 1.);

    trail *= trailMask; // hide trail in front of drop

    return drop * dropPos + trailPos * trail;
}
//------------------------------------------------------------------------------------------------------------------
vec4 lensFlare(in vec2 coord)
{
  //https://www.shadertoy.com/view/ls3czM
  int uGhosts = 5; // number of ghost samples
float uGhostDispersal = 0.6; // dispersion facto
      vec2 texcoordd = -coord + vec2(1.0);
      vec2 texelSize = vec2(1. / viewWidth, 1. / viewHeight);

   // ghost vector to image centre:
      vec2 ghostVec = (vec2(0.5) - texcoordd) * uGhostDispersal;

   // sample ghosts:
      vec4 result = vec4(0.0);
      for (int i = 0; i < uGhosts; ++i) {
         vec2 offset = fract(texcoordd + ghostVec * float(i));

         float weight = length(vec2(0.5) - offset) / length(vec2(0.5));
         weight = pow(1.0 - weight, 10.0);

vec4 lensflarealbedo = texture(colortex0, offset);

         result += lensflarealbedo * weight; //need noise+blur
      }

    return result;
}


vec2 UnderWaterScreen(vec2 uv){
float Xaxis = uv.x*15 + frameTimeCounter;
float Yaxis = uv.y*15 + frameTimeCounter;
      uv.y += cos(Xaxis+Yaxis) *0.01 * cos(Yaxis);
      uv.x += sin(Xaxis-Yaxis) *0.01 * sin(Yaxis);
      return uv;
}

vec2 snakingCamera(vec2 uv){
float Yaxis = uv.x + frameTimeCounter;
      uv.x += cos(Yaxis) *0.01 * cos(Yaxis);
      return uv;
}

const float SAMPLES = 21.;


// 2x1 hash. Used to jitter the samples.
float hashs( vec2 p ){ return fract(sin(dot(p, vec2(41, 289)))*45758.5453); }


// Light offset.
//
// I realized, after a while, that determining the correct light position doesn't help, since
// radial blur doesn't really look right unless its focus point is within the screen boundaries,
// whereas the light is often out of frame. Therefore, I decided to go for something that at
// least gives the feel of following the light. In this case, I normalized the light position
// and rotated it in unison with the camera rotation. Hacky, for sure, but who's checking? :)
vec3 lOff(){

    vec2 u = sin(vec2(1.57, 0) - frameTimeCounter/2.);
    mat2 a = mat2(u, -u.y, u.x);

    vec3 l = normalize(vec3(1.5, 1., -0.5));
    l.xz = a * l.xz;
    l.xy = a * l.xy;

    return l;

}
vec3 applyFog2( in vec3  rgb,      // original color of the pixel
               in float distance, // camera to point distance
               in vec3  rayDir,
							 							 in float coeff,   // camera to point vector
               in vec3  sunDir )  // sun light direction
{
    float fogAmount = 1.0 - exp( -distance*coeff );
    float sunAmount = max( dot( rayDir, sunDir ), 0.0 );
    vec3  fogColor  = mix( vec3(0.5,0.6,1.7), // bluish
                           vec3(1.0,0.9,0.7), // yellowish
                           pow(sunAmount,1.0) );
    return mix( rgb, fogColor, fogAmount );
}
//--------------------------------------------MAIN------------------------------------------------------
float H2 (in vec2 st) {
    return fract(sin(dot(st,vec2(12.9898,8.233))) * 43758.5453123);
}

vec3 lensflarer(vec2 uv,vec2 pos)
{
	vec2 main = uv-pos;
	vec2 uvd = uv*(length(uv));

	float ang = atan(main.y, main.x);
	float dist=length(main); dist = pow(dist,.1);


	float f0 = 1.0/(length(uv-pos)*16.0+1.0);



	float f2 = max(1.0/(1.0+32.0*pow(length(uvd+0.8*pos),2.0)),.0)*00.25;
	float f22 = max(1.0/(1.0+32.0*pow(length(uvd+0.85*pos),2.0)),.0)*00.23;
	float f23 = max(1.0/(1.0+32.0*pow(length(uvd+0.9*pos),2.0)),.0)*00.21;

	vec2 uvx = mix(uv,uvd,-0.5);

	float f4 = max(0.01-pow(length(uvx+0.4*pos),2.4),.0)*6.0;
	float f42 = max(0.01-pow(length(uvx+0.45*pos),2.4),.0)*5.0;
	float f43 = max(0.01-pow(length(uvx+0.5*pos),2.4),.0)*3.0;

	uvx = mix(uv,uvd,-.4);

	float f5 = max(0.01-pow(length(uvx+0.2*pos),5.5),.0)*2.0;
	float f52 = max(0.01-pow(length(uvx+0.4*pos),5.5),.0)*2.0;
	float f53 = max(0.01-pow(length(uvx+0.6*pos),5.5),.0)*2.0;

	uvx = mix(uv,uvd,-0.5);

	float f6 = max(0.01-pow(length(uvx-0.3*pos),1.6),.0)*6.0;
	float f62 = max(0.01-pow(length(uvx-0.325*pos),1.6),.0)*3.0;
	float f63 = max(0.01-pow(length(uvx-0.35*pos),1.6),.0)*5.0;

	vec3 c = vec3(.0);

	c.r+=f2+f4+f5+f6; c.g+=f22+f42+f52+f62; c.b+=f23+f43+f53+f63;
	c+=vec3(f0);

	return c;
}

void main() {
    //vec2 uv = gl_FragCoord.xy / vec2(viewWidth, viewHeight -0.5);
vec3 SunPosNormal = normalize(sunPosition);

vec2 SunPosNormalVec2 = normalize(sunPosition.xy);

        vec2 GetSreenRes = vec2(viewWidth, viewHeight);

vec4 tpos = vec4(sunPosition,1.0)*gbufferProjection;
tpos = vec4(tpos.xyz/tpos.w,1.0);
vec2 LightPos = tpos.xy/tpos.z;


	vec4 color = texture2D(colortex0, texcoord.st);

  vec3 screenPos = vec3(texcoord.st, texture2D(depthtex0, texcoord.st).r);
  vec3 clipPos = screenPos * 2.0 - 1.0;
  vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
  vec3 viewPos = tmp.xyz / tmp.w;
  vec4 world_position = gbufferModelViewInverse * vec4(viewPos, 1.0);

//---------------------------------------------FUNCTIONS------------------------------------------------
#ifdef FXAA
color = ApplyFXAA(colortex0,texSize, uv);
#endif

#ifdef Sharpening

vec3 blur = color.rgb;
blur += texture(colortex0, uv + vec2(0.0, 0.001 * Offset_Strength)).rgb;
blur += texture(colortex0, uv + vec2(0.001 * Offset_Strength, 0.0)).rgb;
blur += texture(colortex0, uv - vec2(0.0, 0.001 * Offset_Strength)).rgb;
blur += texture(colortex0, uv - vec2(0.001 * Offset_Strength, 0.0)).rgb;

blur += texture(colortex0, uv + vec2(0.001 * Offset_Strength)).rgb / 2.0;
blur += texture(colortex0, uv - vec2(0.001 * Offset_Strength)).rgb / 2.0;
blur += texture(colortex0, uv + vec2(0.001 * Offset_Strength, -0.001 * Offset_Strength)).rgb / 2.0;
blur += texture(colortex0, uv + vec2(-0.001 * Offset_Strength, 0.001 * Offset_Strength)).rgb / 2.0;

blur /= 7.0;

float sharpness = (color.rgb - blur).r * Sharpening_Amount;

color.rgb += sharpness;

 #endif
//------------------------------------------------------------------------------------------------------
#ifdef Chromation_Abberation
color.r = texture(colortex0, uv - ChromaOffset).r;
  color.g = texture(colortex0, uv).g;
    color.b = texture(colortex0, uv + ChromaOffset).b;
    #endif
//------------------------------------------------------------------------------------------------------

//fast
  float Pi = 6.28318530718; // Pi*2

      // GAUSSIAN BLUR SETTINGS {{{
      float Directions = 16.0; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
      float Quality = 3.0; // BLUR QUALITY (Default 4.0 - More is better but slower)
      float size = 8.0; // BLUR SIZE (Radius)
      // GAUSSIAN BLUR SETTINGS }}}


      vec2 Radius = size / vec2(viewWidth, viewHeight);

        vec4 BlurGaussianFast = texture(composite, uv);

  for( float d=0.0; d<Pi; d+=Pi/Directions)
  {
  for(float i=1.0/Quality; i<=1.0; i+=1.0/Quality)
    {
  BlurGaussianFast += texture( composite, uv+vec2(cos(d),sin(d))*Radius*i);
    #ifdef Gaussian_Blur
  color = BlurGaussianFast;
  #endif
    }
  }

  //declare stuff
    const int mSize = 11;
    const int kSize = (mSize-1)/2;
    float kernel[mSize];
    vec3 BlurGaussianQuallity = vec3(0.0);

    //create the 1-D kernel
    float sigma = 7.0;
    float Z = 0.0;
    for (int j = 0; j <= kSize; ++j)
    {
      kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
    }

    //get the normalization factor (as the gaussian has been clamped)
    for (int j = 0; j < mSize; ++j)
    {
      Z += kernel[j];
    }

    //read out the texels
    for (int i=-kSize; i <= kSize; ++i)
    {
      for (int j=-kSize; j <= kSize; ++j)
      {

        BlurGaussianQuallity += kernel[kSize+j]*kernel[kSize+i]*texture(colortex0, (gl_FragCoord.xy+vec2(float(i),float(j))) / GetSreenRes).rgb;

      }}
//------------------------------------------------------------------------------------------------------------------
#ifdef RadialBlur
const int nsamples = 10;
  //vec2 center = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
 float blurStart = 1.0;
   float blurWidth = 0.1;

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
//------------------------------------------------------------------------------------------------------------------
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

			color += texture2D(colortex0, coord);
			++samples;
		}
			color = (color/1.0)/samples;
		}

#endif
//------------------------------------------------------------------------------------------------------------------
  #ifdef SUNRAYS



  		vec2 Godrays = LightPos*0.5+0.5;
      float threshold = 0.99 * far;
vec2 tc = texcoord.st;
vec2 delta = (tc - SUNRAYS_TYPE) * GR_DENSITY / float(SUNRAYS_SAMPLES);
float decay = -sunPosition.z / 1000.0;

float dither = bayer256(tc);

        if ((worldTime < 14000 || worldTime > 22000) && sunPosition.z < 0)

          {





vec3 colorGR = vec3(0.0);
float sample;

for (int i = 0; i < GR_SAMPLES; i++) {

tc -= delta;
if (getDepth(tc) > threshold) {

sample = texture2D(colortex0, tc).x;

}
sample *= vec3(decay).x;

if (distance(tc, SUNRAYS_TYPE) > 0.05) sample *= 0.2;
colorGR += sample;
  decay *= GR_DECAY;
                  }

  			colorGR.r = colorGR.r, fogColor;
  			colorGR.g = colorGR.g, fogColor;
  			colorGR.b = colorGR.b, fogColor;

                vec4  SunRaysCustomColor = (color + GR_EXPOSURE * vec4(colorGR.r * SUNRAYS_COLOR_RED, colorGR.g * 1.12, colorGR.b * 0.50, 0.01)*(TimeSunrise+TimeNoon+TimeSunset)* clamp(1.0 - rainStrength,0.1,1.0));
                //  color = (color + GR_EXPOSURE * vec4(colorGR.r * SUNRAYS_COLOR_RED, colorGR.g * 1.12, colorGR.b * 0.50, 0.01)*TimeMidnight* clamp(1.0 - rainStrength,0.1,1.0));
                vec4 SunRaysFogColor = (color + GR_EXPOSURE * vec4(colorGR.r * fogColor.r*2, colorGR.g * fogColor.g, colorGR.b *fogColor.b, 0.01));
                  vec4 SunRaysSkyColor = (color + GR_EXPOSURE * vec4(colorGR.r * skyColor.r, colorGR.g * skyColor.g, colorGR.b *skyColor.b, 0.01));
                color = SR_Color_Type;
          }
  #endif
  //------------------------------------------------------------------------------------------------------------------
  #ifdef ScreenSpaceRain
  if (rainStrength == 1.0){
  	vec3 raintex = texture(noisetex,vec2(uv.x*2.0,uv.y*0.1+frameTimeCounter*0.085)).rgb/2.0;
  	vec2 where = (uv.xy-raintex.xy);
  	vec3 texchur1 = texture(colortex0,vec2(where.x,where.y)).rgb/2;
    color.rgb +=texchur1;
    color /=1.2;
  }
  #endif
  //------------------------------------------------------------------------------------------------------------------
  #ifdef RainDrops
  uv += RainDropCalc(gl_FragCoord.xy);
  if (rainStrength == 1.0){
color += texture2D(colortex0, uv);
    color /= 3;
  }
  #endif
//------------------------------------------------------------------------------------------------------------------
  #ifdef BLOOM
  	int j;
  	int ii;
  	vec4 sum = vec4(0);
          float gaux5 = 0;
      for( ii= -BLOOM_QUALITY2 ;ii < BLOOM_QUALITY; ii++) {
          for (j = -BLOOM_QUALITY2; j < BLOOM_QUALITY; j++) {
              vec2 coord = texcoord.st + vec2(j,ii) * 0.0001;
                  if(coord.y > 0 && coord.y < 1 && coord.y > 0 && coord.y < 1){

          vec4  QuallityBlur = vec4(BlurGaussianQuallity, 1.0);
          vec4  FastBlur = BlurGaussianFast;
                      sum += texture2D(colortex0, coord) +BLOOM_BLUR;
                      gaux5 += 1;
                  }
              }
      }
      sum = sum / vec4(gaux5);

     if (rainStrength == 0) {
  		color += sum*sum*BLOOM_AMOUNT;
    }
  #endif
//------------------------------------------------------------------------------------------------------------------
#ifdef CROSSPROCESS
  color.r = (color.r*COLORCORRECT_RED);
    color.g = (color.g*COLORCORRECT_GREEN);
    color.b = (color.b*COLORCORRECT_BLUE);

  color = color / (color + 2.2) * (1.0+2.0);
#endif
//------------------------------------------------------------------------------------------------------------------
#ifdef TONEMAPPING
color.rgb = TonemappingType(color.rgb);
#endif
//------------------------------------------------------------------------------------------------------------------
#ifdef Vignette
VignetteColor(color.rgb);
#endif
//------------------------------------------------------------------------------------------------------------------

float invLum = clamp(1.0 - dot(vec3(0.299,0.587,0.114), color.rgb), 0.0, 1.0);
float seed = (uv.x + .0) * (uv.y + 4.0) * (mod(frameTimeCounter,10.0) + 12342.876);
float grainR = fract((mod(seed, 13.0) + 1.0) * (mod(seed, 127.0) + 1.0)) - 0.5;
float grainG = fract((mod(seed, 15.0) + 1.0) * (mod(seed, 109.0) + 1.0)) - 0.5;
float grainB = fract((mod(seed,  7.0) + 1.0) * (mod(seed, 113.0) + 1.0)) - 0.5;
vec3 grain = vec3(grainR, grainG, grainB);
#ifdef FilmGrainRain
  if (rainStrength == 1.0){
       color.rgb += grain/FilmGrainStrenght;
     }
     #endif
     #ifdef FilmGrain
        color.rgb += grain/FilmGrainStrenght;
 #endif
//------------------------------------------------------------------------------------------------------------------
#ifdef CinematicBorder
float transparent = 10.0;
vec4 BackColor = vec4(0.0);

	if (texcoord.t > 0.925) BackColor.rgba = vec4(-CinematicBorderIntense,-CinematicBorderIntense,-CinematicBorderIntense,transparent);

	if (texcoord.t < 0.075) BackColor.rgba = vec4(-CinematicBorderIntense,-CinematicBorderIntense,-CinematicBorderIntense,transparent);

color +=BackColor;
#endif
//------------------------------------------------------------------------------------------------------------------
#ifdef LensFlare

 if (isEyeInWater > 0.9) {

 	} else {
 color += lensFlare(uv) * 1.0;
}
#endif
//------------------------------------------------------------------------------------------------------------------
#ifdef RainDesaturation
float Fac = 0.0;
if (rainStrength == 1){
     Fac = RainDesaturationFactor;

}
vec3 gray = vec3( dot( color.rgb , vec3( 0.2126 , 0.7152 , 0.0722 )));
color = vec4( mix( color.rgb , gray , Fac) , 1.0 );
#endif
//-----------------------------------------------------OUTPUT------------------------------------------------------

#ifdef WarmEffect
if (isBiomeDesert == 1){
  vec2 fake_refract = vec2(sin(frameTimeCounter + texcoord.x*100.0 + texcoord.y*50.0),cos(frameTimeCounter + texcoord.y*100.0 + texcoord.x*50.0));
	 	 color += texture2D(colortex0, texcoord.st+ fake_refract * 0.002);
     	 	 color /=1.35;
}
#endif

#ifdef UnderWater

   uv = UnderWaterScreen(texcoord.st);
   if (isEyeInWater > 0.9) {
color += texture2D(colortex0, uv);
color /= 2.5;
}
#endif

vec2 uvv = gl_FragCoord.xy / GetSreenRes.xy - 0.5;
uvv.x *= GetSreenRes.x/GetSreenRes.y; //fix aspect ratio
vec4 ccccc = texture2D(colortex0, texcoord.st);
//color.rgb+=lensflarer(uvv,LightPos);
gl_FragColor = color;

}
