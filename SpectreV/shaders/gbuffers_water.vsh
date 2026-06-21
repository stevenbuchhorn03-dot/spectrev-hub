#version 120
/* ============================================================================
   gbuffers_water.vsh  -  SpectreV
   ----------------------------------------------------------------------------
   Translucents: water, ice, stained glass. We forward-shade these AFTER the
   deferred lighting pass so we can read the already-lit scene behind them
   (colortex0) for refraction and screen-space reflections.
   ========================================================================== */

varying vec2 texcoord;
varying vec2 lmcoord;
varying vec4 vColor;
varying vec3 worldNormal;
varying vec3 worldPos;     // for wave animation & SSR ray setup
varying vec3 viewPos;
varying float isWater;     // 1.0 if this fragment is water (block id tagged)

uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;

/* mc_Entity.x carries the block id we declared in block.properties.
   We tag water as 10000 there (see comment in shaders.properties). */
attribute vec4 mc_Entity;

void main(){
    gl_Position = ftransform();

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vColor   = gl_Color;

    viewPos     = (gl_ModelViewMatrix * gl_Vertex).xyz;
    worldPos    = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz + cameraPosition;
    worldNormal = normalize(mat3(gbufferModelViewInverse) * gl_NormalMatrix * gl_Normal);

    isWater = (mc_Entity.x == 10000.0) ? 1.0 : 0.0;
}
