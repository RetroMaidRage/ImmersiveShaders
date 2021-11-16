#include "/shaders/composite.fsh"

#define specularLight
#ifdef specularLight

vec3 ClipSpacee = vec3(TexCoords, Depth) * 2.0f - 1.0f;
vec4 ViewWw = gbufferProjectionInverse * vec4(ClipSpacee, 1.0f);
vec3 Vieww = ViewWw.xyz / ViewWw.w;

vec3 lightDir = normalize(shadowLightPosition + Vieww.xyz);
     vec3 viewDir = normalize(lightDir - Vieww.xyz);

  float specularStrength = 0.45;
  vec3 testLight = vec3(0.5, 0.25, 0.0);

  testLight.r = (testLight.r*2.6);
    testLight.g = (testLight.g*1.4);
    testLight.b = (testLight.b*11.1);
  testLight = testLight / (testLight + 4.2) * (1.0+2.0);

    vec4 fragPos = gbufferProjectionInverse * vec4(TexCoords, texture2D(depthtex1, TexCoords).r, 1.0);
      fragPos = vec4(fragPos.xyz/fragPos.w, fragPos.w);


       vec3 reflectDir = reflect(-lightDir, Normal);
       float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32);

       vec3 specular = specularStrength * spec * testLight;


#endif
