#version 120

varying vec2 TexCoords;

attribute vec4 mc_Entity;
out vec2 textureCoordinates;

flat out int water;
void main() {
    water = int(mc_Entity.x);
      //if (water == 10023) {
    vec4   vertexpos = gl_Vertex;
   gl_Position = ftransform();
  vec4 fPosition = normalize(gl_Position);
   TexCoords = gl_MultiTexCoord0.st;
     textureCoordinates = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
