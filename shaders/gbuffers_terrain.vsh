#version 120
//#include "/files/filters/noises.glsl"
//--------------------------------------------UNIFORMS------------------------------------------
attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;
out vec3 vworldpos;
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
out float BlockId;
varying vec3 SkyPos;
uniform float rainStrength;
//--------------------------------------------DEFINE------------------------------------------
#define waving_grass
#define waving_leaves_speed 0.1 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
#define waving_grass_speed 0.07 ///[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
const float pi = 3.14f;
varying vec3 viewPos;

float tick = frameTimeCounter;
float Time = max(frameTimeCounter, 1100);

void main() {
		SkyPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
		BlockId = mc_Entity.x;
texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	vec4 position = gl_ModelViewMatrix * gl_Vertex;
  vec4 vpos = gbufferModelViewInverse*position;
  vworldpos = vpos.xyz + cameraPosition;
	viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;

  #ifdef waving_grass
    if (mc_Entity.x == 10002.0 || mc_Entity.x == 10003.0 || mc_Entity.x == 10004.0 || mc_Entity.x == 10015.0 ) {

      float magnitude = sin((tick * pi / (28.0)) + vworldpos.x + vworldpos.z) * 0.055 * (1.0 + rainStrength);
    //   vpos.x += sin((tick * pi / (28.0 * waving_grass_speed)) + (vworldpos.x + -5.0) * 0.1 + (vworldpos.z + 10.0) * 0.1) * magnitude;
          //  vpos.z += sin((tick * pi / (28.0 * waving_grass_speed)) + (vworldpos.x + 10.0) * 0.1 + (vworldpos.z + 0.0) * 0.1) * magnitude;
                //  position.y += sin((tick * pi / (28.0 * speed)) + (position.x + 0.0) * 0.1 + (position.z + 0.0) * 0.1) * magnitude;

								vpos.x += sin(pow(tick, 1.0))*magnitude;
								vpos.z += sin(pow(tick, 1.0))*magnitude;
																vpos.x += sin(pow(tick, 1.0)+(vworldpos.x + 1.0+Time)+(vworldpos.z + 1.0+Time)+(vworldpos.y + 11.0+Time))*magnitude;
																vpos.z += cos(pow(tick, 1.0)+(vworldpos.x + 1.0+Time)+(vworldpos.z + 1.0+Time)+(vworldpos.y + 11.0+Time)/50)*magnitude;
															//			vpos.y += sin(pow(tick, 1.0)+(vworldpos.x + 1.0+Time)+(vworldpos.z + 1.0+Time)+(vworldpos.y + 11.0+Time)/5)*(magnitude/2);
    }

    if (mc_Entity.x == 10007.0) {

      float magnitude = sin((tick * pi / (28.0)) + vworldpos.x + vworldpos.z) * 0.12 + 0.02 * (1.0 + rainStrength);;
       vpos.x += sin((tick * pi / (28.0 * waving_leaves_speed)) + (vworldpos.x + 0.0) * 0.1 + (vworldpos.z + 10.0) * 0.1) * magnitude;
            vpos.y += sin((tick * pi / (28.0 * waving_leaves_speed)) + (vworldpos.x + 0.0) * 0.1 + (vworldpos.z + 0.0) * 0.1) * magnitude;
    }

		    if (mc_Entity.x == 10008.0) {
					float fy = fract(vworldpos.y + 0.001);

						if (fy > 0.002) {
		 float displacement = 0.0;
						float wave = 0.085 * sin(2 * pi * (tick*0.75 + vworldpos.x /  7.0 + vworldpos.z / 13.0))
												 + 0.085 * sin(1 * pi * (tick*0.6 + vworldpos.x / 11.0 + vworldpos.z /  5.0));
												 displacement = clamp(wave, -fy, 1.0-fy);
												 vpos.y += displacement;
											 }}
  #endif

	if (mc_Entity.x == 10011.0) {
float magnitudee = sin((tick * pi / (28.0))) * 0.10;
float magnitude2 = sin((tick * pi / (28.0)) + vworldpos.x + vworldpos.z) * 0.075;
//				vpos.x += sin(pow(tick, 1.0))*magnitude;
//		vpos.z += sin(pow(tick, 1.0))*magnitude;
										vpos.x += sin(pow(tick, 1.0))*magnitudee;
																			vpos.z += sin(pow(tick, 1.0))*magnitudee/2;
						//				vpos.z += cos(pow(tick, 1.0)+(vworldpos.x + 1.0+Time)+(vworldpos.z + 1.0+Time)+(vworldpos.y + 11.0+Time)/50)*magnitude;
	}
vpos = gbufferModelView * vpos;
gl_Position = gl_ProjectionMatrix * vpos;
    TexCoords = gl_MultiTexCoord0.st;
    LightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
    LightmapCoords = (LightmapCoords * 33.05f / 32.0f) - (1.05f / 32.0f);
    Normal = gl_NormalMatrix * gl_Normal;
    Color = gl_Color;
}
