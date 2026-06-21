/* ============================================================================
   SpectreV  -  lib/tonemap.glsl
   ----------------------------------------------------------------------------
   HDR -> LDR tone mapping (ACES filmic, or Reinhard fallback) plus a small
   cinematic colour-grade (temperature, lift, contrast, saturation, vignette).
   ========================================================================== */

#ifndef TONEMAP_GLSL
#define TONEMAP_GLSL

#include "/lib/settings.glsl"
#include "/lib/common.glsl"

/* ACES filmic approximation (Stephen Hill / Narkowicz fit).
   Operates on linear HDR colour, returns linear LDR-ish colour.            */
vec3 acesFilmic(vec3 x){
    const mat3 m1 = mat3(
        0.59719, 0.07600, 0.02840,
        0.35458, 0.90834, 0.13383,
        0.04823, 0.01566, 0.83777);
    const mat3 m2 = mat3(
         1.60475, -0.10208, -0.00327,
        -0.53108,  1.10813, -0.07276,
        -0.07367, -0.00605,  1.07602);
    vec3 v = m1 * x;
    vec3 a = v * (v + 0.0245786) - 0.000090537;
    vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
    return clamp(m2 * (a / b), 0.0, 1.0);
}

/* Reinhard (extended) fallback. */
vec3 reinhard(vec3 x){
    return x / (1.0 + x);
}

/* Colour-temperature shift. t<0 cooler, t>0 warmer. */
vec3 colorTemperature(vec3 c, float t){
    vec3 warm = vec3(1.06, 1.00, 0.92);
    vec3 cool = vec3(0.92, 1.00, 1.08);
    vec3 tint = mix(vec3(1.0), (t > 0.0 ? warm : cool), abs(t));
    return c * tint;
}

/* Full post pipeline applied in final.fsh. Input/Output: linear colour. */
vec3 cinematicGrade(vec3 color){
    color *= EXPOSURE;

#ifdef TONEMAP_ACES
    color = acesFilmic(color);
#else
    color = reinhard(color);
#endif

    // grade
    color = colorTemperature(color, COLOR_TEMP);
    color += LIFT;                              // raise shadows
    color = applyContrast(color, CONTRAST);
    color = applySaturation(color, SATURATION);

    return clamp(color, 0.0, 1.0);
}

#endif // TONEMAP_GLSL
