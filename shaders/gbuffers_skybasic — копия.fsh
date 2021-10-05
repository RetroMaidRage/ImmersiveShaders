#version 120

uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;
uniform float frameTimeCounter;
uniform vec3 sunPosition;
uniform float worldTime;

varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.
const float coeiff = 0.25;
const vec3 totalSkyLight = vec3(0.3, 0.5, 1.0);

float timefract = worldTime;
float TimeSunrise  = ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0) + (1.0 - (clamp(timefract, 0.0, 4000.0)/4000.0));
float TimeNoon     = ((clamp(timefract, 0.0, 4000.0)) / 4000.0) - ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0);
float TimeSunset   = ((clamp(timefract, 8000.0, 12000.0) - 8000.0) / 4000.0) - ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0);
float TimeMidnight = ((clamp(timefract, 12000.0, 12750.0) - 12000.0) / 750.0) - ((clamp(timefract, 23000.0, 24000.0) - 23000.0) / 1000.0);

float tick = frameTimeCounter;

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 mie(float dist, vec3 sunL){
    return max(exp(-pow(dist, 0.25)) * sunL - 0.4, 0.0);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	return mix(skyColor, fogColor, fogify(max(upDot, 0.0), 0.25));
}

vec3 getSky(vec2 uv){

	vec2 sunPos = vec2(0.5, cos(worldTime * 0.3 + 3.14 * 0.564));

    float sunDistance = distance(uv, clamp(sunPos, -1.0, 1.0));
	//	float sunDistance2 = distance(uv, clamp(sunPosition, -1.0, 1.0));

	float scatterMult = clamp(sunDistance, 0.0, 1.0);
	float sun = clamp(1.0 - smoothstep(0.01, 0.011, scatterMult), 0.0, 1.0);

	float dist = uv.y;
	dist = (coeiff * mix(scatterMult, 1.0, dist)) / dist;

    vec3 mieScatter = mie(sunDistance, vec3(1.0));

	vec3 color = dist * totalSkyLight;

    color = max(color, 0.0);

	color = max(mix(pow(color, 1.0 - color),
	color / (2.0 * color + 0.5 - color),
	clamp(sunPos.y * 2.0, 0.0, 1.0)),0.0)
	+ sun + mieScatter;

	color *=  (pow(1.0 - scatterMult, 10.0) * 10.0) + 1.0;

	float underscatter = distance(sunPos.y * 0.5 + 0.5, 1.0);

	color = mix(color, vec3(0.0), clamp(underscatter, 0.0, 1.0));

	return color;
}

void main() {
vec3 color;

		vec4 pos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
		pos = gbufferProjectionInverse * pos;
		vec2 skyposs = gl_FragCoord.xy / vec2(viewWidth, viewHeight);

	//vec3	skypos = normalize(genType v)
		 color = getSky(normalize(skyposs));
	//	vec3 color = getSky(fragCoord.xy / iResolution.x);



//gl_FragColor = vec4(color, 1.0);


/* DRAWBUFFERS:0 */
	gl_FragData[0] = vec4(color, 1.0); //gcolor
}
