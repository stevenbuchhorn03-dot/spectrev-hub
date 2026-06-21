#version 120
/* gbuffers_basic.fsh - SpectreV
   Writes flat colour; marked materialID 0.0 so deferred lighting leaves it
   mostly untouched (outlines should stay crisp/unlit). */

#include "/lib/common.glsl"

/* DRAWBUFFERS:012 */

varying vec4 vColor;
varying vec2 lmcoord;

void main(){
    gl_FragData[0] = vColor;
    gl_FragData[1] = vec4(0.5, 0.5, 0.0, 0.0);   // neutral normal, materialID 0 (unlit)
    gl_FragData[2] = vec4(lmcoord, 1.0, 1.0);    // flag .w = 1 -> skip deferred lighting
}
