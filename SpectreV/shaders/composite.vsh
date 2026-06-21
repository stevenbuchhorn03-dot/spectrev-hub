#version 120
/* composite.vsh - SpectreV  (sky + clouds + god rays)
   Passthrough; also precompute the sun's screen-space position for god rays. */

varying vec2 texcoord;
varying vec2 sunScreenPos;
varying float sunVisible;

uniform vec3 sunPosition;
uniform mat4 gbufferProjection;

void main(){
    gl_Position = ftransform();
    texcoord = gl_MultiTexCoord0.xy;

    // project the (view-space) sun into screen space for radial god rays
    vec4 clip = gbufferProjection * vec4(sunPosition, 1.0);
    sunScreenPos = (clip.xy / clip.w) * 0.5 + 0.5;
    sunVisible = (clip.w > 0.0) ? 1.0 : 0.0;     // sun in front of camera?
}
