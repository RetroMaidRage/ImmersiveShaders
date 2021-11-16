#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord);
//	color *= texture2D(lightmap, lmcoord);
//	vec4 Vanilla = texture2D(texture, texcoord) * glcolor;

	vec4 cwater = vec4(1.5)*glcolor*color;


	cwater.r = (cwater.r*1);
	  cwater.g = (cwater.g*1);
	  cwater.b = (cwater.b*1);
	cwater = cwater / (cwater + 4.2) * (1.0+2.0);
/* DRAWBUFFERS:0 */
	gl_FragData[0] = cwater; //gcolor
}
