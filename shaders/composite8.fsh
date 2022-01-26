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
uniform vec3 sunPosition;
varying vec2 texcoord;
varying vec2 TexCoords;
uniform vec3 shadowLightPosition;
uniform sampler2D colortex1;
uniform mat4 gbufferProjection;
uniform sampler2D gaux1;
uniform vec3 upPosition;
const int noiseTextureResolution = 512;
uniform float rainStrength;
/*
const int colortex0Format = RGBA16F;
const int colortex1Format = RGB16;
const int colortex2Format = RGB16;
*/


//------------------------------------------------------------------------------------------
#define rnd(r) fract(4579.0 * sin(1957.0 * (r)))
#define Cloud
#define CloudQuality 15  //[1 2 3 4 5 6 7 8 9 10 11 12 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 48 64]
#define CloudDestiny 7.604 //[1 2 3 4 5 6 7 8 9 10 11 12 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 48 64 128 256 512 1024]
#define CloudDetaly 2.040; //[1 2 3 4 5 6 7 8 9 10 11 12 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32]
#define CloudPositionY 1.5 //[1 2 3 4 5 6 7 8 9 10 11 12 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32]
#define CloudSpeedNoiseMove 6 //[1 2 3 4 5 6 7 8 9 10 11 12 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32]
#define CloudSpeed 0.015 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define CloudGlobalMove
#define CloudNoiseType noise //[fbm SimplexPerlin2D simplex2D]
#define Stars
#define StarsAlways
#define StarsNum 15	///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4 5 6 7 8 9 10 11 12 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 48 64 128 256 512 1024 ]
#define StarsSize 0.025 ///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define StarsBright 2.0	///[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
//#define UseSkyFix
//------------------------------------------------------------------------------------------
float timefract = worldTime;
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);
//------------------------------------------------------------------------------------------
const float stp = 1.2;			//size of one step for raytracing algorithm
const float ref = 0.1;			//refinement multiplier
const float inc = 2.2;			//increasement factor at each step
const int maxf = 4;				//number of refinements


// Offset the start position.

//--------------------------------------------------------------------------------------------
vec3 nvec3(vec4 pos){
    return pos.xyz/pos.w;
}
//--------------------------------------------------------------------------------------------
vec4 nvec4(vec3 pos){
    return vec4(pos.xyz, 1.0);
}
//--------------------------------------------------------------------------------------------
float cdist(vec2 coord) {
	return max(abs(coord.s-0.5),abs(coord.t-0.5))*2.0;
}
vec4 raytrace(vec3 viewdir, vec3 normal){
  //http://www.minecraftforum.net/forums/mapping-and-modding/minecraft-mods/2381727-shader-pack-datlax-onlywater-only-water
    vec4 color = vec4(0.0);


    vec3 rvector = normalize(reflect(normalize(viewdir), normalize(normal)));
    vec3 vector = stp * rvector;
    vec3 oldpos = viewdir;
    viewdir += vector;
    int sr = 0;

    for(int i = 0; i < 40; i++){
    vec3 pos = nvec3(gbufferProjection * nvec4(viewdir)) * 0.5 + 0.5;

        if(pos.x < 0 || pos.x > 1 || pos.y < 0 || pos.y > 1 || pos.z < 0 || pos.z > 1.0);

        vec3 spos = vec3(pos.st, texture2D(depthtex0, pos.st).r);
        spos = nvec3(gbufferProjectionInverse * nvec4(spos * 2.0 - 1.0));
	    	float err = abs(viewdir.z-spos.z);

		if(err < pow(length(vector)*1.85,1.15) && texture2D(gaux1,pos.st).g < 0.01)
    {      sr++;   if(sr >= maxf){

  float border = clamp(1.0 - pow(cdist(pos.st), 1.0), 0.0, 1.0);
  color = texture2D(gcolor, pos.st);
					float land = texture2D(gaux1, pos.st).g;
					land = float(land < 0.03);
					spos.z = mix(viewdir.z,2000.0*(0.4+1.0*0.6),land);
					color.a = 1.0;
                    color.a *= border;
                    break;
                }
                viewdir = oldpos;
                vector *=ref;
        }
        vector *= inc;
        oldpos = viewdir;
        viewdir += vector;
    }
    return color;
}

//--------------------------------------------MAIN-----------------------------------------
void main() {

//------------------------------------------------------------------------------------------
  float awan = 0.0;

  vec3 FinalDirection = vec3(0.0);


  vec4 color = texture2D(gcolor, texcoord);

//-----------------------------------------------------------------------------------------
vec3 screenPos = vec3(texcoord.st, texture2D(depthtex0, texcoord.st).r);
vec3 clipPos = screenPos * 2.0 - 1.0;
vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
vec3 viewPos = tmp.xyz / tmp.w;
vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
vec3 feetPlayerPos = eyePlayerPos + gbufferModelViewInverse[3].xyz;
vec3 worldPos = feetPlayerPos + cameraPosition;



float depth = texture2D(depthtex0, texcoord.st).r;
bool isTerrain = depth < 1.0;
if (isTerrain)FinalDirection = worldPos;


//-----------------------------------------------------------------------------------------

//-----------------------------------CLOUD_NOISE-------------------------------------------

vec2 pos = FinalDirection.zx;
pos /= 2222;
   awan = texture2D(noisetex, fract(pos*8)).x;
  awan += texture2D(noisetex, (pos*4)).x;
  awan += texture2D(noisetex, (pos*2)).x;
  awan += texture2D(noisetex, (pos/2)).x;



 if (isTerrain)color += awan/22;





//----------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------
/* DRAWBUFFERS:0 */
    //gl_FragData[0] = color;
}
