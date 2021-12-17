#version 150 compatibility

varying vec2 texcoord;
attribute vec4 mc_Entity;
varying vec3 pos;

void main() {
int water = int(mc_Entity.x);
	pos = vec3 ( gl_ModelViewMatrix * gl_Vertex );          // transformed point to world space
	    gl_Position     = gl_ModelViewProjectionMatrix * gl_Vertex;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
 
