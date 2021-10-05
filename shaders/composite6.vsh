#version 120

//#include "composite_variables.glsl"
varying vec3 sunVector;
uniform vec3 sunPosition;
varying vec4 texcoord;
varying vec2 texCoord;
void main() {
  //  gl_Position = transMAD(gl_ModelViewMatrix, gl_Vertex.xyz).xyzz * diagonal4(gl_ProjectionMatrix) + gl_ProjectionMatrix[3];
gl_Position = ftransform();
    texCoord = gl_MultiTexCoord0.st;
    texcoord = gl_MultiTexCoord0;
    sunVector = normalize(sunPosition);
//    moonVector = normalize(-sunPosition);

  //  lightVector = (sunAngle > 0.5) ? moonVector : sunVector;

  //  vec2 noonNight   = vec2(0.0);
  //   noonNight.x = (0.25 - clamp(sunAngle, 0.0, 0.5));
  //   noonNight.y = (0.75 - clamp(sunAngle, 0.5, 1.0));

    // NOON
  //  timeVector.x = 1.0 - clamp01(pow2(abs(noonNight.x) * 4.0));
    // NIGHT
//    timeVector.y = 1.0 - clamp01(pow(abs(noonNight.y) * 4.0, 128.0));
    // SUNRISE/SUNSET
//    timeVector.z = 1.0 - (timeVector.x + timeVector.y);
    // MORNING
  //  timeVector.w = 1.0 - ((1.0 - clamp01(pow2(max0(noonNight.x) * 4.0))) + (1.0 - clamp01(pow(max0(noonNight.y) * 4.0, 128.0))));
}
