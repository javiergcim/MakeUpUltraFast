/* MakeUp - config.glsl
Config variables

Javier Garduño - GNU Lesser General Public License v3.0
*/

// Useful entities
#define ENTITY_SMALLGRASS   10031.0  // Normal grass like entities
#define ENTITY_LOWERGRASS   10175.0  // Lower half only
#define ENTITY_UPPERGRASS   10176.0  // Upper half only
#define ENTITY_SMALLENTS    10059.0  // Crops like entities
#define ENTITY_SMALLENTS_NW 10032.0  // No waveable small ents
#define ENTITY_LEAVES       10018.0  // Leaves
#define ENTITY_VINES        10106.0  // Vines
#define ENTITY_MAGMA        10213.0  // Emissors like magma
#define ENTITY_EMISSIVE     10089.0  // Emissors like candels and others
#define ENTITY_WATER        10008.0  // Water
#define ENTITY_PORTAL       10090.0  // Portal
#define ENTITY_STAINED      10079.0  // Glass

// Other constants
#define HI_SKY_RAIN_COLOR vec3(.7, .85, 1.0)
#define LOW_SKY_RAIN_COLOR vec3(0.35 , 0.425, 0.5)

// Options
#define REFLECTION_SLIDER 2 // [0 1 2] Reflection quality

#if REFLECTION_SLIDER == 0
  #define REFLECTION 0
  #define SSR_TYPE 0
#elif REFLECTION_SLIDER == 1
  #define REFLECTION 1
  #define SSR_TYPE 0
#elif REFLECTION_SLIDER == 2
  #define REFLECTION 1
  #define SSR_TYPE 1
#endif

#define ACERCADE 0 // [0]
#define WAVING 1 // [0 1] Waving entities
#define TINTED_WATER 1  // [0 1] Use the resource pack color for water.
#define REFRACTION 1  // [0 1] Activate refractions.
// #define DOF // Enables depth of field. High performance cost.
#define DOF_STRENGTH 0.045  // [0.03 0.035 0.040 0.045 0.05 0.055 0.06 0.065]  Depth of field strenght.
#define AO 1  // [0 1] Turn on for enhanced ambient occlusion (medium performance impact).
#define AOSTEPS 5 // [5 6 7 8 9 10 11 12 13 14] How many samples are taken. High performance cost.
#define AO_STRENGHT 0.5 // [0.2 0.3 0.4 0.5 0.6] Ambient oclusion strenght
#define AA_TYPE 1 // [0 1 2] Fast TAA - Enable antialiasing (Recommended). Denoise only - Supersampling is only used to eliminate noise. No - Disable antialiasing.
//#define MOTION_BLUR // Turn on motion blurs
#define MOTION_BLUR_STRENGTH 0.12 // [0.02 0.04 0.06 0.08 0.10 0.12 0.14 0.16 0.18 0.20] Set Motion blur strength. Lower framerate -> Lower strength and vice versa is recommended.
#define SUN_REFLECTION 1 // [0 1] Set sun (or moon) reflection on water and glass
#define SHADOW_CASTING // Set shadows
#define SHADOW_RES 2 // [0 1 2 3 4 5] Set shadow quality
#define SHADOW_TYPE 1 // [0 1] Sets the shadow type
#define SHADOW_BLUR 2.0 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]  Shadow blur intensity
#define WATER_TINT 0.8 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]  Water tint percentage
#define COLOR_SCHEME 4 // [0 1 2 3 4] Legacy: Exotic colors at sunset. Cocoa: A warm preset of vivid colors in the day. Captain: A cold preset of stylish colors. Shoka: Warm theme, with high contrast between light and shadow, inspired by the color theme of a famous shader. Ethereal: Current default theme.
#define WATER_TEXTURE 1 // [0 1] Enable or disable resource pack water texture.
#define AVOID_DARK 1 // [0 1] Avoid absolute darkness in caves at daytime
#define V_CLOUDS 1 // [0 1 2] Volumetric static: The clouds move, but they keep their shape. Volumetric dynamic: Clouds change shape over time, a different cloud landscape every time (medium performance hit). Vanilla: Original vanilla clouds.
#define BLACK_ENTITY_FIX 0 // [0 1] Removes black entity bug (activate ONLY if you have problems with black entities)
#define BLOOM // [0 1] Set bloom
#define BLOOM_SAMPLES 5.0 // [5.0 6.0 7.0 8.0 9.0 10.0] Bloom sample pairs
#define CHROMA_ABER 0 // [0 1] Enable chroma aberration
#define CHROMA_ABER_STRENGHT 0.05 // [0.04 0.05 0.06] Chroma aberration strenght

