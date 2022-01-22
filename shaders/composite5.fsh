#version 120

varying vec4 texcoord;
uniform sampler2D gcolor;
uniform sampler2D depthtex0;

uniform vec3 sunPosition;

uniform float worldTime;
uniform float rainStrength;

uniform sampler2D gaux1;
uniform vec3 fogColor;
uniform vec3 shadowLightPosition;

uniform sampler2D noisetex;
uniform sampler2D colortex0;


uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;
uniform vec3 previousCameraPosition;
uniform vec3 skyColor;
uniform float frameTimeCounter;

uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex2;
varying vec2 lmcoord;

varying vec4 glcolor;
uniform sampler2D gnormal;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D depthtex1;
uniform mat4 gbufferProjection;

varying vec2 TexCoords;
varying vec3 viewPos;
varying vec3 normal;
varying vec3 vworldpos;
varying  vec4 fPosition;

vec3 fragpos = vec3(texcoord.st, texture2D(depthtex0, texcoord.st).r);
vec3 nvec3(vec4 pos) {
    return pos.xyz/pos.w;
}

vec4 nvec4(vec3 pos) {
    return vec4(pos.xyz, 1.0);
}


float CalcPuddles(vec3 pos){
//----------------------------------------------------------------------------------------------------
	vec3 screenPos = vec3(texcoord.st, texture2D(depthtex0, texcoord.st).r);
	vec3 clipPos = screenPos * 2.0 - 1.0;
	vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
	vec3 viewPos = tmp.xyz / tmp.w;

	vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
	vec3 feetPlayerPos = eyePlayerPos + gbufferModelViewInverse[3].xyz;
	vec3 worldPos = feetPlayerPos + cameraPosition;

	float depth = texture2D(depthtex0, texcoord.st).r;
	bool isTerrain = depth < 1.0;


	vec3 raincoord;
	  if (isTerrain) raincoord = (worldPos.xyz/20000);

//----------------------------------------------------------------------------------------------------
	float Puddless = texture2D(noisetex, (raincoord.xz*2)).x;
	Puddless += texture2D(noisetex,(raincoord.xz*8)).x;
		Puddless += texture2D(noisetex, (raincoord.xz*4)).x;
	Puddless += texture2D(noisetex, (raincoord.xz/2)).x;

	float Puddles = max((Puddless-2.0),0.0);
	return Puddles;
}

void main() {
		fragpos = nvec3(gbufferProjectionInverse * nvec4(fragpos * 2.0 - 1.0));
	vec3 npos = normalize(fragpos);
	vec3 screenPos = vec3(texcoord.st, texture2D(depthtex0, texcoord.st).r);
	vec3 clipPos = screenPos * 2.0 - 1.0;
	vec4 tmp = gbufferProjectionInverse * vec4(clipPos, 1.0);
	vec3 viewPos = tmp.xyz / tmp.w;

	vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
	vec3 feetPlayerPos = eyePlayerPos + gbufferModelViewInverse[3].xyz;
	vec3 worldPos;


vec4 color = texture2D(colortex0, texcoord.st);
vec4 puddle_color = vec4(0.0, 0.0, 0.8, 0.0);
float puddle =  CalcPuddles(worldPos);

  vec4  Clouds = mix(color, puddle_color, puddle);

/* DRAWBUFFERS:0 */
//	gl_FragData[0] = color; //gcolor
}
