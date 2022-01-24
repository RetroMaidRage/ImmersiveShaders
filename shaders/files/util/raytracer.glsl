vec3 ComputeSSR(vec3 viewDir, vec3 ViewSpace, vec3 ClipSpace, vec3 Normal){



    vec3 RayDirection = reflect(viewDir, Normal);
    vec3 ViewSpaceWithRayDirection = ViewSpace + RayDirection;

    vec4 ScreenSpaceRayDirectionW = gbufferProjection *  vec4(ViewSpaceWithRayDirection, 1.0f);
    vec3 ScreenSpaceRayDirection = normalize(ScreenSpaceRayDirectionW.xyz / ScreenSpaceRayDirectionW.w - ClipSpace) * 0.01f;

    vec3 RayMarchPosition = ClipSpace;

    for(int i = 0; i < SSR2_Steps; i++){

        RayMarchPosition += ScreenSpaceRayDirection;
        vec3 ScreenSpace = RayMarchPosition * 0.5f + 0.5f;

        if(any(lessThan(ScreenSpace.xy, vec2(0.0f))) || any(greaterThan(ScreenSpace.xy, vec2(1.0f)))){
            return vec3(0.0f);
        } else if(texture2D(depthtex0, ScreenSpace.xy).x < ScreenSpace.z){
            return texture2D(colortex0,ScreenSpace.xy).rgb;
        }

    }
    return texture2D(colortex0, RayMarchPosition.xy * 0.5f + 0.5f).rgb;
}
