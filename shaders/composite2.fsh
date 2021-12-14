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
varying vec2 texcoord;
varying vec2 TexCoords;
uniform vec3 shadowLightPosition;
uniform sampler2D colortex1;
uniform vec3 upPosition;
const int noiseTextureResolution = 1;  // Clouds Resolution [512 1024 2048 4096 8192]

/*
const int colortex0Format = RGBA16F;
const int colortex1Format = RGB16;
const int colortex2Format = RGB16;
*/


//--------------------------------------------DEFINE------------------------------------------
#define CloudySky

void main() {

    vec4 color = texture2D(gcolor, texcoord);

#ifdef CloudySky

    vec3 screenPos = vec3(texcoord, texture2D(depthtex0, texcoord).r);
    vec3 clipPos = screenPos * 2.0 - 1.0;
    vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
    vec3 viewPos = tmp.xyz / tmp.w;
    vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
    vec3 feetPlayerPos = eyePlayerPos + gbufferModelViewInverse[3].xyz;
    vec3 worldPos = feetPlayerPos + cameraPosition;

    vec3 Clouds = vec3(0.0);
    vec3 FinalDirection = vec3(0.0);

    if(texture2D(depthtex0, texcoord).r == 1.0) {


    FinalDirection = worldPos.xyz / worldPos.y;
    FinalDirection.y *= 800.0;
    FinalDirection.xz /= vec2(140.0);






float cloudNoise = texture2D(noisetex, FinalDirection.xy/2).r+ interleavedGradientNoise();;
float cloudNoise2pt = texture2D(noisetex, FinalDirection.xz/4).r+ interleavedGradientNoise();;
float cloudNoise3pt = texture2D(noisetex, FinalDirection.xz/6).r+ interleavedGradientNoise();;

float cloudNoise2 = texture2D(noisetex, FinalDirection.xy/10).r;
float cloudNoise2pt2 = texture2D(noisetex, FinalDirection.xz/5).r;
float cloudNoise3pt2 = texture2D(noisetex, FinalDirection.xz).r;

float cloudPreFinalnoise = float(mix(cloudNoise, cloudNoise2pt, cloudNoise3pt));
float cloudPreFinalnoise2 = float(mix(cloudNoise2, cloudNoise2pt2, cloudNoise3pt2));

float cloudFinalNoise = float(mix(cloudPreFinalnoise, cloudNoise2pt, cloudNoise3pt));
float cloudFinalNoise2 = float(mix(cloudFinalNoise, cloudPreFinalnoise2, cloudPreFinalnoise));


    vec4 cloudColor = texture2D(gaux3, vec2(0.5));

		color.r = (color.r*2);
			color.g = (color.g*3);
			color.b = (color.b*5);

  color = color / (color + 40.2) * (1.0+2.0);
    Clouds = mix(color.rgb, cloudColor.rgb, cloudFinalNoise2);
color = color + vec4(Clouds, 1.0);

}

#endif
/* DRAWBUFFERS:0 */
    gl_FragData[0] = color;
}
