#version 120
//----------------------------------------------------INCLUDE----------------------------------------------
#include "/files/filters/noises.glsl"
//----------------------------------------------------UNIFORMS----------------------------------------------
varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;
uniform sampler2D noisetex;
uniform float rainStrength;
uniform sampler2D texture;
varying vec4 texcoord;
in  float BlockId;
uniform sampler2D colortex0;
uniform float frameTimeCounter;
uniform float viewWidth;
uniform float viewHeight;
varying vec3 vworldpos;
varying vec3 SkyPos;
uniform mat4 gbufferModelViewInverse;
uniform vec3 shadowLightPosition;
varying vec3 viewPos;
varying vec4 vpos;
uniform int isEyeInWater;
//----------------------------------------------------DEF----------------------------------------------
#define specularTerrainStrenght 2 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define FakeCaustic
#define FakeCloudShadows

#define Rain_Puddle
#define TerrainGradient
#define PuddleStrenght 0.85 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define GradientStrenght 0.7 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
//#define MoreLayer

#define GradientColorRed 0.5
#define GradientColorGreen 0.5
#define GradientColorBlue 0.5
//#define UseGradientColor

#define waveStrength 0.02; ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
//----------------------------------------------------CONST----------------------------------------------

   float frequency = 30.0;
   float waveSpeed = 5.0;
   float sunlightStrength = 2.0;

   float timeSpeed = 2.0;

//--------------------------------------------------------------------------------------------------------
   float makeWaves(vec2 uv, float theTime, float offset)
   {
       float result = 0.0;
       float direction = 0.0;
       float sineWave = 0.0;
       vec2 randVec = vec2(1.0,0.0);
       float i;
       for(int n = 0; n < 16; n++)
       {
           i = float(n)+offset;
           randVec = randomVec2(float(i));
     		direction = (uv.x*randVec.x+uv.y*randVec.y);
           sineWave = sin(direction*randomVal(i+1.6516)+theTime*timeSpeed);
           sineWave = smoothstep(0.0,1.0,sineWave);
       	result += randomVal(i+123.0)*sineWave;
       }
       return result;
   }
//--------------------------------------------------------------------------------------------------------

void main(){
//--------------------------------------------------------------------------------------------------------
float modifiedTime = frameTimeCounter * waveSpeed;
int id = int(BlockId + 0.5);
//----------------------------------------------------SPECULAR----------------------------------------------
  vec3 ShadowLightPosition = normalize(shadowLightPosition);
  vec3 NormalDir = normalize(Normal);
  vec3 lightDir = normalize(ShadowLightPosition);

  vec3 viewDir = -normalize(viewPos);
  vec3 halfDir = normalize(lightDir + viewDir);
  vec3 reflectDir = reflect(lightDir, viewDir);

  float SpecularAngle = pow(max(dot(halfDir, Normal), 0.0), 50);
  vec4 SpecularTexture = vec4(1.0, 1.0, 1.0,1.0);
//---------------------------------------------------CAUSIC-------------------------------------------------

float distance = length(vpos)-length(vworldpos)/22;

float addend = (sin(10*distance-modifiedTime)+1.0) * waveStrength;
float addendWater = (sin(frequency*distance-modifiedTime)+1.0) * waveStrength;
float addendRain = (sin(frequency*distance)+1.0) * waveStrength;

vec4 colorToAdd = texture2D(colortex0, texcoord.st)* Color * sunlightStrength * addend;
vec4 colorToAddWater = texture2D(colortex0, texcoord.st)* Color * sunlightStrength * addendWater;
vec4 colorToAddRain = texture2D(colortex0, texcoord.st)* Color * sunlightStrength * addendRain;

vec4 puddle_color = texture2D(colortex0, texcoord.st)* Color;

float result;
float result2;

result = makeWaves( vworldpos.xz*10+vec2(frameTimeCounter*2,0.0), frameTimeCounter, 0.1);
result2 = makeWaves(  vworldpos.xz*10-vec2(frameTimeCounter*0.8*2,0.0), frameTimeCounter*0.8+0.06, 0.26);
result = smoothstep(0.4,1.1,1.0-abs(result));
result2 = smoothstep(0.4,1.1,1.0-abs(result2));
result = 2.0*smoothstep(0.35,1.8,(result+result2)*0.5);
//--------------------------------------------------------------------------------------------------------
vec4 Albedo = texture2D(texture, TexCoords) * Color;
//----------------------------------------FakeCloudShadows------------------------------------------------

if (id == 10010.0 || id == 10002.0 || id == 10003.0 || id == 10004.0 || id == 10007.0 || id == 10008.0) { //if id = block

#ifdef FakeCloudShadows
if (rainStrength == 0) {
Albedo = puddle_color+colorToAdd;
}

vec4 RainSpecularCol =  texture2D(texture, TexCoords) * Color;
RainSpecularCol.r = 0.2;
RainSpecularCol.g = 0.2;
RainSpecularCol.b = 0.5;
#endif

//----------------------------------------TERRAIN, RAIN -----------------------------------------------------------
//----------------------------------------------NOISE------------------------------------------------------
vec2 rainCoord = (vworldpos.xz/10000);
float Noise = texture2D(noisetex, fract(rainCoord.xy*8)).x;
Noise += texture2D(noisetex, (rainCoord.xy*4)).x;
Noise += texture2D(noisetex, (rainCoord.xy*2)).x;
Noise += texture2D(noisetex, (rainCoord.xy/2)).x;


#ifdef MoreLayer
Noise += texture2D(noisetex, (rainCoord.xy*6)).x;
Noise += texture2D(noisetex, (rainCoord.xy/4)).x;
Noise += texture2D(noisetex, (rainCoord.xy*8)).x;
#endif
float Fac = max(Noise-2.0,0.0);
vec4 cmix;
float OtherFac;
//--------------------------------------------------------------------------------------------------------
#ifdef Rain_Puddle

 OtherFac = (1.0 - (pow(PuddleStrenght,Fac))) * (1.0 + rainStrength);

vec4 PuddleColor = texture2D(colortex0, texcoord.st)+(SpecularAngle*Albedo)*5;

 cmix = mix(Albedo,PuddleColor, OtherFac);
 if (rainStrength == 1) {
Albedo = cmix;
}
#endif
//--------------------------------------------------------------------------------------------------------
#ifdef TerrainGradient
 OtherFac = (1.0 - (pow(GradientStrenght,Fac))) / (1.0 + rainStrength);

vec4 GradientColor = texture2D(colortex0, texcoord.st);

#ifdef UseGradientColor
GradientColor.r = GradientColorRed; GradientColor.g = GradientColorGreen; GradientColor.b = GradientColorBlue;
#endif

 cmix = mix(Albedo,GradientColor, OtherFac+0.05);
Albedo = cmix;
#endif

}//if id = block
//----------------------------------------SPECULAR--------------------------------------------------------
if (id == 10008.0) {

Albedo += (SpecularAngle*Albedo)*specularTerrainStrenght;
}
#ifdef FakeCaustic
if (isEyeInWater == 1.0){

vec4 ccolor = vec4(0.2, 0.2, 1.0, 1.0)*result;

Albedo = puddle_color+(colorToAddWater*2)+(result/2);

}
#endif
//--------------------------------------------------------------------------------------------------------

    /* DRAWBUFFERS:012 */
    gl_FragData[0] = Albedo;
    gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
    gl_FragData[2] = vec4(LightmapCoords, 0.0f, 1.0f);
}
