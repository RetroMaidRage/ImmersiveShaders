#version 120

varying vec3 tintColor;
varying vec4 starData;
varying vec3 SkyPos;

void main() {

	SkyPos = (gl_ModelViewMatrix * gl_Vertex).xyz;

	gl_Position = ftransform();
	starData = vec4(gl_Color.rgb, float(gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0));
	tintColor = gl_Color.rgb;
}
