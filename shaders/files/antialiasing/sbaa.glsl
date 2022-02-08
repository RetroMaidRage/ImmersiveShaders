float bw(sampler2D col, vec2 uv) {
	return dot(texture(col, uv).xyz, vec3(1./3.));
}

vec2 nUv(vec2 uv, vec2 screenres) {
	return uv/screenres;
}

float sobelHorizontal(vec2 pUv, sampler2D col, screenres) {
	float k1 = bw(col, nUv(pUv-1.),screenres)*-1.;
    float k2 = bw(col, nUv(pUv-vec2(1., -1.),screenres))*-1.;
    float k3 = bw(col, nUv(pUv-vec2(1., 0.),screenres))*-2.;
    float k4 = bw(col, nUv(pUv+1.,screenres));
    float k5 = bw(col, nUv(pUv+vec2(1., -1.),screenres));
    float k6 = bw(col, nUv(pUv+vec2(1., 0.),screenres))*2.;
    return((k1+k2+k3+k4+k5+k6)/6.);
}
float sobelVertical(vec2 pUv, sampler2D col) {
	float k1 = bw(col, nUv(pUv-1.))*-1.;
    float k2 = bw(col, nUv(pUv-vec2(-1., 1.),screenres))*-1.;
    float k3 = bw(col, nUv(pUv-vec2(0., 1.),screenres))*-2.;
    float k4 = bw(col, nUv(pUv+1.),screenres);
    float k5 = bw(col, nUv(pUv+vec2(-1., 1.),screenres));
    float k6 = bw(col, nUv(pUv+vec2(0., 1.)),screenres)*2.;
    return((k1+k2+k3+k4+k5+k6)/6.);
}
