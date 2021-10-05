#version 120

uniform sampler2D lightmap;
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec2 TexCoords;
varying vec2 LightmapCoords;
//varying vec3 Normal;
varying vec4 Color;
uniform vec4 entityColor;
// The texture atlas
uniform sampler2D texture;
uniform vec3 sunPosition;
uniform sampler2D colortex1;

void main(){
	    vec3 Normal = normalize(texture2D(colortex1, TexCoords).rgb * 2.0f - 1.0f);

  float NdotL = max(dot(Normal, normalize(sunPosition)), 0.0f);

    vec4 Albedo = texture2D(texture, TexCoords) * Color;

		vec4 color = texture2D(texture, texcoord) * glcolor;
		color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
		color *= texture2D(lightmap, lmcoord);
	vec4	 entitycolorfinal = color + NdotL;
		gl_FragData[0] = color*1.2;
   gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
   gl_FragData[2] = vec4(LightmapCoords, 0.0f, 1.0f);
}
