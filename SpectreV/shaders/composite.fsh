#version 120
/* ============================================================================
   composite.fsh  -  SpectreV   (sky rebuild + volumetric clouds + god rays)
   ----------------------------------------------------------------------------
   Runs after opaque lighting AND translucents. Three jobs:
     1. For SKY pixels (depth == far): replace with the full procedural sky.
     2. Raymarch volumetric clouds across the sky and blend them in.
     3. Screen-space volumetric god rays (radial light shafts from the sun).
   ========================================================================== */

#include "/lib/common.glsl"
#include "/lib/sky.glsl"
#include "/lib/clouds.glsl"

/* DRAWBUFFERS:0 */

varying vec2 texcoord;
varying vec2 sunScreenPos;
varying float sunVisible;

uniform sampler2D colortex0;
uniform sampler2D depthtex0;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform vec3 sunPosition;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;

/* Reconstruct the world-space view ray for this pixel. */
vec3 cameraRay(vec2 uv){
    vec3 view = screenToView(uv, 1.0, gbufferProjectionInverse);
    return normalize(mat3(gbufferModelViewInverse) * view);
}

void main(){
    vec3  color = texture2D(colortex0, texcoord).rgb;
    float depth = texture2D(depthtex0, texcoord).r;

    vec3 sunDirW  = getSunDirWorld(sunPosition, gbufferModelViewInverse);
    vec3 rayDirW  = cameraRay(texcoord);
    float elev    = sunDirW.y;

    bool isSky = depth >= 1.0;

    // --- 1 & 2 : procedural sky + clouds for sky pixels --------------------
    if(isSky){
        color = skyGradient(rayDirW, sunDirW);

        vec3 sCol = sunColor(elev);
        vec3 aCol = skyAmbient(elev) + skyGradient(rayDirW, sunDirW) * 0.2;
        vec3 camW = cameraPosition;
        vec4 clouds = renderClouds(camW, rayDirW, sunDirW, sCol, aCol, frameTimeCounter);
        color = mix(color, clouds.rgb, clamp(clouds.a, 0.0, 1.0));
    }

    // --- 3 : screen-space god rays / light shafts --------------------------
#ifdef GODRAYS
    if(sunVisible > 0.5 && elev > -0.05){
        vec2 dir = (sunScreenPos - texcoord) / float(GODRAY_SAMPLES);
        vec2 uv = texcoord;
        float illum = 1.0;
        float shafts = 0.0;

        for(int i = 0; i < GODRAY_SAMPLES; i++){
            uv += dir;
            if(uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) break;
            // a sample contributes only where the sky is visible (occluders
            // block the shaft, carving the classic crepuscular ray shape)
            float d = texture2D(depthtex0, uv).r;
            float sky = step(1.0, d);
            shafts += sky * illum;
            illum *= GODRAY_DECAY;
        }
        shafts /= float(GODRAY_SAMPLES);

        // fade with distance from sun on screen + sun elevation
        float radial = 1.0 - clamp(length(texcoord - sunScreenPos), 0.0, 1.0);
        float dayFade = smoothstep(-0.05, 0.25, elev);
        vec3 rayColor = sunColor(elev) * GODRAY_INTENSITY;
        color += rayColor * shafts * radial * dayFade;
    }
#endif

    gl_FragData[0] = vec4(color, 1.0);
}
