#version 120
/* ============================================================================
   composite1.fsh  -  SpectreV   (BLOOM pass A: bright extract + H blur)
   ----------------------------------------------------------------------------
   Extract pixels brighter than BLOOM_THRESHOLD, then 9-tap horizontal Gaussian.
   Output -> colortex4.
   ========================================================================== */

#include "/lib/common.glsl"

/* DRAWBUFFERS:4 */

varying vec2 texcoord;

uniform sampler2D colortex0;
uniform float viewWidth;

vec3 brightPass(vec2 uv){
    vec3 c = texture2D(colortex0, uv).rgb;
    float l = luma(c);
    float k = max(l - BLOOM_THRESHOLD, 0.0) / max(l, 1e-4);
    return c * k;
}

void main(){
#ifndef BLOOM
    gl_FragData[0] = vec4(0.0); return;
#else
    float texel = 1.0 / viewWidth;
    // Gaussian weights (sigma ~2)
    float w[5];
    w[0]=0.227027; w[1]=0.1945946; w[2]=0.1216216; w[3]=0.054054; w[4]=0.016216;

    vec3 sum = brightPass(texcoord) * w[0];
    for(int i = 1; i < 5; i++){
        vec2 off = vec2(texel * float(i) * 2.0, 0.0);
        sum += brightPass(texcoord + off) * w[i];
        sum += brightPass(texcoord - off) * w[i];
    }
    gl_FragData[0] = vec4(sum, 1.0);
#endif
}
