# ImmersiveShaders
![Alt text](/screenshots/preview.png?raw=true "Optional Title")
- !! Shader is not yet claimed for release or distribution !!
- Current Version: 1.0_test
# Features & Functions
>You can setup all values/functions.
### ScreenSpace
- LightShafts (Godrays/Creespecular)
- Bloom
- Vignette
- Tonemapping (Uncharted2TonemapOp/reinhard)
- Crossprocess
- Motion Blur
- RainDrops
- FilmGrain
- Cinematic Border
- RainDesaturation
- Chromation Abberation
- FXAA
- Eye Adaptation
### WorldSpace
- Shadows
- Volumetric Fog
- Custom Lighting
- CustomVanillaSkyRendering
- Custom Atmosphere
- Water
- Screen Space Reflections
- Waving Stuff
- Fog
- Ground Dynamic Fog
- Clouds
- Stars
- Specular Lighting
- Gradient Terrain
- Rain
- Rain Puddles
- Fake Shadows
- Fake Caustic
# Desription/Changelog
ImmersiveShaders - this project focused on good optimization and flexible customization.
Without LightShafts with mc max settings with 10 chunk: fps 100-150 (videocard gtx 1050 ti).
### Problems
 - Worldtime.
 - etc.
 - You can report of bug to my discord: Quiet#8987
### Planing
- RSM
- Better Water
- Atmosphere Scattering
- Light Flickr
- Optimization
### BufferUsage
- colortex1 - Normals
- colortex2 - Lightmap
- colortex5 - WaterNormals
- colortex7 - WaterOpaqueMask
- colortex7 - WaterColorGbuffer
- final - PostProcces
- composite - general,volumetric, specular, water, puddles
- composite1 - fog
- composite2 - sky, stars, clouds
- composite3 - auto exposition
- composite7 - fog
### Credits
ImmersiveShaders/Summertime by RetroMaidRage
some effect from shadertoy or other shaders
-if my shader have code from your shader, and you don't like this, tell me =)
