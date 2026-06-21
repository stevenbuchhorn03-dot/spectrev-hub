#version 120
/* gbuffers_skytextured.vsh - SpectreV  (sun & moon textures, custom skyboxes) */

varying vec2 texcoord;
varying vec4 vColor;

void main(){
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    vColor   = gl_Color;
}
