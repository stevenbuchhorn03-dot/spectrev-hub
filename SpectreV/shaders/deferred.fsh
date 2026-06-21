#version 120
/* ============================================================================
   deferred.fsh  -  SpectreV   (PASS 1 of deferred: SSAO)
   ----------------------------------------------------------------------------
   Screen-space ambient occlusion. For each pixel we sample neighbouring depths
   in a hemisphere oriented by the surface normal and count how many are closer
   to the camera (occluders). Result (1 = open, 0 = occluded) is written to
   colortex3 for the lighting pass to multiply into ambient.
   ========================================================================== */

#include "/lib/common.glsl"
#include "/lib/noise.glsl"

/* DRAWBUFFERS:3 */

varying vec2 texcoord;

uniform sampler2D depthtex0;
uniform sampler2D colortex1;          // encoded normals + materialID
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform float viewWidth;
uniform float viewHeight;
uniform float frameTimeCounter;

void main(){
    float depth = texture2D(depthtex0, texcoord).r;

    // sky / far plane -> no occlusion
    if(depth >= 1.0){ gl_FragData[0] = vec4(1.0); return; }

#ifndef SSAO
    gl_FragData[0] = vec4(1.0); return;
#else
    vec4 enc = texture2D(colortex1, texcoord);
    float materialID = enc.w;
    if(materialID == 0.0 || materialID == 5.0){ gl_FragData[0] = vec4(1.0); return; }

    vec3 origin = screenToView(texcoord, depth, gbufferProjectionInverse);

    // We don't have a view-space normal stored, so derive one from depth
    // gradients (robust and cheap, avoids decoding mismatch).
    vec2 px = 1.0 / vec2(viewWidth, viewHeight);
    float dR = texture2D(depthtex0, texcoord + vec2(px.x, 0.0)).r;
    float dU = texture2D(depthtex0, texcoord + vec2(0.0, px.y)).r;
    vec3 pR = screenToView(texcoord + vec2(px.x,0.0), dR, gbufferProjectionInverse);
    vec3 pU = screenToView(texcoord + vec2(0.0,px.y), dU, gbufferProjectionInverse);
    vec3 normal = normalize(cross(pR - origin, pU - origin));

    float ao = 0.0;
    float rnd = hash12(gl_FragCoord.xy + frameTimeCounter) * TAU;

    for(int i = 0; i < SSAO_SAMPLES; i++){
        // spiral kernel in the hemisphere
        float a = rnd + float(i) * (TAU / float(SSAO_SAMPLES));
        float r = (float(i) + 0.5) / float(SSAO_SAMPLES);
        vec3 dir = vec3(cos(a), sin(a), 1.0);
        dir = normalize(dir) * SSAO_RADIUS * r;
        if(dot(dir, normal) < 0.0) dir = -dir;        // flip into hemisphere

        vec3 samplePos = origin + dir;
        vec4 clip = gbufferProjection * vec4(samplePos, 1.0);
        vec2 suv = (clip.xy / clip.w) * 0.5 + 0.5;
        if(suv.x < 0.0 || suv.x > 1.0 || suv.y < 0.0 || suv.y > 1.0) continue;

        float sd = texture2D(depthtex0, suv).r;
        vec3 sp = screenToView(suv, sd, gbufferProjectionInverse);

        // is the sampled surface in front of our sample point?
        float rangeCheck = smoothstep(0.0, 1.0, SSAO_RADIUS / abs(origin.z - sp.z + 1e-4));
        if(sp.z > samplePos.z + 0.02) ao += rangeCheck;
    }
    ao = 1.0 - (ao / float(SSAO_SAMPLES)) * SSAO_STRENGTH;
    ao = clamp(ao, 0.0, 1.0);

    gl_FragData[0] = vec4(ao, ao, ao, 1.0);
#endif
}
