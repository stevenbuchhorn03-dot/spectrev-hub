#version 120
/* gbuffers_textured.fsh - SpectreV
   Fallback fragment stage. Same G-buffer layout as terrain.
   materialID 2.0 = particles / misc textured. */

#include "/lib/common.glsl"

/* DRAWBUFFERS:012 */

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 vColor;
varying vec3 worldNormal;

uniform sampler2D texture;

void main(){
    vec4 albedo = texture2D(texture, texcoord) * vColor;
    if(albedo.a < 0.1) discard;

    gl_FragData[0] = vec4(albedo.rgb, albedo.a);
    gl_FragData[1] = vec4(encodeNormal(worldNormal), 0.0, 2.0);
    gl_FragData[2] = vec4(lmcoord, 1.0, 0.0);
}
