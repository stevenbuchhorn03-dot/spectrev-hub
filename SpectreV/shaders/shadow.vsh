#version 120
/* ============================================================================
   shadow.vsh  -  SpectreV
   ----------------------------------------------------------------------------
   Renders the scene from the SUN's point of view to build the shadow map.
   We apply the same cubic distortion the sampling code expects (see
   lib/shadows.glsl distortShadowClip) so near-camera texels get more density.
   ========================================================================== */

#include "/lib/settings.glsl"

varying vec2 texcoord;
varying vec4 vColor;

float distortFactor(vec2 p){
    float d = length(p);
    return mix(1.0, d, 0.9) + 0.1;
}

void main(){
    vec4 pos = ftransform();
    pos.xy /= distortFactor(pos.xy);   // match sampling-side distortion
    gl_Position = pos;

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vColor   = gl_Color;
}
