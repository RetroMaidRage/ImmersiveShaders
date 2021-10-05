#version 120

varying vec2 TexCoords;
varying vec4 Color;

uniform sampler2D texture;

void main() {
    gl_FragData[0] = texture2D(texture, TexCoords) * Color;
    	gl_FragData[1] = vec4(0.0);
}
