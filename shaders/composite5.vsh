#version 120
attribute vec3 mc_Entity;
varying vec2 texcoord;
out float entityId;

void main() {
		entityId = mc_Entity.x;
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
