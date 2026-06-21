/* ============================================================================
   SpectreV  -  lib/shadows.glsl
   ----------------------------------------------------------------------------
   Shadow-map sampling with bias + PCF soft edges. Used by the deferred
   lighting pass.

   Relies on (declared by the including program):
     uniform sampler2D   shadowtex0;   // depth (everything)
     uniform sampler2D   shadowtex1;   // depth (opaque only) - for coloured shadows
     uniform sampler2D   shadowcolor0; // colour of translucent shadow casters
     uniform mat4        shadowProjection, shadowModelView;
   ========================================================================== */

#ifndef SHADOWS_GLSL
#define SHADOWS_GLSL

#include "/lib/settings.glsl"

/* Bias the shadow clip coords toward the centre of the shadow frustum.
   Minecraft shadow maps use a distortion so near-camera detail gets more
   texels; we replicate the standard cubic distortion OptiFine expects. */
float distortFactor(vec2 p){
    float d = length(p);
    return mix(1.0, d, 0.9) + 0.1;   // gentle distortion
}
vec3 distortShadowClip(vec3 clip){
    clip.xy /= distortFactor(clip.xy);
    return clip;
}

/* Convert a world-space position to shadow-map [0,1] space. */
vec3 worldToShadow(vec3 worldPos, mat4 shadowMV, mat4 shadowProj){
    vec4 sc = shadowProj * (shadowMV * vec4(worldPos, 1.0));
    sc.xyz = distortShadowClip(sc.xyz);
    return sc.xyz * 0.5 + 0.5;       // -> [0,1]
}

/* Rotated-grid PCF. Returns 0 (fully shadowed) .. 1 (fully lit). */
float samplePCF(sampler2D shadowDepth, vec3 shadowPos, float nDotL){
    // Slope-scaled bias: surfaces facing away from sun need more bias.
    float bias = SHADOW_BIAS * (1.0 + (1.0 - nDotL) * 6.0);

    float texel = 1.0 / float(shadowMapResolution);
    float radius = texel * (1.0 + SHADOW_SOFTNESS * 3.0);

    // Per-pixel rotation so the PCF kernel dithers instead of banding.
    float ang = fract(sin(dot(gl_FragCoord.xy, vec2(12.9898, 78.233))) * 43758.5453) * TAU;
    mat2 rot = mat2(cos(ang), -sin(ang), sin(ang), cos(ang));

    float sum = 0.0;
    float count = 0.0;
    for(int x = -SHADOW_SAMPLES; x <= SHADOW_SAMPLES; x++){
        for(int y = -SHADOW_SAMPLES; y <= SHADOW_SAMPLES; y++){
            vec2 off = rot * (vec2(x, y) * radius);
            float d = texture2D(shadowDepth, shadowPos.xy + off).r;
            sum += step(shadowPos.z - bias, d);   // 1 if lit
            count += 1.0;
        }
    }
    return sum / count;
}

/* Full coloured shadow: opaque blocks cast solid shadow, translucent casters
   (stained glass, water) tint the light passing through them. */
vec3 getShadow(vec3 worldPos, float nDotL,
               sampler2D sdepth0, sampler2D sdepth1, sampler2D scolor0,
               mat4 shadowMV, mat4 shadowProj){

    vec3 sp = worldToShadow(worldPos, shadowMV, shadowProj);

    // Outside the shadow frustum -> assume lit.
    if(sp.x < 0.0 || sp.x > 1.0 || sp.y < 0.0 || sp.y > 1.0 || sp.z > 1.0)
        return vec3(1.0);

    float litAll    = samplePCF(sdepth0, sp, nDotL); // includes translucents
    float litOpaque = samplePCF(sdepth1, sp, nDotL); // opaque only

    // Where opaque says lit but "all" says shadowed -> a translucent caster
    // is between us and the sun: tint by its colour instead of full black.
    vec3 tint = texture2D(scolor0, sp.xy).rgb;
    float translucent = clamp(litOpaque - litAll, 0.0, 1.0);
    vec3 colored = mix(vec3(litAll), tint * litOpaque, translucent);

    // Soft fade at the edge of the shadow distance so it doesn't pop.
    float edge = 1.0 - smoothstep(0.7, 1.0, length(sp.xy * 2.0 - 1.0));
    return mix(vec3(1.0), colored, edge);
}

#endif // SHADOWS_GLSL
