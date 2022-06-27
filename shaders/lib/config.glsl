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
#define ENTITY_METAL        10400.0  // Metal-like glossy blocks
#define ENTITY_SAND         10410.0  // Sand-like glossy blocks
#define ENTITY_FABRIC       10440.0  // Fabric-like glossy blocks

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
  #define REFLEX_INDEX 0.75
#elif REFLECTION_SLIDER == 2
  #define REFLECTION 1
  #define SSR_TYPE 1
  #define REFLEX_INDEX 0.75
#endif

#define ACERCADE 0 // [0]
#define WAVING 1 // [0 1] Makes objects like leaves or grass move in the wind
#define TINTED_WATER 1  // [0 1] Use the resource pack color for water.
#define REFRACTION 1  // [0 1] Activate refractions.
// #define DOF // Enables depth of field (high performance cost).
#define DOF_STRENGTH 0.09  // [0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.013]  Depth of field strenght.
#define AO 1  // [0 1] Turn on for enhanced ambient occlusion (medium performance cost).
#define AOSTEPS 4 // [4 5 6 7 8 9 10 11] How many samples are taken for AO (high performance cost).
#define AO_STRENGHT 0.60 // [0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.66 0.70 0.75 0.80 0.85] Ambient occlusion strenght (strenght NOT affect performance).
#define AA_TYPE 1 // [0 1 2] Fast TAA: Enable antialiasing (Recommended). Denoise only: Supersampling is only used to eliminate noise. No: Disable antialiasing (not recommended).
//#define MOTION_BLUR // Turn on motion blur
#define MOTION_BLUR_STRENGTH 1.0 // [0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0] Set Motion blur strength. Lower framerate -> Lower strength and vice versa is recommended.
#define MOTION_BLUR_SAMPLES 4 // [3 4 5 6 7 8] Motion blur samples 
#define SUN_REFLECTION 1 // [0 1] Enable sun (or moon) reflection on water and glass
#define SHADOW_CASTING // Turn shadow casting on or off.
#define SHADOW_RES 4 // [0 1 2 3 4 5 6 7 8 9 10 11] Set shadow quality. Read as: 'Visual quality (distance)'. Volumetric lighting works best with "normal" or "far" distance shadows.
#define SHADOW_TYPE 1 // [0 1] Sets the shadow type
#define SHADOW_BLUR 2.5 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5]  Shadow blur intensity
// #define COLORED_SHADOW // Attempts to tint the shadow of translucent objects, as well as the associated volumetric light (if active).
#define WATER_ABSORPTION 0.05 // [0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.230.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38] Sets how much light the water absorbs. Low levels make the water more transparent. High levels make it more opaque.
#define COLOR_SCHEME 0 // [0 1 2 3 4 5 6] Ethereal: Current default theme. New shoka: Reinterpretation of a classic. Shoka: The classic. Legacy: Very old default. Captain: A cold preset of stylish colors. Psycodelic: Remaster of old vivid scheme. Cocoa: Warm theme
#define WATER_TEXTURE 0 // [0 1] Enable or disable resource pack water texture. It does not work properly in 1.12. In that case the default value is recommended.
#define AVOID_DARK_LEVEL 0.09 // [0.00 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.18 0.19 0.20]  Minimal omni light intensity in caves (percentaje).
#define NIGHT_BRIGHT 1.2 // [0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7 2.8 2.9 3.0] Adjusts the brightness of the night light in exteriors.
#define V_CLOUDS 1 // [0 1 2] Volumetric static: The clouds move, but they keep their shape. Volumetric dynamic: Clouds change shape over time, a different cloud landscape every time (medium performance hit). Vanilla: Original vanilla clouds.
#define CLOUD_VOL_STYLE 0 // [0 1] Set the volumetric cloud style.
#define CLOUD_REFLECTION  // Set off-screen volumetric clouds reflection (volumetric clouds must be active).
#define BLACK_ENTITY_FIX 0 // [0 1] Removes black entity bug in old video drivers (activate ONLY if you have problems with black entities)
#define BLOOM // Enable or disable bloom effect
#define BLOOM_SAMPLES 4.0 // [4.0 5.0 6.0 7.0 8.0 9.0 10.0] Bloom sample pairs.
#define CHROMA_ABER 0 // [0 1] Enable chroma aberration.
#define CHROMA_ABER_STRENGHT 0.04 // [0.04 0.05 0.06] Chroma aberration strenght.
#define VOL_LIGHT 1 // [0 1 2] Depth based: Turn on depth based godrays, they are a bit slow, but can work better than volumetric light for very short shadow distances. Volumetric: It activates the volumetric light, more accurate and faster, but it needs the shadows enabled to work.
// #define VANILLA_WATER // Establishes the appearance of water as vanilla.
#define WATER_COLOR_SOURCE 0 // [0 1] Select the water color source. It does not work properly in 1.12. In that case the default value is recommended.
#define WATER_TURBULENCE 2.25 // [8.0 3.7 2.25 1.3] Set the water waves strenght.
#define FOG_ADJUST 2.0 // [10.0 8.0 4.0 2.0 1.0]  Sets the fog strenght
// #define DEBUG_MODE // Set debug mode.
#define BLOCKLIGHT_TEMP 1 // [0 1 2 3 4] Set blocklight temperature
#define MATERIAL_GLOSS // A very subtle effect that adds some ability to reflect direct light on some blocks. It is most noticeable on metals and luminous objects.
// #define SIMPLE_AUTOEXP // Toggle between advanced and simple auto-exposure.

