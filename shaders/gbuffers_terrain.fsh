#version 120

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

float waveStrength = 0.02;
   float frequency = 30.0;
   float waveSpeed = 5.0;
   vec4 sunlightColor = vec4(1.0,0.91,0.75, 1.0);
   float sunlightStrength = 15.0;

   vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * SkyPos;
   vec3 feetPlayerPos = eyePlayerPos + gbufferModelViewInverse[3].xyz;

   vec3 V = mat3(gbufferModelViewInverse) * SkyPos;

void main(){

//  vec2 tapPoint = vec2(iMouse.x/iResolution.x,iMouse.y/iResolution.y);
 	vec2 uv = gl_FragCoord.xy / vec2(viewWidth, viewHeight);
     float modifiedTime = frameTimeCounter * waveSpeed;
     float aspectRatio = viewWidth/viewHeight;
     vec2 distVec = uv;
     distVec.x *= aspectRatio;
     vec2 uvv;
     uvv -= uv;
     float distance = length(distVec)-length(uvv);


     float multiplier = (distance < 1.0) ? ((distance-1.0)*(distance-1.0)) : 0.0;
     float addend = (sin(frequency*distance-modifiedTime)+1.0) * waveStrength;


     vec4 colorToAdd = texture2D(colortex0, texcoord.st)* Color * sunlightStrength * addend;


  vec4 puddle_color = texture2D(colortex0, texcoord.st)* Color;
  	int id = int(BlockId + 0.5);
    vec4 Albedo = texture2D(texture, TexCoords) * Color;
    /* DRAWBUFFERS:012 */
      if (id == 10010.0) {
    //    if (rainStrength == 1) {
    //    Albedo = puddle_color+colorToAdd;
              //  Albedo += length(texcoord);
      //  }
      }

    gl_FragData[0] = Albedo;
    gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
    gl_FragData[2] = vec4(LightmapCoords, 0.0f, 1.0f);
}
