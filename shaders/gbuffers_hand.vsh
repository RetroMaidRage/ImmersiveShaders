#version 120

//--------------------------------------------UNIFORMS------------------------------------------
attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;
varying vec3 vworldpos;
uniform float frameTimeCounter;
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glColor;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;

//--------------------------------------------DEFINE------------------------------------------
#define waving_hand
#define waving_hand_speed 0.07 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
const float pi = 3.14f;

float tick = frameTimeCounter;

void main() {
texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	vec4 position = gl_ModelViewMatrix * gl_Vertex;
  vec4 vpos = gbufferModelViewInverse*position;
  vworldpos = vpos.xyz + cameraPosition;

  #ifdef waving_hand
  float magnitude = sin((tick * pi / (28.0)) + vworldpos.x + vworldpos.z) * 0.1 + 0.002;
      float magnitude2 = sin((tick * pi / (28.0)) + vworldpos.x + vworldpos.z) * 0.1 + 0.05;
    //   vpos.x += sin((tick * pi / (28.0 * waving_hand_speed)) + (vworldpos.x + 0.0) * 0.1 + (vworldpos.z + 10.0) * 0.1) * magnitude;
            //vpos.z += sin((tick * pi / (28.0 * waving_hand_speed)) + (vworldpos.x + 0.0) * 0.1 + (vworldpos.z + 0.0) * 0.1) * magnitude2;
                //  position.y += sin((tick * pi / (28.0 * speed)) + (position.x + 0.0) * 0.1 + (position.z + 0.0) * 0.1) * magnitude;
								vpos.xy += sin(frameTimeCounter * vec2(1.6, 1.2)) * (sign(gl_ModelViewMatrix[3][0] + 0.3125) * 0.015625);

  #endif

vpos = gbufferModelView * vpos;
gl_Position = gl_ProjectionMatrix * vpos;
    TexCoords = gl_MultiTexCoord0.st;
    LightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
    LightmapCoords = (LightmapCoords * 33.05f / 32.0f) - (1.05f / 32.0f);
    Normal = gl_NormalMatrix * gl_Normal;
    Color = gl_Color;
}
