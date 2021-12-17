#version 120

varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	gl_Position = ftransform();
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
}
vec3 viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
vec4 clipPos = gl_ProjectionMatrix * vec4(viewPos, 1.0);
vec3 screenPos = clipPos.xyz / clipPos.w * 0.5 + 0.5;
 
