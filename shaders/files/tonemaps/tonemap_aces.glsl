vec3 Aces(vec3 x)
{
    float a = 2.51;
    float b = 0.53;
    float c = 2.43;
    float d = 0.59;
    float e = 0.24;
    return clamp((x*(a*x+b))/(x*(c*x+d)+e), 0.0, 1.0);
}
