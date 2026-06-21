/* ============================================================================
   SpectreV  -  lib/noise.glsl
   ----------------------------------------------------------------------------
   Hash + value noise + fbm used by clouds, water waves, caustics and grain.
   All cheap, GPU-friendly, no textures required.
   ========================================================================== */

#ifndef NOISE_GLSL
#define NOISE_GLSL

/* --- Hashes -------------------------------------------------------------- */
float hash11(float p){
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}
float hash12(vec2 p){
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}
float hash13(vec3 p3){
    p3 = fract(p3 * 0.1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return fract((p3.x + p3.y) * p3.z);
}

/* --- 2D value noise ------------------------------------------------------ */
float vnoise2(vec2 p){
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);                 // smoothstep interpolation
    float a = hash12(i + vec2(0.0, 0.0));
    float b = hash12(i + vec2(1.0, 0.0));
    float c = hash12(i + vec2(0.0, 1.0));
    float d = hash12(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

/* --- 3D value noise (for volumetric clouds) ------------------------------ */
float vnoise3(vec3 p){
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float n000 = hash13(i + vec3(0,0,0));
    float n100 = hash13(i + vec3(1,0,0));
    float n010 = hash13(i + vec3(0,1,0));
    float n110 = hash13(i + vec3(1,1,0));
    float n001 = hash13(i + vec3(0,0,1));
    float n101 = hash13(i + vec3(1,0,1));
    float n011 = hash13(i + vec3(0,1,1));
    float n111 = hash13(i + vec3(1,1,1));
    float nx00 = mix(n000, n100, f.x);
    float nx10 = mix(n010, n110, f.x);
    float nx01 = mix(n001, n101, f.x);
    float nx11 = mix(n011, n111, f.x);
    float nxy0 = mix(nx00, nx10, f.y);
    float nxy1 = mix(nx01, nx11, f.y);
    return mix(nxy0, nxy1, f.z);
}

/* --- Fractal Brownian Motion (layered noise) ----------------------------- */
float fbm2(vec2 p, int oct){
    float v = 0.0, a = 0.5;
    for(int i = 0; i < oct; i++){
        v += a * vnoise2(p);
        p *= 2.02;
        a *= 0.5;
    }
    return v;
}
float fbm3(vec3 p, int oct){
    float v = 0.0, a = 0.5;
    for(int i = 0; i < oct; i++){
        v += a * vnoise3(p);
        p *= 2.03;
        a *= 0.5;
    }
    return v;
}

#endif // NOISE_GLSL
