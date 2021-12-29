#version 120

varying vec2 texcoord;
varying vec2 TexCoords;
void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
		 TexCoords = gl_MultiTexCoord0.st;
}
