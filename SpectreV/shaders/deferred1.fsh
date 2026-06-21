#version 120
/* ============================================================================
   deferred1.fsh  -  SpectreV   (PASS 2 of deferred: LIGHTING)
   ----------------------------------------------------------------------------
   The heart of the look. For every opaque pixel we combine:
     albedo  (colortex0)
     world normal + materialID (colortex1)
     lightmap block/sky + baked AO (colortex2)
     SSAO (colortex3)
     directional sun shadow (shadowtex via lib/shadows.glsl)
     sky ambient + sun colour (lib/sky.glsl)
   ...into a physically-plausible HDR colour written back to colortex0.
   ========================================================================== */

#include "/lib/common.glsl"
#include "/lib/sky.glsl"
#include "/lib/shadows.glsl"

/* DRAWBUFFERS:0 */

varying vec2 texcoord;

uniform sampler2D colortex0;   // albedo
uniform sampler2D colortex1;   // normal + materialID
uniform sampler2D colortex2;   // lightmap + AO
uniform sampler2D colortex3;   // SSAO
uniform sampler2D depthtex0;

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform vec3 sunPosition;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;

void main(){
    vec4 albedo = texture2D(colortex0, texcoord);
    vec4 nrm    = texture2D(colortex1, texcoord);
    vec4 lm     = texture2D(colortex2, texcoord);
    float ssao  = texture2D(colortex3, texcoord).r;
    float depth = texture2D(depthtex0, texcoord).r;

    float materialID = nrm.w;

    // Sky / unlit pixels pass straight through (composite handles sky).
    if(depth >= 1.0 || materialID == 0.0 || materialID == 5.0 || lm.w > 0.5){
        gl_FragData[0] = albedo;
        return;
    }

    // --- reconstruct world position & normal -------------------------------
    vec3 viewPos  = screenToView(texcoord, depth, gbufferProjectionInverse);
    vec3 worldPos = viewToWorld(viewPos, gbufferModelViewInverse);
    vec3 worldPosAbs = worldPos + cameraPosition;
    vec3 N = decodeNormal(nrm.xy);

    // --- sun / sky setup ---------------------------------------------------
    vec3 sunDirW = getSunDirWorld(sunPosition, gbufferModelViewInverse);
    float elev   = sunDirW.y;
    float nDotL  = max(dot(N, sunDirW), 0.0);

    // --- shadows -----------------------------------------------------------
    vec3 shadow = getShadow(worldPos, nDotL,
                            shadowtex0, shadowtex1, shadowcolor0,
                            shadowModelView, shadowProjection);
    // keep a little light in shadow so it reads as ambient, not pure black
    shadow = mix(vec3(SHADOW_BRIGHTNESS), vec3(1.0), shadow);

    // --- light terms -------------------------------------------------------
    vec3 sunCol = sunColor(elev);
    vec3 skyCol = skyAmbient(elev);

    // block (torch) light from lightmap.x, warm tone
    float blockLight = lm.x;
    vec3  blockCol   = vec3(1.0, 0.55, 0.22) * pow(blockLight, 2.0) * 3.0;

    // sky visibility from lightmap.y gates how much ambient sky reaches here
    float skyVis = lm.y;

    // ambient occlusion = MC baked AO (lm.z) * our SSAO
    float ao = lm.z * ssao;

    // --- combine -----------------------------------------------------------
    vec3 direct  = sunCol * nDotL * shadow;
    vec3 ambient = skyCol * skyVis * ao;
    vec3 lighting = direct + ambient + blockCol * ao;

    vec3 color = toLinear(albedo.rgb) * lighting;

    // emissive-ish floor so caves aren't pure black
    color += toLinear(albedo.rgb) * NIGHT_BRIGHTNESS * 0.3 * ao;

    gl_FragData[0] = vec4(color, albedo.a);
}
