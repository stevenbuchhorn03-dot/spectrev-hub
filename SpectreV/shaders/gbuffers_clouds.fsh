#version 120
/* gbuffers_clouds.fsh - SpectreV
   When VOLUMETRIC_CLOUDS is on we hide the vanilla cloud plane entirely and
   let composite render the volumetric ones instead. Otherwise pass it through
   with slightly softened shading. */

#include "/lib/common.glsl"

/* DRAWBUFFERS:012 */

varying vec2 texcoord;
varying vec4 vColor;

uniform sampler2D texture;

void main(){
#ifdef VOLUMETRIC_CLOUDS
    discard;                                      // volumetric clouds take over
#else
    vec4 c = texture2D(texture, texcoord) * vColor;
    if(c.a < 0.1) discard;
    gl_FragData[0] = vec4(c.rgb, c.a);
    gl_FragData[1] = vec4(0.5, 0.5, 0.0, 5.0);
    gl_FragData[2] = vec4(0.0, 1.0, 1.0, 1.0);
#endif
}
