#version 120
attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;
out vec3 vworldpos;
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
out float BlockId;
varying vec3 SkyPos;
uniform float rainStrength;
out float entityId;
	 out vec4 fPosition;
void main() {
		entityId = mc_Entity.x;
	gl_Position = ftransform();
	   fPosition = normalize(gl_Position);
		 vec4 position = gl_ModelViewMatrix * gl_Vertex;
			vec4 vpos = gbufferModelViewInverse*position;
			vworldpos = vpos.xyz + cameraPosition;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
