#version 120
/* ============================================================================
   gbuffers_water.fsh  -  SpectreV
   ----------------------------------------------------------------------------
   Forward water shading:
     - animated wave normals from fbm noise
     - refraction: sample the lit scene (colortex0) at a distorted UV
     - reflection: screen-space ray-march (SSR) falling back to procedural sky
     - Fresnel blend between the two
     - fake animated caustics tint
   Non-water translucents (glass/ice) get a simple tinted blend.
   ========================================================================== */

#include "/lib/common.glsl"
#include "/lib/noise.glsl"
#include "/lib/sky.glsl"

/* DRAWBUFFERS:0 */   // we composite straight into the scene colour

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 vColor;
varying vec3 worldNormal;
varying vec3 worldPos;
varying vec3 viewPos;
varying float isWater;

uniform sampler2D texture;
uniform sampler2D colortex0;   // lit opaque scene (background)
uniform sampler2D depthtex1;   // opaque depth (no translucents)

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;

uniform vec3 sunPosition;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;
uniform float viewWidth;
uniform float viewHeight;

/* Build a perturbed water normal from two scrolling fbm layers. */
vec3 waterNormal(vec3 wp){
    float t = frameTimeCounter * 0.6;
    vec2 p = wp.xz * 0.8;
    float h1 = fbm2(p + vec2(t, t * 0.5), 3);
    float h2 = fbm2(p * 2.3 - vec2(t * 0.7, t), 3);
    float h  = (h1 + h2) * 0.5;

    // finite-difference slope -> tangent-space normal
    float e = 0.06;
    float hx = fbm2((p + vec2(e,0.0)) + vec2(t, t*0.5), 3);
    float hz = fbm2((p + vec2(0.0,e)) + vec2(t, t*0.5), 3);
    vec3 n = normalize(vec3(h - hx, e / max(WATER_WAVE_HEIGHT, 1e-3), h - hz));
    // blend the wave normal onto the flat surface normal
    return normalize(worldNormal + n * WATER_WAVE_HEIGHT * 4.0);
}

/* Screen-space reflection. Returns rgb + hit mask in .a. */
vec4 ssr(vec3 viewN){
#ifdef WATER_REFLECTIONS
    vec3 viewDir = normalize(viewPos);
    vec3 reflDir = reflect(viewDir, viewN);

    vec3 rayPos = viewPos;
    vec3 step   = reflDir * 0.5;

    for(int i = 0; i < SSR_STEPS; i++){
        rayPos += step;
        step   *= 1.18;                                // grow stride with distance

        vec4 clip = gbufferProjection * vec4(rayPos, 1.0);
        vec2 uv   = (clip.xy / clip.w) * 0.5 + 0.5;
        if(uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) break;

        float sceneDepth = texture2D(depthtex1, uv).r;
        vec3 scenePos = screenToView(uv, sceneDepth, gbufferProjectionInverse);

        // ray went behind geometry -> hit
        if(rayPos.z < scenePos.z - 0.05 && rayPos.z > scenePos.z - 1.5){
            float edge = smoothstep(0.0, 0.15, min(min(uv.x,1.0-uv.x), min(uv.y,1.0-uv.y)));
            return vec4(texture2D(colortex0, uv).rgb, edge);
        }
    }
#endif
    return vec4(0.0);
}

void main(){
    vec4 albedo = texture2D(texture, texcoord) * vColor;

    // ----- non-water translucents: simple tinted glass ---------------------
    if(isWater < 0.5){
        if(albedo.a < 0.05) discard;
        gl_FragData[0] = albedo;            // let MC's blend handle it
        return;
    }

    // ----- water -----------------------------------------------------------
    vec3 wN = waterNormal(worldPos);
    vec3 viewN = normalize(mat3(gbufferModelView) * wN);

    // screen uv of this fragment
    vec2 uv = gl_FragCoord.xy / vec2(viewWidth, viewHeight);

    // refraction: offset the background sample by the wave normal
    vec2 refrUV = clamp(uv + wN.xz * 0.04, 0.001, 0.999);
    vec3 refracted = texture2D(colortex0, refrUV).rgb;

    // water tint deepens the further light travels through it
    vec3 waterTint = vec3(0.10, 0.30, 0.40);
    refracted = mix(refracted, refracted * waterTint, 0.55);

#ifdef WATER_CAUSTICS
    // fake caustics: bright animated voronoi-ish ripples added to the floor
    float c = fbm2(worldPos.xz * 1.5 + frameTimeCounter * 0.5, 3);
    c = pow(c, 3.0) * 1.6;
    refracted += vec3(0.6, 0.8, 0.7) * c * 0.15;
#endif

    // reflection: SSR, fall back to procedural sky
    vec3 sunDirW = getSunDirWorld(sunPosition, gbufferModelViewInverse);
    vec3 viewDirW = normalize(worldPos - cameraPosition);
    vec3 reflDirW = reflect(viewDirW, wN);
    vec3 skyRefl  = skyGradient(reflDirW, sunDirW);

    // sun glint specular
    float spec = pow(max(dot(reflDirW, sunDirW), 0.0), 200.0);
    skyRefl += sunColor(sunDirW.y) * spec;

    vec4 ssrCol = ssr(viewN);
    vec3 reflection = mix(skyRefl, ssrCol.rgb, ssrCol.a);

    // Fresnel: more reflective at grazing angles. F0 ~0.02 for water.
    float cosT = max(dot(-viewDirW, wN), 0.0);
    float F = mix(0.02, 1.0, pow(1.0 - cosT, WATER_FRESNEL_POW));

    vec3 col = mix(refracted, reflection, F);

    gl_FragData[0] = vec4(col, 1.0);    // fully replace; we've blended manually
}
