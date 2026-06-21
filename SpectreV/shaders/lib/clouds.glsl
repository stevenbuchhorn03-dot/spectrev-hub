/* ============================================================================
   SpectreV  -  lib/clouds.glsl
   ----------------------------------------------------------------------------
   Lightweight volumetric clouds: raymarch a single horizontal slab of fbm
   noise, with a cheap secondary march toward the sun for self-shadowing /
   silver-lining scattering.

   Controlled by CLOUD_* in settings.glsl.
   ========================================================================== */

#ifndef CLOUDS_GLSL
#define CLOUDS_GLSL

#include "/lib/settings.glsl"
#include "/lib/noise.glsl"
#include "/lib/common.glsl"

/* Cloud density at a world-space point inside the slab. 0 = clear air. */
float cloudDensity(vec3 p, float time){
    // animate with wind
    vec3 wind = vec3(time * CLOUD_SPEED * 0.6, 0.0, time * CLOUD_SPEED * 0.25);
    vec3 q = (p + wind) * 0.0035;

    float base = fbm3(q, 4);
    // remap by coverage; higher CLOUD_DENSITY -> lower threshold -> more cloud
    float coverage = mix(0.62, 0.30, clamp(CLOUD_DENSITY, 0.0, 1.5));
    float d = smoothstep(coverage, coverage + 0.25, base);

    // soft vertical falloff so the slab has rounded tops/bottoms
    float h = (p.y - CLOUD_HEIGHT) / CLOUD_THICKNESS;     // 0..1 across slab
    float vert = smoothstep(0.0, 0.15, h) * smoothstep(1.0, 0.6, h);

    return d * vert * CLOUD_DENSITY;
}

/* Raymarch the slab along a view ray.
   Returns: rgb = scattered colour, a = transmittance-derived coverage (0..1). */
vec4 renderClouds(vec3 rayOrigin, vec3 rayDir, vec3 sunDir,
                  vec3 sunCol, vec3 skyCol, float time){
#ifndef VOLUMETRIC_CLOUDS
    return vec4(0.0);
#else
    // Only march if the ray points up enough to hit the slab.
    if(rayDir.y < 0.02) return vec4(0.0);

    // Entry/exit of the slab along the ray (planes y=CLOUD_HEIGHT and +thickness)
    float tBottom = (CLOUD_HEIGHT - rayOrigin.y) / rayDir.y;
    float tTop    = (CLOUD_HEIGHT + CLOUD_THICKNESS - rayOrigin.y) / rayDir.y;
    float tEnter  = max(min(tBottom, tTop), 0.0);
    float tExit   = max(tBottom, tTop);
    if(tExit <= tEnter) return vec4(0.0);

    float marchLen = min(tExit - tEnter, 6000.0);
    float stepLen  = marchLen / float(CLOUD_STEPS);

    // Phase: forward-scatter glow when looking toward the sun.
    float cosT  = dot(rayDir, sunDir);
    float phase = hgPhase(cosT, 0.6) * CLOUD_SCATTER + 0.15;

    float transmittance = 1.0;            // 1 = fully see-through
    vec3  scattered     = vec3(0.0);

    // small dither to hide step banding
    float jitter = hash12(gl_FragCoord.xy) * stepLen;
    float t = tEnter + jitter;

    for(int i = 0; i < CLOUD_STEPS; i++){
        vec3 pos = rayOrigin + rayDir * t;
        float dens = cloudDensity(pos, time);

        if(dens > 0.001){
            // Cheap sun-shadow: 3 taps marching toward the sun.
            float sun = 0.0;
            for(int s = 1; s <= 3; s++){
                vec3 sp = pos + sunDir * float(s) * 18.0;
                sun += cloudDensity(sp, time);
            }
            float sunTrans = exp(-sun * 0.85);     // Beer's law toward sun

            // Beer-Powder term gives clouds dark cores + bright edges
            float powder = 1.0 - exp(-dens * 2.0);
            vec3 lit = sunCol * sunTrans * phase * powder + skyCol * 0.35;

            float dT = exp(-dens * stepLen * 0.04); // Beer's law along view
            scattered += transmittance * (1.0 - dT) * lit;
            transmittance *= dT;
            if(transmittance < 0.02) break;        // fully opaque, stop early
        }
        t += stepLen;
    }

    float coverage = 1.0 - transmittance;
    return vec4(scattered, coverage);
#endif
}

#endif // CLOUDS_GLSL
