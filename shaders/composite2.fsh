#version 120



uniform mat4 gbufferModelView;
uniform mat4 gbufferProjection;

uniform mat4 shadowModelView;


uniform sampler2D gcolor;

varying vec2 texcoord;

uniform sampler2D gdepthtex;
uniform sampler2D depthtex1;
uniform sampler2D depthtex0;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D shadowtex0;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
uniform sampler2D composite;
uniform sampler2D colortex4;


uniform int frameCounter;
uniform int isEyeInWater;
uniform int worldTime;

uniform float aspectRatio;
uniform float blindness;
uniform float far;
uniform float frameTimeCounter;
uniform float near;
uniform float rainStrength;
uniform float timeAngle;
uniform float timeBrightness;
uniform float viewWidth;
uniform float viewHeight;

uniform vec3 skyColor;
uniform vec3 cameraPosition;
uniform mat4 shadowProjection;
uniform sampler2D colortex2;
uniform vec3 shadowLightPosition;

varying vec3 lightVector;
float ld(float depth) {
   return (2.0 * near) / (far + near - depth * (far - near));
}




void main() {

	vec3 color = texture2D(gcolor, texcoord).rgb;


/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}
