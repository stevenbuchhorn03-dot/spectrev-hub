# SpectreV — a cinematic, RTX-inspired Minecraft shader pack

A modular Iris / OptiFine (GLSL) shader pack built around a **deferred** pipeline:
soft shadow-mapped sunlight, a physically-plausible day/night sky with golden-hour
tones, volumetric god rays and clouds, reflective/refractive water with caustics,
SSAO, bloom, and ACES tonemapping with a cinematic colour grade.

It is intentionally written to be **read and tweaked** — every pass is commented and
every knob lives in one place (`shaders/lib/settings.glsl`, also exposed in the
in-game menu).

---

## 1. Folder / file structure

```
SpectreV/                          ← this folder is the shader pack
└── shaders/
    ├── shaders.properties         ← in-game menu layout, profiles, sliders
    ├── block.properties           ← tags blocks (water=10000) for mc_Entity
    ├── lang/
    │   └── en_us.lang             ← labels + tooltips for the menu
    │
    ├── lib/                       ← shared #include code (no entry points)
    │   ├── settings.glsl          ← ★ ALL tweakables + colortex formats
    │   ├── common.glsl            ← math, normal/depth encode, gamma helpers
    │   ├── noise.glsl             ← hashes, value noise, fbm
    │   ├── sky.glsl               ← atmosphere + time-of-day sun/sky colour
    │   ├── shadows.glsl           ← shadow distortion + PCF soft sampling
    │   ├── clouds.glsl            ← volumetric cloud raymarch
    │   └── tonemap.glsl           ← ACES/Reinhard + cinematic grade
    │
    ├── shadow.vsh / shadow.fsh    ← renders the sun's-eye shadow map
    │
    ├── gbuffers_terrain.*         ← opaque world geometry  → G-buffer
    ├── gbuffers_textured.*        ← particles / fallback   → G-buffer
    ├── gbuffers_basic.*           ← outlines (kept unlit)  → G-buffer
    ├── gbuffers_entities.*        ← mobs / items           → G-buffer
    ├── gbuffers_hand.*            ← first-person hand      → G-buffer
    ├── gbuffers_skybasic.*        ← sky dome (placeholder, rebuilt later)
    ├── gbuffers_skytextured.*     ← sun/moon discs (HDR boosted)
    ├── gbuffers_clouds.*          ← vanilla clouds (hidden when volumetric on)
    ├── gbuffers_water.*           ← FORWARD water: reflect/refract/Fresnel/caustics
    │
    ├── deferred.*                 ← PASS 1: SSAO            → colortex3
    ├── deferred1.*                ← PASS 2: lighting (sun+shadow+sky+AO) → colortex0
    │
    ├── composite.*                ← procedural sky + volumetric clouds + god rays
    ├── composite1.*               ← bloom: bright-pass + horizontal blur → colortex4
    ├── composite2.*               ← bloom: vertical blur → colortex5
    └── final.*                    ← bloom add + ACES tonemap + grade + vignette + grain
```

### How the frame flows (pipeline order)

```
shadow            → build shadow map from the sun
gbuffers_*        → rasterize scene into the G-buffer (albedo / normal / lightmap)
deferred  (SSAO)  → occlusion factor                    [colortex3]
deferred1 (light) → combine everything into lit HDR     [colortex0]
gbuffers_water    → forward-shade translucents over the lit scene
composite         → rebuild sky, raymarch clouds, add god rays
composite1/2      → bloom (separable Gaussian)
final             → tonemap + grade + vignette + grain → screen
```

**G-buffer layout** (formats declared in `lib/settings.glsl`):

| Buffer    | Contents                                             |
|-----------|------------------------------------------------------|
| colortex0 | scene colour (HDR, linear) — albedo → lit → graded   |
| colortex1 | encoded world normal `.xy`, smoothness `.z`, materialID `.w` |
| colortex2 | lightmap (block `.x`, sky `.y`), baked AO `.z`, unlit flag `.w` |
| colortex3 | SSAO                                                 |
| colortex4 | bloom (horizontal blur)                              |
| colortex5 | bloom (vertical blur)                                |
| colortex6 | reserved / god-ray scratch                           |

---

## 2. Installation

### Requirements
- Minecraft Java Edition
- **Iris** (recommended, modern) *or* **OptiFine** — both read this same pack.

### Steps
1. Install Iris (with Sodium) **or** OptiFine for your Minecraft version.
2. Launch the game with that profile.
3. Open **Options → Video Settings → Shader Packs** (OptiFine) or
   **Options → Video Settings → Shaders / the Iris "Shader Packs" button** (Iris).
