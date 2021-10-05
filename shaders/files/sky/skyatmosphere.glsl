/*
    Atmospheric scattering

    Implementation is based on @wwwtyro atmosphere scattering (it's a good start point for everyone!) which is Nishita-like.
    I tried to improve it a bit, and make it more 'complete' (as original implementation didn't used ozone absorption)

    I'm not saying it's the most accurate atmosphere in the world, but I'm pretty sure it can be good resource for someone who just
    started working on atmospheric scattering.
    There's still plenty of room for optimization, improvments.


    Feel free to fork this shader, if you do so - send a link to your work in comments!

    References:
    https://developer.nvidia.com/gpugems/gpugems2/part-ii-shading-lighting-and-shadows/chapter-16-accurate-atmospheric-scattering
    https://www.alanzucconi.com/2017/10/10/atmospheric-scattering-1/
    https://www.scratchapixel.com/lessons/procedural-generation-virtual-worlds/simulating-sky/simulating-colors-of-the-sky
    https://github.com/wwwtyro/glsl-atmosphere

    Credits:
    @wwwtyro - For initial implementation of atmospheric scattering!
    @Jessie - For Cornette-Shank phase function, and ozone density approximation!
*/

#define PI 3.141592
#define AS_ISTEPS 16 //Scattering steps
#define AS_JSTEPS 8 //Transmittance steps

/*
    Struct with data used in atmosphere scattering function
*/
struct as_data
{
	float rPlanet; //Planet radius
    float rAtmos; //Atmosphere radius

	vec3 kRlh; //Rayleigh coefficient
    float shRlh; //Rayleigh scattering height

    mat2x3 kMie; //Mie coefficients
    float shMie; //Mie scattering height
    float gMie; //g for Mie phase

	vec3 kOzo; //Ozone extinction coefficient

    float iSun; //Sun luminance
};

/*
    Rayleigh phase
*/
float phase_rayleigh(float VL)
{
    return 3.0 * (1.0 + VL * VL) / (16.0 * PI);
}

/*
    Cornette-Shank Mie phase
    Thanks Jessie!
*/
float phase_mie(float VL, float g_coeff)
{
	float g_coeff_sqr = g_coeff * g_coeff;
	float p1 = 3.0 * (1.0 - g_coeff_sqr) * (1.0 / (PI * (2.0 + g_coeff_sqr)));
	float p2 = (1.0 + (VL * VL)) * (1.0/pow((1.0 + g_coeff_sqr - 2.0 * g_coeff * VL), 1.5));

	float phase = (p1 * p2);
	phase *= 0.125;

	return max(phase, 0.0);
}

/*
    Returns density of mie/rlh/ozo
*/
vec3 get_densities(float height, as_data atmosphere)
{
    //Rayleigh density
    float densityRlh = exp(-height / atmosphere.shRlh);

    //Mie density
    float densityMie = exp(-height / atmosphere.shMie);

    //Ozone density
    float densityOzo = exp(-max(0.0, (35000.0 - height) - atmosphere.rAtmos) / 5000.0) * exp(-max(0.0, (height - 35000.0) - atmosphere.rAtmos) / 15000.0);

    //Output
    return vec3(densityRlh, densityMie, densityOzo);
}


/*
    Ray sphere intersection function
*/
vec2 rsi( vec3 p, vec3 dir, float r )
{
	float b = dot( p, dir );
	float c = dot( p, p ) - r * r;

	float d = b * b - c;
	if ( d < 0.0 ) {
		return vec2( 10000.0, -10000.0 );
	}
	d = sqrt( d );

	return vec2( -b - d, -b + d );
}

/*
    ACES approximation
*/
const mat3 ACESInputMat = mat3(
    0.59719, 0.35458, 0.04823,
    0.07600, 0.90834, 0.01566,
    0.02840, 0.13383, 0.83777
);

const mat3 ACESOutputMat = mat3(
    1.60475, -0.53108, -0.07367,
    -0.10208,  1.10813, -0.00605,
    -0.00327, -0.07276,  1.07602
);

vec3 RRTAndODTFit( in vec3 v )
{
    vec3 a = v * (v + 0.0245786) - 0.000090537;
    vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
    return a / b;
}
