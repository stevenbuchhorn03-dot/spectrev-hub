#version 120
/* gbuffers_skybasic.vsh - SpectreV
   The vanilla sky dome / void. We pass the colour through; the real
   procedural sky is rebuilt in composite from the camera ray. */

varying vec4 vColor;

void main(){
    gl_Position = ftransform();
    vColor = gl_Color;
}