4. Click **"Open Shader Pack Folder"**. This opens
   `.minecraft/shaderpacks/`.
5. Copy the **`SpectreV` folder** (the one containing `shaders/`) into
   `shaderpacks/`. *(You can also zip it — `SpectreV.zip` with `shaders/`
   inside — both work.)*
6. Back in the menu, select **SpectreV** from the list to enable it.
7. Click **"Shader Options"** (or "Settings") to open the in-game menu and
   start tweaking — or pick a **profile**: `POTATO`, `BALANCED`, `ULTRA`.

> Tip: changes you make in the in-game menu are saved per-pack and override the
> defaults in `lib/settings.glsl`.

---

## 3. Tweaking — where the knobs are

Everything lives in **`shaders/lib/settings.glsl`** and is mirrored in the
in-game menu. The headline ones:

| Want to change…        | Setting(s)                                            |
|------------------------|-------------------------------------------------------|
| Shadow softness        | `SHADOW_SOFTNESS` (blur), `SHADOW_SAMPLES` (quality)  |
| Shadow acne / floating | `SHADOW_BIAS`                                          |
| Cloud amount / look    | `CLOUD_DENSITY`, `CLOUD_SCATTER`, `CLOUD_STEPS`        |
| God-ray strength       | `GODRAY_INTENSITY`, `GODRAY_SAMPLES`                   |
| Water reflectivity     | `WATER_FRESNEL_POW`, `WATER_REFLECTIONS`, `SSR_STEPS`  |
| Time-of-day warmth     | `GOLDEN_HOUR_WARMTH`, `SUN_INTENSITY`, `SKY_INTENSITY` |
| Cinematic colour grade | `EXPOSURE`, `CONTRAST`, `SATURATION`, `COLOR_TEMP`, `LIFT` |
| Bloom                  | `BLOOM_STRENGTH`, `BLOOM_THRESHOLD`                    |

Each effect can be **fully disabled** by commenting out its `#define`
(`SSAO`, `GODRAYS`, `VOLUMETRIC_CLOUDS`, `WATER_REFLECTIONS`, `BLOOM`,
`TONEMAP_ACES`).

---

## 4. Performance trade-offs (what's GPU-heavy)

Ordered roughly most → least expensive. Use the **`POTATO` profile** as a fast baseline.

| Feature                | Cost     | Cheapest win                                  |
|------------------------|----------|-----------------------------------------------|
| Volumetric clouds      | **HIGH** | lower `CLOUD_STEPS` (16→10), or disable       |
| God rays               | **HIGH** | lower `GODRAY_SAMPLES` (24→12), or disable    |
| Shadow map resolution  | **HIGH** | `4096 → 2048 → 1024` (huge VRAM/fill saving)  |
| PCF shadow samples     | MED-HIGH | `SHADOW_SAMPLES 3→2→1` ((2N+1)² taps)         |
| Water SSR              | MEDIUM   | lower `SSR_STEPS`, or disable reflections     |
| SSAO                   | MEDIUM   | lower `SSAO_SAMPLES` (12→6)                    |
| Bloom                  | LOW-MED  | cheap; disable last                           |
| Tonemap / grade / grain| LOW      | essentially free                              |

Notes:
- **Clouds + god rays are both raymarchers** — they scale linearly with their
  step counts and are the first things to cut on weak GPUs.
- **Shadow resolution** affects both VRAM and fill-rate; dropping to 1024 is the
  single biggest easy saving, at the cost of crisper shadow edges.
- SSAO and SSR are screen-space, so they're cheaper at lower render resolutions
  (use Minecraft's GUI/render scale if needed).

---

## 5. Building it up yourself (learning path)

The pack is layered so you can study one effect at a time. Suggested order, each
step is independently toggleable:

1. **Base:** G-buffers + `deferred1` lighting + `final` tonemap (flat but correct).
2. **Shadows:** enable `shadow.*` + `lib/shadows.glsl` PCF.
3. **Sky/sun cycle:** `lib/sky.glsl` driving `deferred1` + `composite`.
4. **SSAO:** `deferred.fsh`.
5. **God rays + volumetric clouds:** `composite.fsh` + `lib/clouds.glsl`.
6. **Water:** `gbuffers_water.*`.
7. **Bloom + grade polish:** `composite1/2` + `lib/tonemap.glsl`.

---

*SpectreV is a hand-written reference pack: clarity over micro-optimisation.
Tune the `lib/settings.glsl` constants to taste.*
