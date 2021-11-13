#version 120
//deferred.fsh deferred.vsh ssao.glsl dither.glsl by negoros
//CODE BY BSL CAPT TATSU

//#define AmbientOcclusion

varying vec2 texcoord;

uniform int frameCounter;
uniform int isEyeInWater;
uniform int worldTime;

uniform float aspectRatio;
uniform float blindness;
uniform float far;
uniform float frameTimeCounter;
uniform float near;
uniform float nightVision;
uniform float rainStrength;
uniform float shadowFade;
uniform float timeAngle;
uniform float timeBrightness;
uniform float viewWidth;
uniform float viewHeight;

uniform ivec2 eyeBrightnessSmooth;

uniform vec3 cameraPosition;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferModelView;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;
uniform sampler2D noisetex;

float ld(float depth) {
   return (2.0 * near) / (far + near - depth * (far - near));
}

#include "/files/filters/dither.glsl"
#include "/files/shadows/SSAO.glsl"

void main(){
	vec4 color = texture2D(colortex0,texcoord.xy);
	float z = texture2D(depthtex0,texcoord.xy).r;

	//Dither
	float dither = bayer64(gl_FragCoord.xy);

	#ifdef AmbientOcclusion
	color.rgb *= dbao(depthtex0, dither);
	#endif

/*DRAWBUFFERS:04*/
	gl_FragData[0] = color;
	gl_FragData[1] = vec4(z,0.0,0.0,0.0);
}