#ifdef SIMPLE_AUTOEXP
  // Menu bug workaround. Don't remove
#endif

// Reflection parameters
#define RAYMARCH_STEPS 10

// Cloud parameters
#if CLOUD_VOL_STYLE == 1
  #define CLOUD_PLANE_SUP 380.0
  #define CLOUD_PLANE_CENTER 335.0
  #define CLOUD_PLANE 319.0
#else
  #define CLOUD_PLANE_SUP 590.0
  #define CLOUD_PLANE_CENTER 375.0
  #define CLOUD_PLANE 319.0
#endif

#define CLOUD_STEPS_AVG 7 // [7 8 9 10 11 12 13 14 15 16] Samples per pixel (high performance impact).
#define CLOUD_SPEED 0 // [0 1 2] Change the speed of clouds for display purposes.

#if CLOUD_VOL_STYLE == 1
  #if CLOUD_SPEED == 0
    #define CLOUD_HI_FACTOR 0.001388888888888889
    #define CLOUD_LOW_FACTOR 0.0002777777777777778
  #elif CLOUD_SPEED == 1
    #define CLOUD_HI_FACTOR 0.01388888888888889
    #define CLOUD_LOW_FACTOR 0.002777777777777778
  #elif CLOUD_SPEED == 2
    #define CLOUD_HI_FACTOR 0.1388888888888889
    #define CLOUD_LOW_FACTOR 0.02777777777777778
  #endif
#else
  #if CLOUD_SPEED == 0
    #define CLOUD_HI_FACTOR 0.0016666666666666666
    #define CLOUD_LOW_FACTOR 0.0002777777777777778
  #elif CLOUD_SPEED == 1
    #define CLOUD_HI_FACTOR 0.016666666666666666
    #define CLOUD_LOW_FACTOR 0.002777777777777778
  #elif CLOUD_SPEED == 2
    #define CLOUD_HI_FACTOR 0.16666666666666666
    #define CLOUD_LOW_FACTOR 0.02777777777777778
  #endif
#endif

// Godrays
#define GODRAY_STEPS 6
#define CHEAP_GODRAY_SAMPLES 4

// Color blindness
// #define COLOR_BLINDNESS  // Enable color blindness correction
#define COLOR_BLIND_MODE 0  // [0 1 2]  Set color blindness type

// Sun rotation angle
const float sunPathRotation = -25.0; // [-40.0 -35.0 -30.0 -25.0 -20.0 -15.0 -10.0 -5.0 0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0]

// Shadow parameters
const float shadowIntervalSize = 3.0;
const bool generateShadowMipmap = false;
const bool generateShadowColorMipmap = false;

#ifdef SHADOW_CASTING
  #ifndef NO_SHADOWS
    #if SHADOW_RES == 0
      #define SHADOW_LIMIT 75.0
      const int shadowMapResolution = 300;
      const float shadowDistance = 75.0;
      #define SHADOW_DIST 0.7
    #elif SHADOW_RES == 1
      #define SHADOW_LIMIT 105.0
      const int shadowMapResolution = 420;
      const float shadowDistance = 105.0;
      #define SHADOW_DIST 0.77
    #elif SHADOW_RES == 2
      #define SHADOW_LIMIT 255.0
      const int shadowMapResolution = 1020;
      const float shadowDistance = 255.0;
      #define SHADOW_DIST 0.8

    #elif SHADOW_RES == 3
      #define SHADOW_LIMIT 75.0
      const int shadowMapResolution = 600;
      const float shadowDistance = 75.0;
      #define SHADOW_DIST 0.77
    #elif SHADOW_RES == 4
      #define SHADOW_LIMIT 105.0
      const int shadowMapResolution = 840;
      const float shadowDistance = 105.0;
      #define SHADOW_DIST 0.8
    #elif SHADOW_RES == 5
      #define SHADOW_LIMIT 255.0
      const int shadowMapResolution = 2040;
      const float shadowDistance = 255.0;
      #define SHADOW_DIST 0.85

    #elif SHADOW_RES == 6
      #define SHADOW_LIMIT 75.0
      const int shadowMapResolution = 1200;
      const float shadowDistance = 75.0;
      #define SHADOW_DIST 0.77
    #elif SHADOW_RES == 7
      #define SHADOW_LIMIT 105.0
      const int shadowMapResolution = 1680;
      const float shadowDistance = 105.0;
      #define SHADOW_DIST 0.8
    #elif SHADOW_RES == 8
      #define SHADOW_LIMIT 255.0
      const int shadowMapResolution = 4080;
      const float shadowDistance = 255.0;
      #define SHADOW_DIST 0.85

    #elif SHADOW_RES == 9
      #define SHADOW_LIMIT 75.0
      const int shadowMapResolution = 2400;
      const float shadowDistance = 75.0;
      #define SHADOW_DIST 0.77
    #elif SHADOW_RES == 10
      #define SHADOW_LIMIT 105.0
      const int shadowMapResolution = 3360;
      const float shadowDistance = 105.0;
      #define SHADOW_DIST 0.8
    #elif SHADOW_RES == 11
      #define SHADOW_LIMIT 255.0
      const int shadowMapResolution = 8160;
      const float shadowDistance = 255.0;
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
