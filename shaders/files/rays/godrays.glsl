#ifdef GODRAYS


const float GR_DECAY    = 1.0*GODRAYS_DECAY;
const float GR_DENSITY  = 1.0*GODRAYS_LENGHT;
const float GR_EXPOSURE = 1.0*GODRAYS_BRIGHTNESS;
const int GR_SAMPLES    = 4*GODRAYS_SAMPLES;
#endif

#ifdef GODRAYS
    vec4 tpos = vec4(sunPosition,1.0)*gbufferProjection;
    tpos = vec4(tpos.xyz/tpos.w,1.0);
    vec2 pos1 = tpos.xy/tpos.z;
    vec2 lightPos = pos1*0.5+0.5;
    float threshold = 0.99 * far;


    #ifdef MOONRAYS

    #else
      if ((worldTime < 14000 || worldTime > 22000) && sunPosition.z < 0)
    #endif

        {
                vec2 texCoord = texcoord.st;
                vec2 delta = (texCoord - lightPos) * GR_DENSITY / float(GODRAYS_SAMPLES);
                float decay = -sunPosition.z / 1000.0;
                vec3 colorGR = vec3(0.0);
                for (int i = 0; i < GR_SAMPLES; i++) {
                        texCoord -= delta;
                        if (texCoord.x < 0.0 || texCoord.x > 1.0) {
                                if (texCoord.y < 0.0 || texCoord.y > 1.0) {
                                        break;
                                }
                        }
                        vec3 sample = vec3(0.0);
                        if (getDepth(texCoord) > threshold) {
                                sample = texture2D(gaux1, texCoord).rgb;
                        }
                        sample *= vec3(decay);
                        if (distance(texCoord, lightPos) > 0.05) sample *= 0.2;
                        colorGR += sample* GODRAYS_DITHER;
                        decay *= GR_DECAY;
                }

      colorGR.r = colorGR.r, fogColor;
      colorGR.g = colorGR.g, fogColor;
      colorGR.b = colorGR.b, fogColor;
                color = (color + GR_EXPOSURE * vec4(colorGR.r * GODRAYS_COLOR_RED, colorGR.g * 1.12, colorGR.b * 0.50, 0.01)*(TimeSunrise+TimeNoon+TimeSunset)* clamp(1.0 - rainStrength,0.1,1.0));
                color = (color + GR_EXPOSURE * vec4(colorGR.r * GODRAYS_COLOR_RED, colorGR.g * 1.12, colorGR.b * 0.50, 0.01)*TimeMidnight* clamp(1.0 - rainStrength,0.1,1.0));
        }
#endif
