// State of include guard
#ifndef DISTORT_GLSL
#define DISTORT_GLSL
#define DISORT_THREASHOLD 0.9 //[0.001 0.01 0.1 0.2 0.3 0.4. 0.5 0.6 0.7 0.8 0.9]

vec2 DistortPosition(in vec2 position){
    float CenterDistance = length(position);
    float DistortionFactor = mix(1.0f, CenterDistance, DISORT_THREASHOLD);
    return position / DistortionFactor;
}

#endif
