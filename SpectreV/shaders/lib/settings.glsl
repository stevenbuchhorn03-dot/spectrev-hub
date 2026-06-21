/* ============================================================================
   SpectreV  -  lib/settings.glsl
   ----------------------------------------------------------------------------
   Central place for ALL user-tweakable values and pipeline-wide constants.
   This file is #included by (almost) every program, so anything you change
   here propagates across the whole pack.

   The lines marked  // [GUI] ...  are ALSO surfaced in shaders.properties so
   they appear as sliders/toggles inside the in-game Iris/OptiFine shader menu.
   Editing them here changes the *default*; editing them in-game overrides it.
   ========================================================================== */

#ifndef SETTINGS_GLSL
#define SETTINGS_GLSL

/* ----------------------------------------------------------------------------
   0. GBUFFER / COLORTEX FORMATS
   ----------------------------------------------------------------------------
   OptiFine/Iris read these const declarations to decide the internal format of
   each color attachment. We want HDR (16F) for anything carrying lighting so
   bloom & tonemapping have headroom and don't band.
---------------------------------------------------------------------------- */
const int colortex0Format = RGBA16F;  // Scene color (HDR, linear)
const int colortex1Format = RGBA16F;  // Encoded world-space normal + smoothness
const int colortex2Format = RGBA16F;  // Lightmap (block,sky) + material id + AO
const int colortex3Format = RGBA16F;  // SSAO / scratch
const int colortex4Format = RGBA16F;  // Bloom mips / scratch
const int colortex5Format = RGBA16F;  // Bloom mips / scratch
const int colortex6Format = RGBA16F;  // God-ray buffer

/* Keep history-less buffers from being cleared can be done via *Clear flags,
   but we recompute every frame so defaults are fine. */

/* ----------------------------------------------------------------------------
   1. SHADOWS                                            // GPU cost: MEDIUM
---------------------------------------------------------------------------- */
/* NOTE on the `// [a b c]` comments below: that bracketed list is the exact
   syntax OptiFine/Iris parse to build the menu control (selectable values /
   slider stops). The FIRST value is not special — the active value is the one
   after `=` / on the #define. Edit the number to change the default. */
const int   shadowMapResolution = 2048;   // [512 1024 2048 4096]
const float shadowDistance      = 160.0;  // [64.0 96.0 128.0 160.0 224.0 320.0]
#define SHADOW_SOFTNESS    1.6   // [0.0 0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0]  PCF radius: 0 hard, higher softer
#define SHADOW_SAMPLES     2     // [1 2 3]  PCF half-width. taps = (2N+1)^2. 2 -> 25 taps
#define SHADOW_BIAS        0.0006 // [0.0002 0.0004 0.0006 0.0008 0.0012 0.0020]  raise if acne, lower if peter-panning
#define SHADOW_BRIGHTNESS  0.18  // [0.0 0.1 0.18 0.3 0.45 0.6]  ambient fill kept inside shadows

/* ----------------------------------------------------------------------------
   2. SUN / SKY / ATMOSPHERE
---------------------------------------------------------------------------- */
#define SUN_INTENSITY      4.2   // [1.0 2.0 3.0 4.2 5.0 6.0 8.0]
#define SKY_INTENSITY      1.4   // [0.5 1.0 1.4 2.0 3.0 4.0]
#define GOLDEN_HOUR_WARMTH 1.0   // [0.0 0.5 1.0 1.5 2.0]
#define NIGHT_BRIGHTNESS   0.05  // [0.0 0.02 0.05 0.1 0.2 0.3]

/* ----------------------------------------------------------------------------
   3. VOLUMETRIC GOD RAYS / LIGHT SHAFTS                 // GPU cost: HIGH
---------------------------------------------------------------------------- */
#define GODRAYS                  // comment-out to disable entirely
#define GODRAY_SAMPLES     24    // [8 12 16 24 32 48]  march steps
#define GODRAY_INTENSITY   0.55  // [0.0 0.25 0.55 1.0 1.5 2.0]
#define GODRAY_DECAY       0.96  // [0.90 0.93 0.96 0.98]  per-step falloff

