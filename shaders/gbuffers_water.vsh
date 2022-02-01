#version 120

//--------------------------------------------UNIFORMS------------------------------------------
attribute vec2 mc_midTexCoord;
varying vec3 vworldpos;
uniform float frameTimeCounter;
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glColor;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;
varying vec4 glcolor;
attribute vec3 mc_Entity;
out float entityId;
varying vec3 viewPos;
varying vec3 worldPos;
varying vec3 normal;
varying vec3 binormal;
varying vec3 tangent;
varying vec3 viewVector;
varying vec3 wpos;
varying float iswater;
//--------------------------------------------DEFINE------------------------------------------
#define waves
#define waves_strenght 0.085 ///[0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1]
#define WaveMultiplyVertex
#define BLOCK_WAVE
const float pi = 3.14f;
const float PI = 3.14f;
float tick = frameTimeCounter;
//---------------------------------------------------------------------------------------------------------------------------
void main() {
	iswater = 0.0f;
	float displacement = 0.0;


	vec3 eyePlayerPos = mat3(gbufferModelViewInverse) * viewPos;
	vec3 feetPlayerPos = eyePlayerPos + gbufferModelViewInverse[3].xyz;
	worldPos = eyePlayerPos + cameraPosition;
	viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	entityId = mc_Entity.x;
	int blockId = int(entityId);
	glcolor = gl_Color;
texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	vec4 position = gl_ModelViewMatrix * gl_Vertex;
  vec4 vpos = gbufferModelViewInverse*position;
  vworldpos = vpos.xyz + cameraPosition;
	normal = gl_NormalMatrix * gl_Normal;
	wpos = vworldpos;
//---------------------------------------------------------------------------------------------------------------------------
  #ifdef waves

	vec3 posxz2 = vworldpos.xyz;
	posxz2.x += sin(posxz2.z+frameTimeCounter)*0.2;
	posxz2.z += cos(posxz2.x+frameTimeCounter*0.5)*0.2;

	float wave = 0.05 * sin(2 * 3.14 * (frameTimeCounter + posxz2.x  + posxz2.z / 2.0))
						+ 0.05 * sin(2 * 3.14 * (frameTimeCounter*1.2 + posxz2.x / 2.0 + posxz2.z ));

	vec3 newnormal2 = vec3(sin(wave*3.14),1.0-cos(wave*3.14),wave);
//---------------------------------------------------------------------------------------------------------------------------
	vec3 posxz3 = vworldpos.xyz;


	float oceannoise = sin((posxz3.x + frameTimeCounter) * 1.05)+sin((posxz3.z + frameTimeCounter) * 1.05);

		vec3 newnormal3 = vec3(sin(oceannoise*PI),1.0-cos(oceannoise*PI),oceannoise)/22;
//---------------------------------------------------------------------------------------------------------------------------
	if (mc_Entity.x == 10001.0) {

			 float fy = fract(vworldpos.y + 0.001);

				 if (fy > 0.002) {
	float displacement = 0.0;
				 float wave = waves_strenght * sin(2 * pi * (tick*0.75 + vworldpos.x /  7.0 + vworldpos.z / 13.0))
											+ 0.085 * sin(1 * pi * (tick*0.6 + vworldpos.x / 11.0 + vworldpos.z /  5.0));
											displacement = clamp(wave, -fy, 1.0-fy);

											vpos.y += displacement;

										//		vpos.y += wave;
										#ifdef WaveMultiplyVertex
										newnormal2.y *= 2;
													vpos.xz += newnormal2.xz;
													#endif
														//			vpos.xyz += newnormal3;

	}}
#endif
#ifdef BLOCK_WAVE
if (mc_Entity.x == 10012.0) {
	float fy = fract(vworldpos.y + 0.001);

		if (fy > 0.002) {
float displacement = 0.0;
		float wave = 0.085 * sin(2 * pi * (tick*0.75 + vworldpos.x /  7.0 + vworldpos.z / 13.0))
								 + 0.085 * sin(1 * pi * (tick*0.6 + vworldpos.y / 11.0 + vworldpos.z /  5.0));
								 displacement = clamp(wave, -fy, 1.0-fy);
								 vpos.y += displacement;

							 }
						 }
#endif
tangent = vec3(0.0);
binormal = vec3(0.0);
normal = normalize(gl_NormalMatrix * normalize(gl_Normal));

if (gl_Normal.x > 0.5) {
	//  1.0,  0.0,  0.0
	tangent  = normalize(gl_NormalMatrix * vec3( 0.0,  0.0, -1.0));
	binormal = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
}

else if (gl_Normal.x < -0.5) {
	// -1.0,  0.0,  0.0
	tangent  = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  1.0));
	binormal = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
}

else if (gl_Normal.y > 0.5) {
	//  0.0,  1.0,  0.0
	tangent  = normalize(gl_NormalMatrix * vec3( 1.0,  0.0,  0.0));
	binormal = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  1.0));
}

else if (gl_Normal.y < -0.5) {
	//  0.0, -1.0,  0.0
	tangent  = normalize(gl_NormalMatrix * vec3( 1.0,  0.0,  0.0));
	binormal = normalize(gl_NormalMatrix * vec3( 0.0,  0.0,  1.0));
}

else if (gl_Normal.z > 0.5) {
	//  0.0,  0.0,  1.0
	tangent  = normalize(gl_NormalMatrix * vec3( 1.0,  0.0,  0.0));
	binormal = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
}

else if (gl_Normal.z < -0.5) {
	//  0.0,  0.0, -1.0
	tangent  = normalize(gl_NormalMatrix * vec3(-1.0,  0.0,  0.0));
	binormal = normalize(gl_NormalMatrix * vec3( 0.0, -1.0,  0.0));
}

mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
						tangent.y, binormal.y, normal.y,
						tangent.z, binormal.z, normal.z);

						vec3 newnormal = vec3(sin(displacement*pi),1.0-cos(displacement*pi),displacement);

							vec3 bump = newnormal;
							bump = bump;

						float bumpmult = 10.05;


					bump = bump * vec3(bumpmult, bumpmult, bumpmult) + vec3(0.0f, 0.0f, 1.0f - bumpmult);

						normal = bump * tbnMatrix;

					viewVector = (gl_ModelViewMatrix * gl_Vertex).xyz;
					viewVector = normalize(tbnMatrix * viewVector);

vpos = gbufferModelView * vpos;
gl_Position = gl_ProjectionMatrix * vpos;
texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;

lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).st;

gl_FogFragCoord = gl_Position.z;
    TexCoords = gl_MultiTexCoord0.st;
    LightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
    LightmapCoords = (LightmapCoords * 33.05f / 32.0f) - (1.05f / 32.0f);
    Normal = tbnMatrix * normal;
    Color = gl_Color;
}
