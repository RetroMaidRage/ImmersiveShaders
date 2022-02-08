#define LIGHT_STRENGHT 6 //[1 2 3 4 5 6 7 8 9 10]

float AdjustLightmapTorch(in float torch) {

       float K =LIGHT_STRENGHT;
       float P = 7.06f;
        return K * pow(torch, P);
}
//--------------------------------------------------------------------------------------------
float AdjustLightmapSky(in float sky){
    float sky_2 = sky * sky;
    return sky * sky_2;
}
//--------------------------------------------------------------------------------------------
vec2 AdjustLightmap(in vec2 Lightmap){
    vec2 NewLightMap;
    NewLightMap.x = AdjustLightmapTorch(Lightmap.x);
    NewLightMap.y = AdjustLightmapSky(Lightmap.y);
    return NewLightMap;
}
