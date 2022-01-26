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
#define ENTITY_EMMISIVE     10089.0  // Emissors
#define ENTITY_S_EMMISIVE   10090.0  // Emissors
#define ENTITY_F_EMMISIVE   10213.0  // Fake emissors
#define ENTITY_WATER        10008.0  // Water
#define ENTITY_PORTAL       10090.0  // Portal
#define ENTITY_STAINED      10079.0  // Glass

// Other constants
#define HI_SKY_RAIN_COLOR vec3(.7, .85, 1.0)
#define LOW_SKY_RAIN_COLOR vec3(0.35 , 0.425, 0.5)

// Options
#define REFLECTION_SLIDER 2 // [0 1 2] Reflection quality. - Flipped image: Inaccurate but quick reflection. - Raymarching: Raytraced Screen Space Reflection.

#if REFLECTION_SLIDER == 0
  #define REFLECTION 0
  #define SSR_TYPE 0
  #define REFLEX_INDEX 0.45
#elif REFLECTION_SLIDER == 1
  #define REFLECTION 1
  #define SSR_TYPE 0
  #define REFLEX_INDEX 0.6
#elif REFLECTION_SLIDER == 2
  #define REFLECTION 1
  #define SSR_TYPE 1
  #define REFLEX_INDEX 0.6
#endif

#define ACERCADE 0 // [0]
#define WAVING 1 // [0 1] Waving entities
#define TINTED_WATER 1  // [0 1] Use the resource pack color for water.
#define REFRACTION 1  // [0 1] Activate refractions.
// #define DOF // Enables depth of field. High performance cost.
#define DOF_STRENGTH 0.09  // [0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.013]  Depth of field strenght.
#define AO 1  // [0 1] Turn on for enhanced ambient occlusion (medium performance impact).
#define AOSTEPS 4 // [4 5 6 7 8 9 10 11] How many samples are taken. High performance cost.
#define AO_STRENGHT 0.50 // [0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.66 0.70 0.75 0.80 0.85] Ambient occlusion strenght. Strenght NOT affect performance.
#define AA_TYPE 1 // [0 1 2] Fast TAA - Enable antialiasing (Recommended). Denoise only - Supersampling is only used to eliminate noise. No - Disable antialiasing.
//#define MOTION_BLUR // Turn on motion blurs
#define MOTION_BLUR_STRENGTH 0.12 // [0.02 0.04 0.06 0.08 0.10 0.12 0.14 0.16 0.18 0.20 0.22] Set Motion blur strength. Lower framerate -> Lower strength and vice versa is recommended.
#define MOTION_BLUR_SAMPLES 4 // [3 4 5 6 7 8] Motion blur samples 
#define SUN_REFLECTION 1 // [0 1] Set sun (or moon) reflection on water and glass
#define SHADOW_CASTING // Set shadows
#define SHADOW_RES 4 // [0 1 2 3 4 5 6 7 8 9 10 11] Set shadow quality. Read as: 'Visual quality (distance)'. Volumetric lighting works best with "normal" or "far" distance shadows.
#define SHADOW_TYPE 1 // [0 1] Sets the shadow type
#define SHADOW_BLUR 2.5 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5]  Shadow blur intensity
// #define COLORED_SHADOW // Attempts to tint the shadow of translucent objects, as well as the associated volumetric light (if active).
#define WATER_ABSORPTION 0.05 // [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.230.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38] Sets how much light the water absorbs. Low levels make the water more transparent. High levels make it more opaque.
#define COLOR_SCHEME 4 // [0 1 2 3 4 5] Legacy: Exotic colors at sunset. Cocoa: A warm preset of vivid colors in the day. Captain: A cold preset of stylish colors. Shoka: Warm theme, with high contrast between light and shadow, inspired by the color theme of a famous shader. Ethereal: Current default theme. Vivid: Fantasy theme.
#define WATER_TEXTURE 0 // [0 1] Enable or disable resource pack water texture.
#define AVOID_DARK_LEVEL 0.08 // [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12]  Minimal omni light intensity in caves (percentaje). During the night, the caves are always dark.
#define NIGHT_BRIGHT 1.1 // [0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0] Adjusts the brightness of the night light.
#define V_CLOUDS 1 // [0 1 2] Volumetric static: The clouds move, but they keep their shape. Volumetric dynamic: Clouds change shape over time, a different cloud landscape every time (medium performance hit). Vanilla: Original vanilla clouds.
#define CLOUD_VOL_STYLE 0 // [0 1] Set the volumetric cloud style.
#define CLOUD_REFLECTION  // Set off-screen volumetric clouds reflection (volumetric clouds must be active)
#define BLACK_ENTITY_FIX 0 // [0 1] Removes black entity bug (activate ONLY if you have problems with black entities)
#define BLOOM // Set bloom
#define BLOOM_SAMPLES 5.0 // [5.0 6.0 7.0 8.0 9.0 10.0] Bloom sample pairs
#define CHROMA_ABER 0 // [0 1] Enable chroma aberration
#define CHROMA_ABER_STRENGHT 0.05 // [0.04 0.05 0.06] Chroma aberration strenght
#define VOL_LIGHT // This option activates volumetric light (shadows must be enabled to work)
// #define VANILLA_WATER // Establishes the appearance of water as vanilla.
#define WATER_COLOR_SOURCE 0 // [0 1] Select the water color source. This option has no effect on 1.12.x versions or Vanilla like water.
#define WATER_TURBULENCE 1.7 // [3.7 1.7 1.3] Set the water waves strenght
#define FOG_ADJUST 1.0 // [2.0 1.0 0.5]  Recommended settings. 'Short' for 8 or less draw distance. 'Regular' between 9 and 19 draw distance. 'Far' for 20+ draw distance.
// #define DEBUG_MODE // Set debug mode.


