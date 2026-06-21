#version 120
/* gbuffers_skytextured.fsh - SpectreV
   Sun/moon discs. We boost the sun a little so it blooms nicely, and keep it
   unlit (materialID 5). */

#include "/lib/common.glsl"

/* DRAWBUFFERS:012 */

varying vec2 texcoord;
varying vec4 vColor;

uniform sampler2D texture;

void main(){
    vec4 c = texture2D(texture, texcoord) * vColor;
    if(c.a < 0.05) discard;
    c.rgb *= 2.0;                                 // give the disc HDR punch for bloom

    gl_FragData[0] = vec4(c.rgb, c.a);
    gl_FragData[1] = vec4(0.5, 0.5, 0.0, 5.0);
    gl_FragData[2] = vec4(0.0, 1.0, 1.0, 1.0);   // unlit
}
