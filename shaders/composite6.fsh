#version 120

#define upVector gbufferModelView[1].xyz
#define max0(n) max(0.0, n)
float pow2(in float n)  { return n * n; }
float pow3(in float n)  { return pow2(n) * n; }
float pow4(in float n)  { return pow2(pow2(n)); }
float pow5(in float n)  { return pow2(pow2(n)) * n; }
float pow6(in float n)  { return pow2(pow2(n) * n); }
float pow7(in float n)  { return pow2(pow2(n) * n) * n; }
float pow8(in float n)  { return pow2(pow2(pow2(n))); }
float pow9(in float n)  { return pow2(pow2(pow2(n))) * n; }
float pow10(in float n) { return pow2(pow2(pow2(n)) * n); }
float pow11(in float n) { return pow2(pow2(pow2(n)) * n) * n; }
float pow12(in float n) { return pow2(pow2(pow2(n) * n)); }
float pow13(in float n) { return pow2(pow2(pow2(n) * n)) * n; }
float pow14(in float n) { return pow2(pow2(pow2(n) * n) * n); }
float pow15(in float n) { return pow2(pow2(pow2(n) * n) * n) * n; }
float pow16(in float n) { return pow2(pow2(pow2(pow2(n)))); }

varying vec3 sunVector;
uniform sampler2D colortex0;
varying vec2 texCoord;
uniform sampler2D depthtex1;
uniform mat4 gbufferModelViewInverse, gbufferProjectionInverse, gbufferProjection;
uniform mat4 shadowModelView, shadowProjection;
uniform mat4 shadowModelViewInverse, shadowProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferPreviousModelView;
uniform mat4 gbufferPreviousProjection;
uniform float far, near;
uniform sampler2D colortex5;
const float pi  = 3.14;
varying vec2 TexCoords;

#include "sky.glsl"

#define getLandMask(x) (x < (1.0 - near / far / far))

void main() {
    vec4 color = texture2D(colortex0, texCoord.st);
//    float depth = texture2D(depthtex1, texCoord.st).r;
    float depth = texture2D(depthtex1, texCoord).r;

    color.rgb = pow(color.rgb, vec3(2.2));

    vec4 view = vec4(vec3(texCoord.st, depth) * 2.0 - 1.0, 1.0);
    view = gbufferProjectionInverse * view;

    if(!getLandMask(depth)) color.rgb = js_getScatter(vec3(0.0), normalize(view.xyz), sunVector, 0);

    color.rgb = pow(color.rgb, vec3(1.0 / 2.2));

	 /* DRAWBUFFERS:01 */

    gl_FragData[0] = color;
    gl_FragData[1] = texture2D(colortex5, texCoord.st);
}
