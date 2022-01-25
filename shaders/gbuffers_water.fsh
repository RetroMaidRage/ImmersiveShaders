#version 120
#include "/files/filters/noises.glsl"
#include "/files/filters/blur.glsl"
//--------------------------------------------UNIFORMS------------------------------------------
varying vec4 texcoord;
uniform sampler2D gcolor;
uniform sampler2D depthtex0;

uniform vec3 sunPosition;

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

uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;
uniform vec3 previousCameraPosition;
uniform vec3 skyColor;
uniform float frameTimeCounter;
uniform int isEyeInWater;

uniform sampler2D lightmap;
uniform sampler2D texture;
uniform sampler2D colortex1;
uniform sampler2D depthtex2;
varying vec2 lmcoord;
in  float entityId;
varying vec4 glcolor;
uniform sampler2D gnormal;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D depthtex1;
uniform mat4 gbufferProjection;
uniform sampler2D composite;
varying vec2 TexCoords;
varying vec3 viewPos;
varying vec3 normal;
varying vec3 Normal;
varying vec3 vworldpos;
varying vec3 binormal;
varying vec3 tangent;
varying vec3 viewVector;
varying float iswater;
//--------------------------------------------DEFINE------------------------------------------
#define WaterType Custom //[Custom Texture]
#define WaterTransparent 2.0  //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5]
#define WaterBumpStrenght 0.25 ///[0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.2142 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 ]
#define FrenselTexture Frensel //[FrenselUseTexture]
#define FrensStrenght 0.015   //[[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
//#define SpecularWaterIceGlass
//#define SpecularTexture SpecularCustom //[SpecularCustom SpecularUseTexture]
//#define specularDistance 50 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 11 12 13 14 15 16 17 18 19 20]
//#define specularTextureStrenght 0.7 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 11 12 13 14 15 16 17 18 19 20]
//#define SpecularCustomStrenght 1 //[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 11 12 13 14 15 16 17 18 19 20]
//---------------------------------------------------------------------------------------------------------------------------
float timeSpeed = 2.0;
float     GetDepthLinear(in vec2 coord) {
   return 2.0f * near * far / (far + near - (2.0f * texture2D(depthtex0, coord).x - 1.0f) * (far - near));
}

float linearDepth(float depth){
	return 2.0 * (near * far) / (far + near - (depth) * (far - near));
}

//---------------------------------------------------------------------------------------------------------------------------
float PI = 3.14;

float rainx = clamp(rainStrength, 0.0f, 1.0f)/1.0f;

vec2 dx = dFdx(texcoord.xy);
vec2 dy = dFdy(texcoord.xy);


//---------------------------------------------------------------------------------------------------------------------------
float waterH(vec3 posxz) {

float wave = 10.0;


float factor = 2.0;
float amplitude = 0.2;
float speed = 4.0;
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




//---------------------------------------------------------------------------------------------------------------------------
void main() {
	int id = int(entityId + 0.5);

vec4 color = texture2D(texture, texcoord.st);
vec4 Frensel =  vec4(1.0,1.0,1.0,1.0);
vec4 FrenselUseTexture = texture2D(texture, texcoord.st);

vec4 fresnelColor =  FrenselTexture;
vec4 Texture = color;
vec4 Custom = vec4(0.87);

	vec4 cwater = vec4(WaterTransparent)*glcolor*WaterType;
	cwater.r = (cwater.r*1);
	  cwater.g = (cwater.g*1);
	 // cwater.b = (cwater.b*0.6);
	cwater = cwater / (cwater + 6.2) * (1.0+2.0);

//--------------------------------------------------------------------------------------
float fog = length(viewPos.xz)/5;
float frensel =  exp(-fog * FrensStrenght);
vec2 GetSreenRes = vec2(viewWidth, viewHeight);

vec3 ShadowLightPosition = normalize(shadowLightPosition);
vec3 Normal = normalize(normal);
vec3 lightDir = normalize(ShadowLightPosition);

vec3 viewDir = -normalize(viewPos);
vec3 halfDir = normalize(lightDir + viewDir);
vec3 reflectDir = reflect(lightDir, viewDir);
//---------------------------------------------------------------------------------------------------------------------------
vec3 posxz = vworldpos.xyz;

posxz.x += sin(posxz.z+frameTimeCounter)*0.25;
posxz.z += cos(posxz.x+frameTimeCounter*0.5)*1.25;

float deltaPos = 0.8;
float h0 = waterH(posxz);
float h1 = waterH(posxz + vec3(deltaPos,0.0,0.0));
float h2 = waterH(posxz + vec3(-deltaPos,0.0,0.0));
float h3 = waterH(posxz + vec3(0.0,0.0,deltaPos));
float h4 = waterH(posxz + vec3(0.0,0.0,-deltaPos));

float xDelta = ((h1-h0)+(h0-h2))/deltaPos;
float yDelta = ((h3-h0)+(h0-h4))/deltaPos;

    vec3 newnormal = normalize(vec3(xDelta,yDelta,1.0-xDelta*xDelta-yDelta*yDelta));
//---------------------------------------------------------------------------------------------------------------------------
    vec4 frag2;
      frag2 = vec4((normal) * 0.5f + 0.5f, 1.0f);


      vec3 bump = newnormal;
        bump = bump;


      float bumpmult = WaterBumpStrenght;

      bump = bump * vec3(bumpmult, bumpmult, bumpmult) + vec3(0.0f, 0.0f, 1.0f - bumpmult);
      mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
                tangent.y, binormal.y, normal.y,
                tangent.z, binormal.z, normal.z);

      frag2 = vec4(normalize(bump * tbnMatrix) * 0.5 + 0.5, 1.0);

//---------------------------------------------------------------------------------------------------------------------------



    vec4 outputWater = mix(fresnelColor, cwater, frensel);
      vec4 outputIce = mix(fresnelColor, color, frensel);
	vec4 w = vec4(0.1, 0.2, 0.3, 0.87);
	vec4 w2 = vec4(1.0);
/* DRAWBUFFERS:0576 */
//0 - цвет, 5 - нормали, 7 - нахождение воды, 6 - цвет
if (id == 10006) {
  gl_FragData[0] = outputIce*outputIce;
}
if (id == 10001) {
gl_FragData[0] = outputWater; //gcolor
gl_FragData[1] = frag2;
// gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
gl_FragData[2] = vec4(10.0f);
gl_FragData[3] =outputWater;
}
if (id == 10014) {
gl_FragData[0] = outputIce*outputIce; //gcolor
}}
