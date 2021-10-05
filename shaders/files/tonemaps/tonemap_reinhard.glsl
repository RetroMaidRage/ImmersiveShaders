vec3 Uncharted2TonemapOp(vec3 color)
{
    return color/(10.5+color);
}
