#version 120
/* ============================================================================
   gbuffers_terrain.vsh  -  SpectreV
   ----------------------------------------------------------------------------
   Vertex stage for opaque world geometry (blocks, foliage, etc.).
   We just transform the vertex and forward everything the fragment pass needs:
   UV, lightmap coords, vertex colour and the WORLD-space normal.
   ========================================================================== */

varying vec2 texcoord;     // block texture UV
varying vec2 lmcoord;      // lightmap UV  (x = block light, y = sky light)
varying vec4 vColor;       // vertex colour / tint (grass, foliage, AO baked by MC)
varying vec3 worldNormal;  // normal in world space

uniform mat4 gbufferModelViewInverse;

void main(){
    gl_Position = ftransform();                         // standard MVP transform

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    vColor   = gl_Color;

    // gl_Normal is in view space; rotate into world space for stable lighting.
    worldNormal = normalize(mat3(gbufferModelViewInverse) * gl_NormalMatrix * gl_Normal);
}
