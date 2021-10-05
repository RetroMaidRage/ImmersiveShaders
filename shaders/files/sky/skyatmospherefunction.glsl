/*
    Atmospheric scattering function.
    Look into "Common" tab for more info.
*/
vec3 atmospheric_scattering(vec3 r0, vec3 r, vec3 pSun, as_data atmosphere)
{
    //Inverted steps
    float scattering_steps = 1.0 / float(AS_ISTEPS);
    float transmittance_steps = 1.0 / float(AS_JSTEPS);

    // Calculate the step size of the primary ray.
    vec2 p = rsi(r0, r, atmosphere.rAtmos);

    // Bleh bleh another intersection
    vec2 isect_planet = rsi(r0, r, atmosphere.rPlanet);

    // Ray starts inside the planet -> return 0
    if (isect_planet.x < 0.0 && isect_planet.y >= 0.0 && p.x > p.y || p.y < 0.0)
        return vec3(0.0, 0.0, 0.0);

    // Treat intersection of the planet in negative t as if the planet had not
    // been intersected at all.
    bool planet_intersected = (isect_planet.x < isect_planet.y && isect_planet.x > 0.0);

    // Always start atmosphere ray at viewpoint if we start inside atmosphere
    p.x = max(p.x, 0.0);

    // If the planet is intersected, set the end of the ray to the planet
    // surface.
    p.y = planet_intersected ? isect_planet.y : p.y;

    // Step size
    float iStepSize = (p.y - p.x) * scattering_steps;

    // Initialize the primary ray time.
    float iTime = 0.0;

    // Initialize accumulators for Rayleigh and Mie scattering.
    vec3 totalRlh = vec3(0.0, 0.0, 0.0);
    vec3 totalMie = vec3(0.0, 0.0, 0.0);

    // Initialize optical depth accumulators for the primary ray.
    float iOdRlh = 0.0;
    float iOdMie = 0.0;
    float iOdOzo = 0.0;

    // Calculate the Rayleigh and Mie phases.
    float VL = max(dot(r, pSun), 0.0);
    float pRlh = phase_rayleigh(VL);
    float pMie = phase_mie(VL, atmosphere.gMie);

    // Sample the primary (view) ray.
    for (int scattering = 0; scattering < AS_ISTEPS; scattering++)
	{
        // Calculate the primary (view) ray sample position.
        vec3 iPos = r0 + r * (iTime + iStepSize * 0.5);

        // Calculate the height of the sample.
        float iHeight = length(iPos) - atmosphere.rPlanet;

        // Get densities
        vec3 iDensity = get_densities(iHeight, atmosphere);

        // Calculate the optical depth of the Rayleigh, Mie scattering and Ozone for this step.
        float odStepRlh = iDensity.x * iStepSize; //Rayleigh
        float odStepMie = iDensity.y * iStepSize; //Mie
        float odStepOzo = iDensity.z * iStepSize; //Ozone

        // Accumulate optical depth.
        iOdRlh += odStepRlh;
        iOdMie += odStepMie;
        iOdOzo += odStepOzo;

        // Calculate the step size of the secondary (light) ray.
        float jStepSize = rsi(iPos, pSun, atmosphere.rAtmos).y * transmittance_steps;

        // Initialize the secondary (light) ray time.
        float jTime = 0.0;

        // Initialize optical depth accumulators for the secondary (light) ray.
        float jOdRlh = 0.0; //Rayleigh light optical depth
        float jOdMie = 0.0; //Mie light optical depth
        float jOdOzo = 0.0; //Ozone light optical depth

        // Sample the secondary ray.
        for (int transmittance = 0; transmittance < AS_JSTEPS; transmittance++)
		{
            // Calculate the secondary ray sample position.
            vec3 jPos = iPos + pSun * (jTime + jStepSize * 0.5);

            // Calculate the height of the sample.
            float jHeight = length(jPos) - atmosphere.rPlanet;

            // Get densities
            vec3 jDensity = get_densities(jHeight, atmosphere);

            // Accumulate the optical depth.
            jOdRlh += jDensity.x * jStepSize; //Rayleigh
            jOdMie += jDensity.y * jStepSize; //Mie
            jOdOzo += jDensity.z * jStepSize; //Ozone

            // Increment the secondary ray time.
            jTime += jStepSize;
        }

        // Calculate attenuation.
        vec3 attRlh = atmosphere.kRlh * (iOdRlh + jOdRlh); // Rayleigh scattering attenuation
        vec3 attMie = atmosphere.kMie[0] * (iOdMie + jOdMie); // Mie scattering attenuation
        vec3 attOzo = atmosphere.kOzo * (iOdOzo + jOdOzo); // Ozone absorption attenuation

        // Complete attenuation.
        vec3 totalAtt = exp(-(attRlh + attMie + attOzo));

        // Accumulate scattering.
        totalRlh += odStepRlh * totalAtt;
        totalMie += odStepMie * totalAtt;

        // Increment the primary ray time.
        iTime += iStepSize;

    }

    // Calculate and return the final color.
    return atmosphere.iSun * (pRlh * atmosphere.kRlh * totalRlh + pMie * atmosphere.kMie[1] * totalMie);
}

/*
    You can make different function like this one
    for example a new one to simulate Mars atmosphere
*/
vec3 get_sky_color(vec3 ray_origin, vec3 ray_direction, vec3 light_direction)
{
    //Initialize data struct
    as_data atmosphere;

    //Planet
    atmosphere.rPlanet = 6371e3; //Planet radius
    atmosphere.rAtmos = 6471e3; //Atmosphere radius

    //Rayleigh
    atmosphere.kRlh = vec3(5.8e-6, 13.3e-6, 33.31e-6); //Rayleigh coefficient
    atmosphere.shRlh = 8e3; //Rayleigh height

    //Mie
    atmosphere.kMie = mat2x3(vec3(21e-6), vec3(21e-6) * 0.9); //Mie coefficients (extinction and scattering. Mie albedo is 0.9)
    atmosphere.shMie = 1.2e3; //Mie height
    atmosphere.gMie = 0.76; //Mie 'g' term

    //Ozone
    atmosphere.kOzo = vec3(3.426e-7, 8.298e-7, 0.356e-7); //Ozone coefficient

    //Sun intensity
    atmosphere.iSun = 22.0; //Just sun intensity

    //Output
	return atmospheric_scattering(ray_origin, ray_direction, light_direction, atmosphere);
}

/*
    Render atmosphere scattering into cubemap
*/
void mainCubemap( out vec4 fragColor, in vec2 fragCoord, in vec3 rayOri, in vec3 rayDir )
{
    //Ray origin
    vec3 ray_origin = vec3(0.0, 6371e3, 0.0);

    //Ray direction
    vec3 ray_direction = rayDir;

    //A bit dynamic light direction
    vec3 light_direction = normalize(vec3(0.0, sin(iTime) * 0.5 + 0.5, 1.0));

    //Get atmosphere
    vec3 color = get_sky_color(ray_origin, ray_direction, light_direction);

    //Output
    fragColor = vec4(color,1.0);
}
