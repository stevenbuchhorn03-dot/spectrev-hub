#version 120
/* ============================================================================
   final.fsh  -  SpectreV   (post: bloom add + tonemap + grade + vignette)
   ----------------------------------------------------------------------------
   The last program. Takes the HDR scene (colortex0), adds bloom (colortex5),
   runs ACES tonemapping + cinematic colour grade, then vignette + film grain.
   Output goes straight to the screen (gl_FragColor).
   ========================================================================== */

#include "/lib/common.glsl"
#include "/lib/tonemap.glsl"
#include "/lib/noise.glsl"

varying vec2 texcoord;

uniform sampler2D colortex0;   // HDR scene (linear)
uniform sampler2D colortex5;   // bloom
uniform float frameTimeCounter;

void main(){
    vec3 color = texture2D(colortex0, texcoord).rgb;

    // --- add bloom ---------------------------------------------------------
#ifdef BLOOM
    vec3 bloom = texture2D(colortex5, texcoord).rgb;
    color += bloom * BLOOM_STRENGTH * 10.0;
#endif

    // --- tonemap + cinematic grade (see lib/tonemap.glsl) ------------------
    color = cinematicGrade(color);

    // --- vignette ----------------------------------------------------------
    vec2 v = texcoord - 0.5;
    float vig = 1.0 - dot(v, v) * VIGNETTE * 2.5;
    color *= clamp(vig, 0.0, 1.0);

    // --- film grain --------------------------------------------------------
    float grain = (hash12(texcoord * vec2(1920.0,1080.0) + frameTimeCounter) - 0.5);
    color += grain * FILM_GRAIN;

    // back to display gamma
    color = toGamma(color);

    gl_FragColor = vec4(color, 1.0);
}