// Reflection parameters
#define RAY_STEP 0.25
#define RAYMARCH_STEPS 11
#define RAYSEARCH_STEPS 5

// Cloud parameters
#define CLOUD_PLANE_SUP 920.0
#define CLOUD_PLANE_CENTER 620.0
#define CLOUD_PLANE 520.0
#define CLOUD_STEPS_RANGE 10
#define CLOUD_STEPS_AVG 12 // [12 16 20 24] Average samples per pixel (high performance impact)
#define CLOUD_SPEED 0 // [0 1 2] Change the speed of clouds for display purposes.

#if CLOUD_SPEED == 0
  #define CLOUD_HI_FACTOR 0.002777777777777778
  #define CLOUD_LOW_FACTOR 0.0002777777777777778
#elif CLOUD_SPEED == 1
  #define CLOUD_HI_FACTOR 0.02777777777777778
  #define CLOUD_LOW_FACTOR 0.002777777777777778
#elif CLOUD_SPEED == 2
  #define CLOUD_HI_FACTOR 0.2777777777777778
  #define CLOUD_LOW_FACTOR 0.02777777777777778
#endif

// Buffers clear
const bool colortex0Clear = false;
const bool colortex1Clear = false;
const bool colortex2Clear = false;
const bool colortex3Clear = false;
const bool gaux1Clear = false;
const bool colortex5Clear = false;
const bool colortex6Clear = false;

// Sun rotation angle
const float sunPathRotation = -25.0;

// Shadow parameters
const float shadowIntervalSize = 4.0;
const bool generateShadowMipmap = false;
const bool generateShadowColorMipmap = false;

#ifdef SHADOW_CASTING
  #ifndef NO_SHADOWS
    #if SHADOW_RES == 0
      const int shadowMapResolution = 256;
      const float shadowDistance = 70.0;
      #define SHADOW_DIST 0.77
    #elif SHADOW_RES == 1
    const int shadowMapResolution = 512;
    const float shadowDistance = 128.0;
    #define SHADOW_DIST 0.75
    #elif SHADOW_RES == 2
      const int shadowMapResolution = 512;
      const float shadowDistance = 70.0;
      #define SHADOW_DIST 0.77
    #elif SHADOW_RES == 3
      const int shadowMapResolution = 1024;
      const float shadowDistance = 128.0;
      #define SHADOW_DIST 0.8
    #elif SHADOW_RES == 4
      const int shadowMapResolution = 1024;
      const float shadowDistance = 79.0;
      #define SHADOW_DIST 0.77
    #elif SHADOW_RES == 5
      const int shadowMapResolution = 2048;
      const float shadowDistance = 158.0;
      #define SHADOW_DIST 0.85
    #endif
    const float shadowDistanceRenderMul = 1.0;
    const bool shadowHardwareFiltering1 = true;

    #if SHADOW_TYPE == 0
      const bool shadowtex1Nearest = true;
    #elif SHADOW_TYPE == 1
      const bool shadowtex1Nearest = false;
    #endif
  #endif
#endif

// Redefined constants
#if AO == 0
  const float ambientOcclusionLevel = 1.0;
#else
  const float ambientOcclusionLevel = 0.5;
#endif

const float eyeBrightnessHalflife = 6.0;
const float centerDepthHalflife = 1.0;
