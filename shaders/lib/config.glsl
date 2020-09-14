/* MakeUp Ultra Fast - gbuffers_entities.vsh
Config variables

Javier Garduño - GNU Lesser General Public License v3.0
*/

// Useful entities
#define ENTITY_SMALLGRASS   10031.0  //
#define ENTITY_LOWERGRASS   10175.0  // Lower half only in 1.13+
#define ENTITY_UPPERGRASS   10176.0  // Upper half only used in 1.13+
#define ENTITY_SMALLENTS    10059.0  // sapplings(6), dandelion(37), rose(38), carrots(141), potatoes(142), beetroot(207)
#define ENTITY_LEAVES       10018.0  // Leaves
#define ENTITY_VINES        10106.0  // Vines
#define ENTITY_MAGMA        10213.0  // Emissors like magma
#define ENTITY_EMISSIVE     10089.0  // Emissors like candels and others
#define ENTITY_WATER        10008.0  // Water
#define ENTITY_PORTAL       10090.0  // Portal
#define ENTITY_STAINED      10079.0  // Glass

// Options
#define WAVING 1 // [0 1] Waving entities
#define TINTED_WATER 1  // [0 1] Use the resource pack color for water.
#define REFLECTION 1  // [0 1] Activate reflections.
#define REFRACTION 1  // [0 1] Activate refractions.
#define SSR_METHOD 0  // [0 1] Flipped Image is inaccurate but faster. Raytrace is more accurate but slower.
#define AA 4 // [0 4 6 12] Set antialiasing quality
#define DOF 1  // [0 1] Enables depth of field (high performance cost)
#define DOF_STRENGTH 50.0  // [20.0 25.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 65.0 70.0 75.0 80.0]  Depth of field strenght.
#define AO 1  // [0 1] Turn on for enhanced ambient occlusion (medium performance impact).
#define AOSTEPS 8 // [8 12 16 20] How many samples are taken. More samples, less performance
#define AO_STRENGHT 0.6 // [0.4 0.5 0.6 0.7 0.8 0.9 1.0] Ambient oclusion strenght
#define RT_SAMPLES 10 // [6 8 10 12 14 16 18 20 22 24] Reflections samples (only raytrace). More samples, less performance.
#define TAA 1  // [0 1] Activate temporal antialiasing
