#version 120
/* gbuffers_skybasic.fsh - SpectreV
   Output a placeholder sky colour and tag it as sky (materialID 5, unlit).
   composite.fsh detects sky pixels (depth == far) and replaces them with the
   full procedural sky + clouds + god rays. */

#include "/lib/common.glsl"

/* DRAWBUFFERS:012 */

varying vec4 vColor;

void main(){
    gl_FragData[0] = vec4(vColor.rgb, 1.0);
    gl_FragData[1] = vec4(0.5, 0.5, 0.0, 5.0);   // materialID 5 = sky
    gl_FragData[2] = vec4(0.0, 1.0, 1.0, 1.0);   // flag unlit
}
