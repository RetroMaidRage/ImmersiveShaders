#version 120
//--------------------------------------------UNIFORMS------------------------------------------
varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;
varying vec2 texcoord;
uniform sampler2D gcolor;
uniform vec3 skyColor;
uniform sampler2D noisetex;
uniform sampler2D texture;
uniform mat4 gbufferModelView;
uniform vec3 sunPosition;
varying vec4 glcolor;
//--------------------------------------------DEFINE------------------------------------------
#define CLOUD_RENDERING 0.7 //[0.7 1 0]
#define CLOUD_AMMOUNT 1 ///[1 2 3 4 5]
#define CLOUD_SETTINGS Default //[Clear Default]
 
void main(){
	float Clear = 0.7;
	vec4 Default = vec4(glcolor);

vec2 texcoord = texcoord /CLOUD_AMMOUNT;

    vec4 Albedo = texture2D(texture, texcoord)*CLOUD_SETTINGS;
    gl_FragData[0] = Albedo;
}
