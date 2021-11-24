#version 120

uniform sampler2D lightmap;
uniform sampler2D texture;
uniform sampler2D depthtex2;
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
uniform sampler2D gnormal;
uniform mat4 gbufferProjectionInverse;
uniform sampler2D depthtex1;
uniform mat4 gbufferProjection;
uniform sampler2D composite;
const int maxf = 6;				//number of refinements
const float stp = 1.0;			//size of one step for raytracing algorithm
const float ref = 0.1;			//refinement multiplier
const float inc = 2.0;
float cdist(vec2 coord) {
    return distance(coord,vec2(0.5))*2.0;
}
vec3 nvec3(vec4 pos) {
    return pos.xyz/pos.w;
}

vec4 nvec4(vec3 pos) {
    return vec4(pos.xyz, 1.0);
}



void main() {
	vec4 color = texture2D(texture, texcoord);
//	color *= texture2D(lightmap, lmcoord);
//	vec4 Vanilla = texture2D(texture, texcoord) * glcolor;

	vec4 cwater = vec4(1.5)*glcolor*color;
	vec3 fragpos = vec3(texcoord.st, texture2D(depthtex2, texcoord.st).r);
	fragpos = nvec3(gbufferProjectionInverse * nvec4(fragpos * 2.0 - 1.0));
	vec3 normal = texture2D(gnormal, texcoord.st).rgb * 2.0 - 1.0;
		float normalDotEye = dot(normal, normalize(fragpos));
		float fresnel = clamp(pow(1.0 + normalDotEye, 5.0),0.0,1.0);

	cwater.r = (cwater.r*1);
	  cwater.g = (cwater.g*1);
	  cwater.b = (cwater.b*1.2);
	cwater = cwater / (cwater + 4.2) * (1.0+2.0);

/* DRAWBUFFERS:0 */
	gl_FragData[0] = cwater; //gcolor
}
