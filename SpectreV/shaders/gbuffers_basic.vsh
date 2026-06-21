#version 120
/* gbuffers_basic.vsh - SpectreV
   Untextured geometry: block selection outline, leash, etc. */

varying vec4 vColor;
varying vec2 lmcoord;

void main(){
    gl_Position = ftransform();
    vColor   = gl_Color;
    lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
}
