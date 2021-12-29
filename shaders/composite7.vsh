#version 120

varying vec2 texcoord;
varying vec3 pos;
varying vec2 TexCoords;

void main() {

	pos = vec3 ( gl_ModelViewMatrix * gl_Vertex );          // transformed point to world space
	    gl_Position     = gl_ModelViewProjectionMatrix * gl_Vertex;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	 TexCoords = gl_MultiTexCoord0.st;
}
