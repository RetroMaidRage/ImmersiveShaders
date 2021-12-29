#version 120

varying vec4 texcoord;
varying vec3 SkyPos;
void main(){
  gl_Position = ftransform();
 	SkyPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
  texcoord = gl_MultiTexCoord0;
}
