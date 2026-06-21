#version 120
/* composite2.vsh - SpectreV  (bloom: vertical blur) */
varying vec2 texcoord;
void main(){
    gl_Position = ftransform();
    texcoord = gl_MultiTexCoord0.xy;
}