/* ----------------------------------------------------------------------------
   4. VOLUMETRIC CLOUDS                                  // GPU cost: HIGH
---------------------------------------------------------------------------- */
#define VOLUMETRIC_CLOUDS       // comment-out for vanilla clouds only
#define CLOUD_STEPS        20    // [8 12 16 20 28 40]  raymarch steps through slab
#define CLOUD_DENSITY      0.55  // [0.0 0.25 0.4 0.55 0.7 1.0 1.5]  coverage/opacity
#define CLOUD_HEIGHT       260.0 // [180.0 220.0 260.0 320.0]  base altitude (world Y)
#define CLOUD_THICKNESS    90.0  // [40.0 60.0 90.0 130.0]  vertical extent
#define CLOUD_SPEED        1.0   // [0.0 0.5 1.0 2.0 4.0]  wind speed
#define CLOUD_SCATTER      1.3   // [0.0 0.6 1.0 1.3 2.0 3.0]  forward sun-scatter glow

/* ----------------------------------------------------------------------------
   5. WATER                                              // GPU cost: MEDIUM
---------------------------------------------------------------------------- */
#define WATER_REFLECTIONS       // screen-space reflections on water
#define SSR_STEPS          24    // [8 12 16 24 32 48]  reflection ray steps
#define WATER_CAUSTICS          // fake animated caustics
#define WATER_WAVE_HEIGHT  0.06  // [0.0 0.03 0.06 0.1 0.15 0.2]
#define WATER_FRESNEL_POW  5.0   // [2.0 3.0 4.0 5.0 6.0]  Fresnel falloff

/* ----------------------------------------------------------------------------
   6. SSAO  (screen-space ambient occlusion)            // GPU cost: MEDIUM
---------------------------------------------------------------------------- */
#define SSAO                    // toggle
#define SSAO_SAMPLES       12    // [4 6 8 12 16 24 32]
#define SSAO_RADIUS        0.6   // [0.1 0.3 0.6 1.0 1.5 2.0]  world radius
#define SSAO_STRENGTH      1.0   // [0.0 0.5 1.0 1.5 2.0]

/* ----------------------------------------------------------------------------
   7. POST: BLOOM + TONEMAP + GRADING                    // GPU cost: LOW-MED
---------------------------------------------------------------------------- */
#define BLOOM
#define BLOOM_STRENGTH     0.06  // [0.0 0.03 0.06 0.12 0.2 0.3]
#define BLOOM_THRESHOLD    1.0   // [0.5 0.8 1.0 1.5 2.0]  luminance to bloom above

#define TONEMAP_ACES            // ACES filmic. comment out for Reinhard
#define EXPOSURE           1.05  // [0.2 0.5 0.8 1.05 1.5 2.0 3.0]
#define SATURATION         1.08  // [0.0 0.5 0.8 1.0 1.08 1.3 1.6 2.0]
#define CONTRAST           1.04  // [0.5 0.8 1.0 1.04 1.2 1.5]
#define LIFT               0.00  // [-0.1 -0.05 0.0 0.02 0.05 0.1]  raises shadows
#define COLOR_TEMP         0.0   // [-1.0 -0.5 -0.2 0.0 0.2 0.5 1.0]  - cooler / + warmer
#define VIGNETTE           0.18  // [0.0 0.1 0.18 0.3 0.45 0.6]
#define FILM_GRAIN         0.012 // [0.0 0.006 0.012 0.025 0.05]

/* ----------------------------------------------------------------------------
   8. HELPERS / CONSTANTS  (don't usually need to touch)
---------------------------------------------------------------------------- */
#define PI   3.14159265358979
#define TAU  6.28318530717958
#define EPS  1e-4

#endif // SETTINGS_GLSL
