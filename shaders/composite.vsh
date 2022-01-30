#version 120

varying vec2 TexCoords;
varying vec2 texcoord;
attribute vec4 mc_Entity;
out vec2 textureCoordinates;
out float entityId;
varying vec3 SkyPos;
void main() {
  entityId = mc_Entity.x;
  	int blockId = int(entityId);
    vec4   vertexpos = gl_Vertex;
   gl_Position = ftransform();
  vec4 fPosition = normalize(gl_Position);
   TexCoords = gl_MultiTexCoord0.st;
     textureCoordinates = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
     texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
     	SkyPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
}
