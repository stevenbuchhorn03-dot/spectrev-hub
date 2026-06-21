#version 120
/* ============================================================================
   gbuffers_terrain.fsh  -  SpectreV
   ----------------------------------------------------------------------------
   Fills the G-buffer for opaque geometry. NO lighting happens here — we only
   store surface data (albedo, normal, lightmap, material) so the deferred
   pass can light everything once, in screen space.

   G-buffer layout (see lib/settings.glsl for formats):
     colortex0 = albedo.rgb (+ alpha)
     colortex1 = encoded world normal .xy | smoothness .z | materialID .w
     colortex2 = lightmap (block,sky) | AO .z | material flag .w
   ========================================================================== */

#include "/lib/common.glsl"

/* DRAWBUFFERS:012 */

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 vColor;
varying vec3 worldNormal;

uniform sampler2D texture;     // the block atlas

void main(){
    vec4 albedo = texture2D(texture, texcoord) * vColor;
    if(albedo.a < 0.1) discard;                 // cut out leaves/grass etc.

    // material id 1.0 = generic opaque terrain
    float materialID = 1.0;

    gl_FragData[0] = vec4(albedo.rgb, albedo.a);
    gl_FragData[1] = vec4(encodeNormal(worldNormal), 0.0, materialID);
    gl_FragData[2] = vec4(lmcoord, vColor.a, 0.0);   // vColor.a carries MC's baked AO
}
