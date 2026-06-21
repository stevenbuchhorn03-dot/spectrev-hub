#version 120
/* ============================================================================
   shadow.fsh  -  SpectreV
   ----------------------------------------------------------------------------
   Writes depth automatically (shadowtex). We ALSO write the caster's colour to
   shadowcolor0 so translucent casters (stained glass, water) can tint the
   light that passes through them — that's how coloured shadows work.
   ========================================================================== */

#include "/lib/common.glsl"

varying vec2 texcoord;
varying vec4 vColor;

uniform sampler2D texture;

void main(){
    vec4 c = texture2D(texture, texcoord) * vColor;
    if(c.a < 0.1) discard;     // respect cutout so leaves cast leafy shadows

    // shadowcolor0: for opaque casters store white (no tint); for translucent
    // store their colour so getShadow() can colourise the shadow.
    gl_FragData[0] = vec4(c.rgb, c.a);
}
