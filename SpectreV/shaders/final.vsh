#version 120
/* final.vsh - SpectreV */
varying vec2 texcoord;
void main(){
    gl_Position = ftransform();
    texcoord = gl_MultiTexCoord0.xy;
}
