#version 120

//--------------------------------------------UNIFORMS------------------------------------------
varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;
uniform float frameTimeCounter;
attribute vec4 mc_Entity;
varying vec4 texcoord;
uniform float rainStrength;
uniform int worldTime;
varying vec4 lmcoord;
//--------------------------------------------DEFINE------------------------------------------
//#define waving_terrain
#define waving_grass

void main() {
  const float pi = 3.14f;

	float tick = frameTimeCounter;


	vec4 position = gl_Vertex;
#ifdef waving_terrain
float speed = 10.1;
float magnitude = sin((tick * pi / (28.0)) + position.x + position.z) * 0.12 + 0.02;
  position.x += sin((tick * pi / (28.0 * speed)) + (position.x + 0.0) * 0.1 + (position.z + 0.0) * 0.1) * magnitude;
      position.y += sin((tick * pi / (28.0 * speed)) + (position.x + 0.0) * 0.1 + (position.z + 0.0) * 0.1) * magnitude;
#endif



#ifdef waving_grass
  if (mc_Entity.x == 31.0 || mc_Entity.x == 32.0 || mc_Entity.x == 33.0) {
    float speed = 0.07;
    float magnitude = sin((tick * pi / (28.0)) + position.x + position.z) * 0.12 + 0.02;
     position.x += sin((tick * pi / (28.0 * speed)) + (position.x + 0.0) * 0.1 + (position.z + 10.0) * 0.1) * magnitude;
          position.y += sin((tick * pi / (28.0 * speed)) + (position.x + 0.0) * 0.1 + (position.z + 0.0) * 0.1) * magnitude;
              //  position.y += sin((tick * pi / (28.0 * speed)) + (position.x + 0.0) * 0.1 + (position.z + 0.0) * 0.1) * magnitude;
  }

  if (mc_Entity.x == 34.0) {
    float speed = 0.1;
    float magnitude = sin((tick * pi / (28.0)) + position.x + position.z) * 0.12 + 0.02;
     position.x += sin((tick * pi / (28.0 * speed)) + (position.x + 0.0) * 0.1 + (position.z + 10.0) * 0.1) * magnitude;
          position.y += sin((tick * pi / (28.0 * speed)) + (position.x + 0.0) * 0.1 + (position.z + 0.0) * 0.1) * magnitude;
  }
#endif


gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * position);
    TexCoords = gl_MultiTexCoord0.st;
    LightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
    LightmapCoords = (LightmapCoords * 33.05f / 32.0f) - (1.05f / 32.0f);
    Normal = gl_NormalMatrix * gl_Normal;
    Color = gl_Color;
}
