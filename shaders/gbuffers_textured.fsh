#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;
uniform sampler2D colortex0;
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	color *= texture2D(lightmap, lmcoord);

/* DRAWBUFFERS:01 */
	gl_FragData[0] = color; //gcolor
}
