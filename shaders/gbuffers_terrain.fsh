#version 120
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
#define specularTerrainStrenght 2
#define FakeCaustic
#define FakeCloudShadows
#define Rain_Puddle
#define waveStrength 0.02;
//----------------------------------------------------CONST----------------------------------------------

   float frequency = 30.0;
   float waveSpeed = 5.0;
   float sunlightStrength = 2.0;

void main(){
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
      float SpecularAngleRain = pow(max(dot(halfDir, Normal), 0.0), 2);
   vec4 SpecularTexture = vec4(1.0, 1.0, 1.0,1.0);
//----------------------------------------------------PUDDLE----------------------------------------------

     float distance = length(vpos)-length(vworldpos)/22;

     float addend = (sin(frequency*distance-modifiedTime)+1.0) * waveStrength;
     float addendWater = (sin(frequency*distance-modifiedTime)+1.0) * waveStrength;
     float addendRain = (sin(frequency*distance)+1.0) * waveStrength;

     vec4 colorToAdd = texture2D(colortex0, texcoord.st)* Color * sunlightStrength * addend;
     vec4 colorToAddWater = texture2D(colortex0, texcoord.st)* Color * sunlightStrength * addendWater;
     vec4 colorToAddRain = texture2D(colortex0, texcoord.st)* Color * sunlightStrength * addendRain;

  vec4 puddle_color = texture2D(colortex0, texcoord.st)* Color;

//----------------------------------------------------OUTPUT----------------------------------------------
    vec4 Albedo = texture2D(texture, TexCoords) * Color;


      if (id == 10010.0 || id == 10002.0 || id == 10003.0 || id == 10004.0 || id == 10007.0 || id == 10008.0) {
        #ifdef FakeCloudShadows
   if (rainStrength == 0) {
       Albedo = puddle_color+colorToAdd;
     }
        vec4 RainSpecularCol =  texture2D(texture, TexCoords) * Color;
        RainSpecularCol.r = 0.2;
        RainSpecularCol.g = 0.2;
        RainSpecularCol.b = 0.5;
        #endif

        #ifdef Rain_Puddle
               if (rainStrength == 1) {
                   Albedo = puddle_color+colorToAddRain*2;
#endif


        }
        #ifdef FakeCaustic
          if (isEyeInWater == 1.0){


              Albedo = puddle_color+(colorToAddWater*5);
          }
          #endif
      }
      if (id == 10008.0) {

        Albedo += (SpecularAngle*Albedo)*specularTerrainStrenght;
      }



    /* DRAWBUFFERS:012 */
    gl_FragData[0] = Albedo;
    gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
    gl_FragData[2] = vec4(LightmapCoords, 0.0f, 1.0f);
}
