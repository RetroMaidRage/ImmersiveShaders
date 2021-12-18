#version 150 compatibility

varying vec2 texcoord;
attribute vec4 mc_Entity;
varying vec3 pos;
out vec3 vworldpos;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
out float entityId;
uniform float frameTimeCounter;

void main() {
	entityId = mc_Entity.x;
	int blockId = int(entityId);
	pos = vec3 ( gl_ModelViewMatrix * gl_Vertex );          // transformed point to world space
	    gl_Position     = gl_ModelViewProjectionMatrix * gl_Vertex;
			vec4 position = gl_ModelViewMatrix * gl_Vertex;
			vec4 vpos = gbufferModelViewInverse*position;
			vworldpos = vpos.xyz + cameraPosition;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
