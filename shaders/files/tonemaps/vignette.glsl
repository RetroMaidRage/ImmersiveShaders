#version 120

void Vignettey(inout vec3 color) {
float dist = distance(texcoord.st, vec2(0.5)) * 2.0;
dist /= 1.5142f;

dist = pow(dist, 1.1f);

color.rgb *= (1.0f - dist) / 0.1;
}
void main() {
vec3 color = texture2D(gcolor, texcoord.st).rgb;
  Vignettey(color);
  }