// Reflection parameters
#define RAYMARCH_STEPS 9

// Cloud parameters
#if CLOUD_VOL_STYLE == 1
  #define CLOUD_PLANE_SUP 520.0
  #define CLOUD_PLANE_CENTER 470.0
  #define CLOUD_PLANE 420.0
#else
  #define CLOUD_PLANE_SUP 920.0
  #define CLOUD_PLANE_CENTER 570.0
  #define CLOUD_PLANE 420.0
#endif

#define CLOUD_STEPS_AVG 7 // [7 10 13] Samples per pixel (high performance impact)
#define CLOUD_SPEED 0 // [0 1 2] Change the speed of clouds for display purposes.

#if CLOUD_VOL_STYLE == 1
  #if CLOUD_SPEED == 0
    #define CLOUD_HI_FACTOR 0.001388888888888889
    #define CLOUD_LOW_FACTOR 0.0001388888888888889
  #elif CLOUD_SPEED == 1
    #define CLOUD_HI_FACTOR 0.01388888888888889
    #define CLOUD_LOW_FACTOR 0.001388888888888889
  #elif CLOUD_SPEED == 2
    #define CLOUD_HI_FACTOR 0.1388888888888889
    #define CLOUD_LOW_FACTOR 0.01388888888888889
  #endif
#else
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
#endif

// Godrays
#define GODRAY_STEPS 6

// Sun rotation angle
const float sunPathRotation = -25.0; // [-40.0 -35.0 -30.0 -25.0 -20.0 -15.0 -10.0 -5.0 0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0]

// Shadow parameters
const float shadowIntervalSize = 4.0;
const bool generateShadowMipmap = false;
const bool generateShadowColorMipmap = false;

#ifdef SHADOW_CASTING
  #ifndef NO_SHADOWS
    #if SHADOW_RES == 0
      const int shadowMapResolution = 256;
      const float shadowDistance = 70.0;
      #define SHADOW_DIST 0.7
    #elif SHADOW_RES == 1
      const int shadowMapResolution = 512;
      const float shadowDistance = 128.0;
      #define SHADOW_DIST 0.77
    #elif SHADOW_RES == 2
      const int shadowMapResolution = 1024;
      const float shadowDistance = 256.0;
      #define SHADOW_DIST 0.8

    #elif SHADOW_RES == 3
      const int shadowMapResolution = 512;
      const float shadowDistance = 70.0;
      #define SHADOW_DIST 0.77
    #elif SHADOW_RES == 4
      const int shadowMapResolution = 1024;
      const float shadowDistance = 128.0;
      #define SHADOW_DIST 0.8
    #elif SHADOW_RES == 5
      const int shadowMapResolution = 2048;
      const float shadowDistance = 256.0;
      #define SHADOW_DIST 0.85

    #elif SHADOW_RES == 6
      const int shadowMapResolution = 1024;
      const float shadowDistance = 70.0;
      #define SHADOW_DIST 0.77
    #elif SHADOW_RES == 7
      const int shadowMapResolution = 2048;
      const float shadowDistance = 128.0;
      #define SHADOW_DIST 0.8
    #elif SHADOW_RES == 8
      const int shadowMapResolution = 4096;
      const float shadowDistance = 256.0;
      #define SHADOW_DIST 0.85

    #elif SHADOW_RES == 9
      const int shadowMapResolution = 2048;
      const float shadowDistance = 70.0;
      #define SHADOW_DIST 0.77
    #elif SHADOW_RES == 10
      const int shadowMapResolution = 4096;
      const float shadowDistance = 128.0;
      #define SHADOW_DIST 0.8
    #elif SHADOW_RES == 11
      const int shadowMapResolution = 8192;
      const float shadowDistance = 256.0;
      #define SHADOW_DIST 0.85
    #endif

    const float shadowDistanceRenderMul = 1.0;
    const bool shadowHardwareFiltering = true;

    const bool shadowtex1Nearest = false;
  #endif
#endif

// Redefined constants
#if AO == 0
  const float ambientOcclusionLevel = 0.7;
#else
  const float ambientOcclusionLevel = 0.0;
#endif

const float eyeBrightnessHalflife = 6.0;
const float centerDepthHalflife = 1.0;
