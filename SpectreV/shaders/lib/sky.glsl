/* ============================================================================
   SpectreV  -  lib/sky.glsl
   ----------------------------------------------------------------------------
   Physically-plausible-ish sky gradient + time-of-day sun colour.
   Not a full Bruneton/Hosek model (too heavy) but tuned to read as realistic
   and to drive golden-hour warmth at sunrise/sunset.

   Relies on these OptiFine/Iris uniforms (declared by the including program):
     uniform vec3  sunPosition;        // view-space
     uniform vec3  upPosition;         // view-space
     uniform float sunAngle;           // 0..1 over a full day
     uniform mat4  gbufferModelViewInverse;
   ========================================================================== */

#ifndef SKY_GLSL
#define SKY_GLSL

#include "/lib/settings.glsl"
#include "/lib/common.glsl"

/* World-space sun direction (y>0 = above horizon). Caller passes the
   view-space sunPosition transformed to world via gbufferModelViewInverse. */
vec3 getSunDirWorld(vec3 sunPosView, mat4 mvInv){
    return normalize(mat3(mvInv) * sunPosView);
}

/* How high the sun is, 0 at horizon, 1 at zenith, negative at night. */
float sunElevation(vec3 sunDirWorld){
    return sunDirWorld.y;
}

/* Direct sun colour as a function of elevation.
   High noon  -> near-white, slightly warm.
   Horizon    -> deep orange/red (Rayleigh extinction of blue).            */
vec3 sunColor(float elev){
    float t = clamp(elev, 0.0, 1.0);
    // base daylight colour
    vec3 noon    = vec3(1.00, 0.97, 0.92);
    vec3 horizon = vec3(1.00, 0.45, 0.18);
    // blend, biased so the warm range dominates near the horizon
    float k = smoothstep(0.0, 0.35, t);
    vec3 col = mix(horizon, noon, k);
    // extra golden-hour push
    float golden = (1.0 - k) * GOLDEN_HOUR_WARMTH;
    col += vec3(0.25, 0.08, -0.05) * golden;
    return col * SUN_INTENSITY * smoothstep(-0.08, 0.06, elev); // fade out below horizon
}

/* Ambient sky colour (used as fill light). Cool up high, warm near horizon. */
vec3 skyAmbient(float elev){
    float day = smoothstep(-0.05, 0.25, elev);
    vec3 dayCol   = vec3(0.45, 0.62, 0.95);   // blue daytime ambient
    vec3 nightCol = vec3(0.04, 0.06, 0.12);   // moonlit blue
    vec3 col = mix(nightCol, dayCol, day);
    return col * mix(NIGHT_BRIGHTNESS, SKY_INTENSITY, day);
}

/* Procedural sky dome colour for a given view ray (world space). */
vec3 skyGradient(vec3 viewDirWorld, vec3 sunDirWorld){
    float up  = clamp(viewDirWorld.y * 0.5 + 0.5, 0.0, 1.0);
    float elev = sunDirWorld.y;

    // Vertical gradient: horizon -> zenith
    vec3 zenith  = mix(vec3(0.02,0.03,0.07), vec3(0.18,0.34,0.62), smoothstep(-0.1,0.3,elev));
    vec3 horizon = mix(vec3(0.05,0.06,0.10), vec3(0.62,0.70,0.86), smoothstep(-0.1,0.3,elev));
    vec3 sky = mix(horizon, zenith, pow(up, 0.55));

    // Sun disc + glow (Mie forward scattering)
    float cosSun = clamp(dot(normalize(viewDirWorld), sunDirWorld), 0.0, 1.0);
    float glow   = pow(cosSun, 8.0) * 0.6 + pow(cosSun, 256.0) * 4.0;
    sky += sunColor(elev) * glow * 0.4;

    // Warm the horizon band toward the sun at golden hour
    float horizGlow = pow(cosSun, 4.0) * (1.0 - up) * GOLDEN_HOUR_WARMTH;
    sky += vec3(0.9, 0.4, 0.15) * horizGlow * (1.0 - smoothstep(0.0, 0.4, elev));

    return sky * SKY_INTENSITY;
}

#endif // SKY_GLSL
