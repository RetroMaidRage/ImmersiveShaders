#define atmosphereHeight 8000.  // actual thickness of the atmosphere
#define earthRadius 6371000.    // actual radius of the earth
#define mieMultiplier 1.
#define ozoneMultiplier 1.      // 1. for physically based
#define rayleighDistribution 8. //physically based
#define mieDistribution 1.8     //physically based
#define rayleighCoefficient vec3(5.8e-6,1.35e-5,3.31e-5) // Physically based (Bruneton, Neyret)
#define ozoneCoefficient (vec3(3.426,8.298,.356) * 6e-5 / 100.) // Physically based (Kutz)
#define mieCoefficient ( 3e-6 * mieMultiplier) //good default

vec2 js_getThickness2(vec3 rd){
    vec2 sr = earthRadius + vec2(
        atmosphereHeight,
        atmosphereHeight * mieDistribution / rayleighDistribution
    );
    vec3 ro = -upVector * earthRadius;
    float b = dot(rd, ro);
    return b + sqrt( sr * sr + (b * b - dot(ro, ro)) );
}

#define getEarth(a) pow(smoothstep(-.1,.1,dot(upVector,a)),1.)
#define phaseRayleigh(a) ( .2 * (a) + 1.14 )

//float phaseMie(float x){
//    const vec3 c = vec3(.256098,.132268,.010016);
  //  const vec3 d = vec3(-1.5,-1.74,-1.98);
  //  const vec3 e = vec3(1.5625,1.7569,1.9801);
//    return dot((x * x + 1.) * c / pow( d * x + e, vec3(1.5)),vec3(.33333333333));
//}

vec3 absorb(in vec2 a) { return exp( -(a).x * (  ozoneCoefficient * ozoneMultiplier + rayleighCoefficient) - 1.11 * (a).y * mieCoefficient); }

const float js_steps = 16.;
const float js_steps_inv = 2.0 / js_steps;


vec3 js_sunColor(vec3 V, vec3 L) {
    return absorb(js_getThickness2(L)) * getEarth(L);
}

vec3 js_getScatter(in vec3 colour, in vec3 V, in vec3 L, in int mode) {
  vec2 thickness = js_getThickness2(V) / js_steps;

  float dotVS = dot(V, sunVector);
//  float dotVM = dot(V, moonVector);

  vec3 viewAbsorb = absorb(thickness);
  vec4 scatterCoeff = 1. - exp(-thickness.xxxy * vec4(rayleighCoefficient,mieCoefficient));

  vec3 scatterS = scatterCoeff.xyz * phaseRayleigh(dotVS);
//  vec3 scatterM = scatterCoeff.xyz * phaseRayleigh(dotVM) + (scatterCoeff.w * phaseMie(dotVM));

  vec3 js_sunAbsorb = absorb(js_getThickness2(sunVector)*js_steps_inv) * getEarth(sunVector);
//  vec3 js_moonAbsorb = absorb(js_getThickness2(moonVector)*js_steps_inv) * getEarth(moonVector);

  vec3 skyColorS = mode != 0 ? vec3(0.0) : colour + (sin(max0(pow16(dotVS) - 0.9935) / 0.015 * pi) * js_sunAbsorb * 200.0);
//  vec3 skyColorM = mode != 0 ? vec3(0.0) : colour + (max0(pow(dotVM, 5000.0)) * 50.0 * moonLight);

  for(int i = 0; i < int(js_steps); i++) { 
    scatterS *= js_sunAbsorb * 0.9;
    //scatterM *= js_moonAbsorb * moonLight * 0.00725;

    skyColorS = skyColorS * viewAbsorb + scatterS;
  //  skyColorM = skyColorM * viewAbsorb + scatterM;
  }
  return skyColorS;
}
