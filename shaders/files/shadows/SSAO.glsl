#define AOAmount 0.5	///[0.1 0.11 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 3.0 4.0 5 6.0 7.0 8.0 9.0 10 15 20]
#define AO_Samples 5 ///[1 2 3 4 5 6 7 8 9 10 20]
vec2 offsetDist(float x, int s){
	float n = fract(x*1.414)*3.1415;
    return vec2(cos(n),sin(n))*x/s;
}

float dbao(sampler2D depth, float dither){
	float ao = 0.0;


	dither = fract(frameTimeCounter * 4.0 + dither);


	float d = texture2D(depth,texcoord.xy).r;
	float hand = float(d < 0.56);
	d = ld(d);

	float sd = 0.0;
	float angle = 0.0;
	float dist = 0.0;
	vec2 scale = 0.6 * vec2(1.0/aspectRatio,1.0) * gbufferProjection[1][1] / (2.74747742 * max(far*d,6.0));

	for (int i = 1; i <= AO_Samples; i++) {
		vec2 offset = offsetDist(i + dither, AO_Samples) * scale;

		sd = ld(texture2D(depth,texcoord.xy+offset).r);
		float sample = far*(d-sd)*2.0;
		if (hand > 0.5) sample *= 1024.0;
		angle = clamp(0.5-sample,0.0,1.0);
		dist = clamp(0.25*sample-1.0,0.0,1.0);

		sd = ld(texture2D(depth,texcoord.xy-offset).r);
		sample = far*(d-sd)*2.0;
		if (hand > 0.5) sample *= 1024.0;
		angle += clamp(0.5-sample,0.0,1.0);
		dist += clamp(0.25*sample-1.0,0.0,1.0);


		ao += clamp(angle + dist,0.0,1.0);
	}
	ao /= AO_Samples;

	return pow(ao,AOAmount);
}
