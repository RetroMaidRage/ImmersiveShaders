uniform mat4 gbufferModelView;
uniform vec3 fogColor;
uniform vec3 skyColor;

#define SKY_COLOR_RED 0.0 ///[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
#define SKY_COLOR_GREEN 0.2 ///[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
#define SKY_COLOR_BLUE 1.0 ///[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]
#define SKY_SKATTERING 0.1  ///[ 0.001 0.002 0.003 0.004 0.005 0.006 0.007 0.008 0.009 0.010  0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10 15 20]


float fogify(float x, float w) { 	return w / (x * x + w);
}

vec3 CalculateVanillaSky(vec3 SkyPos) {
	float upDot = dot(SkyPos, gbufferModelView[1].xyz); //not much, what's up with you?
	vec3 skycol = vec3(SKY_COLOR_RED, SKY_COLOR_GREEN, SKY_COLOR_BLUE);
	vec3 OtherSkyColor = mix(skyColor.rgb, fogColor, skycol);
	return mix(OtherSkyColor, fogColor, fogify(max(upDot, 0.0), SKY_SKATTERING));
}
//-------------------------------------------------------------------------------------
vec3 mie(float dist, vec3 sunL){
return max(exp(-pow(dist, 0.55)) * sunL - 0.2, 0.0);
}

float Rayleigh(float costh){
return 3.0 / (16.0 * 3.14 ) * (1.0 + costh * costh);
}

float phaseHG(float g, float cst) {
    float gg = g*g;
    return (1.0 - gg) / (4.0*3.14*pow(1.0+gg-2.0*g*cst, 1.5));
}
