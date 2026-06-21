#version 120
/* gbuffers_entities.fsh - SpectreV
   entityColor blends the red damage flash / status overlays. materialID 3.0. */

#include "/lib/common.glsl"

/* DRAWBUFFERS:012 */

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 vColor;
varying vec3 worldNormal;

uniform sampler2D texture;
uniform vec4 entityColor;      // .rgb tint, .a blend amount (damage flash)

void main(){
    vec4 albedo = texture2D(texture, texcoord) * vColor;
    if(albedo.a < 0.05) discard;
    albedo.rgb = mix(albedo.rgb, entityColor.rgb, entityColor.a);

    gl_FragData[0] = vec4(albedo.rgb, albedo.a);
    gl_FragData[1] = vec4(encodeNormal(worldNormal), 0.0, 3.0);
    gl_FragData[2] = vec4(lmcoord, 1.0, 0.0);
}
