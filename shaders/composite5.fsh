#version 120

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
uniform sampler2D colortex2;
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

vec3 convertSpace(sampler2D dtx, int spc, vec2 texcoord) {
	if(spc == 0) {
		vec3 screenPos = vec3(texcoord, texture2D(dtx, texcoord).r);
		return screenPos;
	} else if(spc == 1) {
		vec3 screenPos = vec3(texcoord, texture2D(dtx, texcoord).r);
		vec3 clipPos = screenPos * 2.0 - 1.0;
		return clipPos;
	} else if(spc == 2) {
		vec3 screenPos = vec3(texcoord, texture2D(dtx, texcoord).r);
		vec3 clipPos = screenPos * 2.0 - 1.0;
		vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
		vec3 viewPos = tmp.xyz / tmp.w;
		return viewPos;
	}
}

void main() {


	vec3 viewPos = convertSpace(depthtex0, 2, texcoord.st);

	//values
	float dst;
	float dns;
	float water;

	//colors
	vec3 color = texture2D(gcolor, texcoord.st).rgb;
	vec4 finalColor;
	vec3 fogColor;

	//block detection
	water =  texture2D(colortex2, texcoord.st).r * 255;


	if(int(water) == 1 ) {
		#ifdef waterFog
			fogColor = vec3(110.0,0.3,1);
			dns = waterFogDensity;
			dst = length( convertSpace(depthtex1, 2, texcoord) - viewPos);
			finalColor = vec4(color * mix(fogColor, vec3(1,1,1), exp(-dst * dns)), 1.0);
		#else
			finalColor = vec4(color, 1.0);
		#endif
	} else {
		finalColor = vec4(color, 1.0);
	}


		int id = int(entityId + 0.5);





		color *= 1111.0;
/* DRAWBUFFERS:0 */



	gl_FragData[0] = finalColor; //gcolor
}
