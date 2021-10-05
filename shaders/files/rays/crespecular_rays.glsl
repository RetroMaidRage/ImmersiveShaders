#version 120

#define GAMMA 1.3
#define GOD_RAYS

#ifdef GOD_RAYS

const float GR_DECAY 	= 0.95;
const float GR_DENSITY 	= 0.5;
const float GR_EXPOSURE = 0.2;
const int GR_SAMPLES 	= 32;

#endif

uniform vec3 sunPosition;
uniform float aspectRatio;
uniform float displayWidth;
uniform float displayHeight;
uniform float near;
uniform float far;
uniform int worldTime;

uniform sampler2D sampler0;
uniform sampler2D sampler1;
uniform sampler2D sampler2;

vec2 getDepth(vec2 coord);

void main() {
    gl_FragColor = texture2D(sampler0, gl_TexCoord[0].st);
	
#ifdef GOD_RAYS

	float threshold = 0.99 * far;
	bool foreground = false;
	vec2 depth = getDepth(gl_TexCoord[0].st);

	if ((worldTime < 14000 || worldTime > 22000)&& sunPosition.z < 0 && depth.x < threshold && depth.y < 0.0)
	{
		vec2 lightPos = sunPosition.xy / -sunPosition.z;
		lightPos.y *= aspectRatio; 
		lightPos = (lightPos + 1.0)/2.0;
		vec2 texCoord = gl_TexCoord[0].st;
		vec2 delta = (texCoord - lightPos) * GR_DENSITY / float(GR_SAMPLES);
		float decay = -sunPosition.z / 100.0;
		
		vec3 color = vec3(0.0);
		
		for (int i = 0; i < GR_SAMPLES; i++)
		{
			texCoord -= delta;
			if (texCoord.x < 0.0 || texCoord.x > 1.0) {
				if (texCoord.y < 0.0 || texCoord.y > 1.0) {
					break;
				}
			}
			vec3 sample = vec3(0.0);
			if (getDepth(texCoord).x > threshold) sample = texture2D(sampler0, texCoord).rgb;
			sample *= decay;
			if (distance(texCoord, lightPos) > 0.05) sample *= 0.2;
			color += sample;
			decay *= GR_DECAY;
		}
		
		gl_FragColor = (gl_FragColor + GR_EXPOSURE * vec4(color, 0.0));
	}

#endif
	
#ifdef GAMMA
    if (gl_FragColor[3] == 0.0) {
        gl_FragColor = gl_Fog.color;
    }
    else {
        gl_FragColor.rgb = pow(gl_FragColor.rgb, vec3(1.0/GAMMA));
    }
#endif
}

vec2 getDepth(vec2 coord) {
	float depth = texture2D(sampler1, coord).x;
	float depth2 = texture2D(sampler2, coord).x;
	float fg = -1.0;
	if (depth2 < 1.0) {
		depth = depth2;
		fg = 1.0;
	}
	
    return vec2(2.0 * near * far / (far + near - (2.0 * depth - 1.0) * (far - near)), fg);
}