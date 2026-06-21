/* ============================================================================
   SpectreV  -  lib/common.glsl
   ----------------------------------------------------------------------------
   Math / encoding helpers shared by every program: normal packing, depth ->
   position reconstruction, luminance, sRGB<->linear, etc.
   ========================================================================== */

#ifndef COMMON_GLSL
#define COMMON_GLSL

#include "/lib/settings.glsl"

/* --- Luminance (Rec.709) ------------------------------------------------- */
float luma(vec3 c){ return dot(c, vec3(0.2126, 0.7152, 0.0722)); }

/* --- Gamma <-> linear ---------------------------------------------------- */
/* Minecraft textures are sRGB; we work in linear light then convert back. */
vec3 toLinear(vec3 c){ return pow(c, vec3(2.2)); }
vec3 toGamma (vec3 c){ return pow(c, vec3(1.0/2.2)); }

/* --- Spheremap normal encode/decode (store a full 3D normal in RG) -------
   CryEngine "Spheremap Transform": handles the whole sphere (z in -1..1),
   cheap, and the decode exactly inverts the encode. We only spend 2 channels
   of colortex1 so .z/.w stay free for smoothness + materialID. */
vec2 encodeNormal(vec3 n){
    float p = sqrt(n.z * 8.0 + 8.0);
    return n.xy / p + 0.5;
}
vec3 decodeNormal(vec2 enc){
    vec2 fenc = enc * 4.0 - 2.0;
    float f = dot(fenc, fenc);
    float g = sqrt(1.0 - f / 4.0);
    vec3 n;
    n.xy = fenc * g;
    n.z  = 1.0 - f / 2.0;
    return n;
}

/* --- Depth -> view-space position --------------------------------------- */
/* Needs the inverse projection matrix and the screen-space uv + raw depth.  */
vec3 screenToView(vec2 uv, float depth, mat4 invProj){
    vec3 ndc = vec3(uv, depth) * 2.0 - 1.0;       // [0,1] -> [-1,1]
    vec4 view = invProj * vec4(ndc, 1.0);
    return view.xyz / view.w;                       // perspective divide
}

/* --- View -> world (needs gbufferModelViewInverse) ----------------------- */
vec3 viewToWorld(vec3 viewPos, mat4 mvInv){
    return (mvInv * vec4(viewPos, 1.0)).xyz;
}

/* --- Schlick Fresnel ----------------------------------------------------- */
float fresnelSchlick(float cosTheta, float F0){
    return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

/* --- Henyey-Greenstein phase (forward scattering for sun in fog/clouds) -- */
float hgPhase(float cosT, float g){
    float g2 = g * g;
    return (1.0 - g2) / (4.0 * PI * pow(1.0 + g2 - 2.0 * g * cosT, 1.5));
}

/* --- Simple saturation/contrast operators -------------------------------- */
vec3 applySaturation(vec3 c, float s){
    float l = luma(c);
    return mix(vec3(l), c, s);
}
vec3 applyContrast(vec3 c, float k){
    return (c - 0.5) * k + 0.5;
}

#endif // COMMON_GLSL
