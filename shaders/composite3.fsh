#version 120

uniform sampler2D gcolor;
uniform vec3 sunPosition;
uniform sampler2D gaux1;
uniform float weight;
varying vec2 texcoord;

void main() {
vec3 color = texture2D(gcolor, texcoord).rgb;
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}
