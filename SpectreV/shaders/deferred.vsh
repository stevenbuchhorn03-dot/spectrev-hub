#version 120
/* deferred.vsh - SpectreV  (fullscreen pass: SSAO)
   Standard fullscreen-triangle/quad passthrough used by every post program. */

varying vec2 texcoord;

void main(){
    gl_Position = ftransform();
    texcoord = gl_MultiTexCoord0.xy;
}
