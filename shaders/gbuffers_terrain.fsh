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
uniform sampler2D colortex1;
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

#define PuddleStrenght 0.85 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]

#define TerrainGradient
#define GradientStrenght 0.7 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define GradientTerrainStrenght 0.7 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]

//#define MoreLayer

#define LeavesGradient
#define GradientLeavesStrenght 1 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]

//#define GrassGradient
#define GradientGrassStrenght 1 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]

#define GradientColorRed 0.5 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define GradientColorGreen 0.5 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define GradientColorBlue 0.5 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
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
float waterH(vec3 posxz) {

float wave = 10.0;


float factor = 2.0;
float amplitude = 0.2;
float speed = 5.5;
float size = 0.2;

float px = posxz.x/50.0 + 250.0;
float py = posxz.z/50.0  + 250.0;

float fpx = abs(fract(px*20.0)-0.5)*2.0;
float fpy = abs(fract(py*20.0)-0.5)*2.0;

float d = length(vec2(fpx,fpy));

for (int i = 1; i < 4; i++) {
	wave -= d*factor*cos( (1/factor)*px*py*size + 1.0*frameTimeCounter*speed);
	factor /= 2;
}

factor = 1.0;
px = -posxz.x/50.0 + 250.0;
py = -posxz.z/150.0 - 250.0;

fpx = abs(fract(px*20.0)-0.5)*2.0;
fpy = abs(fract(py*20.0)-0.5)*2.0;

d = length(vec2(fpx,fpy));
float wave2 = 0.0;
for (int i = 1; i < 4; i++) {
	wave2 -= d*factor*cos( (1/factor)*px*py*size + 1.0*frameTimeCounter*speed);
	factor /= 2;
}

return amplitude*wave2+amplitude*wave;
}

void main(){
//--------------------------------------------------------------------------------------------------------
float modifiedTime = frameTimeCounter * waveSpeed;
int id = int(BlockId + 0.5);

vec3 posxz = vworldpos.xyz;

posxz.x += sin(posxz.z+frameTimeCounter)*0.25;
posxz.z += cos(posxz.x+frameTimeCounter*0.5)*1.25;

float deltaPos = 0.25;
float h0 = waterH(posxz);
float h1 = waterH(posxz + vec3(deltaPos,0.0,0.0));
float h2 = waterH(posxz + vec3(-deltaPos,0.0,0.0));
float h3 = waterH(posxz + vec3(0.0,0.0,deltaPos));
float h4 = waterH(posxz + vec3(0.0,0.0,-deltaPos));

float xDelta = ((h1-h0)+(h0-h2))/deltaPos;
float yDelta = ((h3-h0)+(h0-h4))/deltaPos;
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
//---------------------------------------------------CAUSIC-------------------------------------------------
float awan = 0.0;
float d = 1.400;
vec4 Clouds = vec4(0.0);
float speed = frameTimeCounter * 0.2;
float CloudMove = speed * 0.127 * pow(d, 0.9);


  vec2 pos = vworldpos.zx*3.1;
for(int i = 0; i < 15; i++) {   //CLOUD SAMPLES
//---------------------------------------------------CAUSIC-------------------------------------------------
awan += fbm(pos) / d;
pos *= 2.040;
d *= 2.064;
pos -= CloudMove+(speed);
}
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

if (id == 10010.0 || id == 10002.0 || id == 10003.0 || id == 10004.0 || id == 10007.0 || id == 10008.0 || id == 10015.0) { //if id = block

#ifdef FakeCloudShadows
if (rainStrength == 0) {
Albedo = puddle_color+colorToAdd;
vec4 colrain = texture2D(colortex0, texcoord.st);
  //  Albedo = mix(puddle_color, colrain, pow(abs(awan), (2.604-(1.0 + rainStrength))));
}

vec4 RainSpecularCol =  texture2D(texture, TexCoords) * Color;
RainSpecularCol.r = 0.2;
RainSpecularCol.g = 0.2;
RainSpecularCol.b = 0.5;
#endif

//----------------------------------------TERRAIN, RAIN -----------------------------------------------------------
//----------------------------------------------NOISE------------------------------------------------------


vec4 cmix;
float OtherFac;
//----------------------------------------PUDDLE---------------------------------------------------------
#ifdef Rain_Puddle

 OtherFac = (1.0 - (pow(PuddleStrenght,Fac))) * (1.0 + rainStrength);

vec4 PuddleColor = texture2D(colortex0, texcoord.st)/22+((xDelta * yDelta*Albedo))+(SpecularAngle*Albedo)*15;

PuddleColor.r +=0.5;
PuddleColor.g +=0.5;
PuddleColor.b +=0.5;


 cmix = mix(Albedo,PuddleColor, OtherFac);
cmix +=SpecularAngle*(xDelta * yDelta*Albedo)*2;

 if (rainStrength == 1) {
Albedo = cmix;
}
#endif
//-------------------------------------------TerrainGradient---------------------------------------------
#ifdef TerrainGradient
 OtherFac = (1.0 - (pow(GradientTerrainStrenght,Fac))) / (1.0 + rainStrength);

vec4 GradientColor = texture2D(colortex0, texcoord.st);

#ifdef UseGradientColor
GradientColor.r = GradientColorRed; GradientColor.g = GradientColorGreen; GradientColor.b = GradientColorBlue;
#endif
cmix = mix(Albedo,GradientColor, OtherFac+0.05);
 if (rainStrength == 0) {
Albedo = cmix;
}

#endif

//-------------------------------------------LeavesGradient---------------------------------------------
#ifdef LeavesGradient
if (id == 10015.0 ){


  GradientColor.r+=1.8;
    GradientColor.g+=0.2;
     OtherFac = (1.0 - (pow(GradientLeavesStrenght,Fac))) * (1.0 + rainStrength);
     OtherFac+=0.07;
  cmix = mix(Albedo,GradientColor, OtherFac);
   if (rainStrength == 0) {
 Albedo = cmix;
}
}
#endif

#ifdef GrassGradient
if (id == 10002.0 ){

  GradientColor.r+=1.8;
    GradientColor.g+=1.2;
     OtherFac = (1.0 - (pow(GradientGrassStrenght,Fac))) * (1.0 + rainStrength);
     OtherFac+=0.025;
  cmix = mix(Albedo,GradientColor, OtherFac);
     if (rainStrength == 0) {
 Albedo = cmix;
}
}
#endif
}
//-------------------------------------------OUTPUT--------------------------------------------





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
