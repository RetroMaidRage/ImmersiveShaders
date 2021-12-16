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
#define waving_grass
#define waving_leaves_speed 0.1 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
#define waving_grass_speed 0.07 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
const float pi = 3.14f;

float tick = frameTimeCounter;

void main() {
texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	vec4 position = gl_ModelViewMatrix * gl_Vertex;
  vec4 vpos = gbufferModelViewInverse*position;
  vworldpos = vpos.xyz + cameraPosition;

  #ifdef waving_grass
    if (mc_Entity.x == 10002.0 || mc_Entity.x == 10003.0 || mc_Entity.x == 10004.0) {

      float magnitude = sin((tick * pi / (28.0)) + vworldpos.x + vworldpos.z) * 0.12 + 0.02;
       vpos.x += sin((tick * pi / (28.0 * waving_grass_speed)) + (vworldpos.x + -5.0) * 0.1 + (vworldpos.z + 10.0) * 0.1) * magnitude;
            vpos.z += sin((tick * pi / (28.0 * waving_grass_speed)) + (vworldpos.x + 10.0) * 0.1 + (vworldpos.z + 0.0) * 0.1) * magnitude;
                //  position.y += sin((tick * pi / (28.0 * speed)) + (position.x + 0.0) * 0.1 + (position.z + 0.0) * 0.1) * magnitude;
    }

    if (mc_Entity.x == 10007.0) {

      float magnitude = sin((tick * pi / (28.0)) + vworldpos.x + vworldpos.z) * 0.12 + 0.02;
       vpos.x += sin((tick * pi / (28.0 * waving_leaves_speed)) + (vworldpos.x + 0.0) * 0.1 + (vworldpos.z + 10.0) * 0.1) * magnitude;
            vpos.y += sin((tick * pi / (28.0 * waving_leaves_speed)) + (vworldpos.x + 0.0) * 0.1 + (vworldpos.z + 0.0) * 0.1) * magnitude;
    }
  #endif

vpos = gbufferModelView * vpos;
gl_Position = gl_ProjectionMatrix * vpos;
    TexCoords = gl_MultiTexCoord0.st;
    LightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
    LightmapCoords = (LightmapCoords * 33.05f / 32.0f) - (1.05f / 32.0f);
    Normal = gl_NormalMatrix * gl_Normal;
    Color = gl_Color;
}
