#version 120
/* deferred1.vsh - SpectreV  (fullscreen pass: lighting) */

varying vec2 texcoord;

void main(){
    gl_Position = ftransform();
    texcoord = gl_MultiTexCoord0.xy;
}
