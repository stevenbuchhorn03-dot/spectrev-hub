#version 120
/* ============================================================================
   composite2.fsh  -  SpectreV   (BLOOM pass B: vertical blur)
   ----------------------------------------------------------------------------
   Vertical Gaussian over colortex4, output -> colortex5. final.fsh adds it
   back over the scene.
   ========================================================================== */

#include "/lib/common.glsl"

/* DRAWBUFFERS:5 */

varying vec2 texcoord;

uniform sampler2D colortex4;
uniform float viewHeight;

void main(){
#ifndef BLOOM
    gl_FragData[0] = vec4(0.0); return;
#else
    float texel = 1.0 / viewHeight;
    float w[5];
    w[0]=0.227027; w[1]=0.1945946; w[2]=0.1216216; w[3]=0.054054; w[4]=0.016216;

    vec3 sum = texture2D(colortex4, texcoord).rgb * w[0];
    for(int i = 1; i < 5; i++){
        vec2 off = vec2(0.0, texel * float(i) * 2.0);
        sum += texture2D(colortex4, texcoord + off).rgb * w[i];
        sum += texture2D(colortex4, texcoord - off).rgb * w[i];
    }
    gl_FragData[0] = vec4(sum, 1.0);
#endif
}
