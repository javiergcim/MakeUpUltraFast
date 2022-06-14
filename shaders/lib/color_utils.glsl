/* MakeUp - color_utils.glsl
Usefull data for color manipulation.

Javier Garduño - GNU Lesser General Public License v3.0
*/

uniform float day_moment;
uniform float day_mixer;
uniform float night_mixer;

#ifdef UNKNOWN_DIM
  uniform vec3 fogColor;
  uniform vec3 skyColor;
#endif

#if COLOR_SCHEME == 0  // Ethereal
  #define OMNI_TINT 0.45
  #define AMBIENT_MIDDLE_COLOR vec3(0.887528, 0.591192, 0.401392)
  #define AMBIENT_DAY_COLOR vec3(0.90, 0.84, 0.79)
  #define AMBIENT_NIGHT_COLOR vec3(0.0317353, 0.0467353, 0.0637353) * NIGHT_BRIGHT

  #define HI_MIDDLE_COLOR vec3(0.1745098, 0.22352941, 0.34901961)
  #define HI_DAY_COLOR vec3(0.0785098, 0.24352941, 0.54901961)
  #define HI_NIGHT_COLOR vec3(0.0168, 0.0228, 0.03) * NIGHT_BRIGHT

  #define LOW_MIDDLE_COLOR vec3(1.0, 0.6, 0.394)
  #define LOW_DAY_COLOR vec3(0.65, 0.91, 1.3)
  #define LOW_NIGHT_COLOR vec3(0.02556, 0.03772, 0.05244) * NIGHT_BRIGHT

  #define WATER_COLOR vec3(0.01647059, 0.13882353, 0.16470588)
#elif COLOR_SCHEME == 1  // New shoka
  #define OMNI_TINT 0.4
  #define AMBIENT_MIDDLE_COLOR vec3(0.8832, 0.6348, 0.2898)
  #define AMBIENT_DAY_COLOR vec3(0.94252382, 0.85683984, 0.838695)
  #define AMBIENT_NIGHT_COLOR vec3(0.04786874, 0.05175001, 0.06112969) * NIGHT_BRIGHT

  #define HI_MIDDLE_COLOR vec3(0.13, 0.22176471, 0.33137255)
  #define HI_DAY_COLOR vec3(0.13, 0.22176471, 0.33137255)
  #define HI_NIGHT_COLOR vec3(0.014, 0.019, 0.025) * NIGHT_BRIGHT

  #define LOW_MIDDLE_COLOR vec3(0.715, 0.611, 0.52)
  #define LOW_DAY_COLOR vec3(0.4368, 0.819 , 1.2012)
  #define LOW_NIGHT_COLOR vec3(0.0213, 0.0306, 0.0387) * NIGHT_BRIGHT

  #define WATER_COLOR vec3(0.01647059, 0.13882353, 0.16470588)
#elif COLOR_SCHEME == 2  // Shoka
  #define OMNI_TINT 0.5
  #define AMBIENT_MIDDLE_COLOR vec3(0.8832, 0.6348, 0.2898)
  #define AMBIENT_DAY_COLOR vec3(0.91640625, 0.91640625, 0.635375)
  #define AMBIENT_NIGHT_COLOR vec3(0.04786874, 0.05175001, 0.06112969) * NIGHT_BRIGHT

  #define HI_MIDDLE_COLOR vec3(0.13, 0.22176471, 0.33137255)
  #define HI_DAY_COLOR vec3(0.13, 0.22176471, 0.33137255)
  #define HI_NIGHT_COLOR vec3(0.014, 0.019, 0.025) * NIGHT_BRIGHT

  #define LOW_MIDDLE_COLOR vec3(0.715, 0.611, 0.52)
  #define LOW_DAY_COLOR vec3(0.364 , 0.6825, 0.91)
  #define LOW_NIGHT_COLOR vec3(0.0213, 0.0306, 0.0387) * NIGHT_BRIGHT

  #define WATER_COLOR vec3(0.01647059, 0.13882353, 0.16470588)
#elif COLOR_SCHEME == 3  // Legacy
  #define OMNI_TINT 0.5
  #define AMBIENT_MIDDLE_COLOR vec3(1.0764, 0.54453175, 0.23638589)
  #define AMBIENT_DAY_COLOR vec3(0.88504, 0.88504, 0.8372)
  #define AMBIENT_NIGHT_COLOR vec3(0.04693014, 0.0507353 , 0.05993107) * NIGHT_BRIGHT

  #define HI_MIDDLE_COLOR vec3(0.10455883, 0.28779412, 0.5817647)
  #define HI_DAY_COLOR vec3(0.182, 0.351, 0.754)
  #define HI_NIGHT_COLOR vec3(0.00841175, 0.01651763, 0.025) * NIGHT_BRIGHT

  #define LOW_MIDDLE_COLOR vec3(0.81, 0.55207059, 0.25293529)
  #define LOW_DAY_COLOR vec3(0.572, 1.014, 1.248)
  #define LOW_NIGHT_COLOR vec3(0.01078431, 0.02317647, 0.035) * NIGHT_BRIGHT

  #define WATER_COLOR vec3(0.01647059, 0.13882353, 0.16470588)

#elif COLOR_SCHEME == 4  // Captain
  #define OMNI_TINT 0.5
  #define AMBIENT_MIDDLE_COLOR vec3(0.84456, 0.52992, 0.26496001)
  #define AMBIENT_DAY_COLOR vec3(0.83064961, 0.93448079, 1.1032065)
  #define AMBIENT_NIGHT_COLOR vec3(0.02597646, 0.05195295, 0.069) * NIGHT_BRIGHT

  #define HI_MIDDLE_COLOR vec3(0.2418 , 0.28782, 0.41574)
  #define HI_DAY_COLOR vec3(0.104, 0.26, 0.507)
  #define HI_NIGHT_COLOR vec3(0.004 ,0.01, 0.0195) * NIGHT_BRIGHT

  #define LOW_MIDDLE_COLOR vec3(1.3, 1.079, 0.494)
  #define LOW_DAY_COLOR vec3(0.65, 0.91, 1.3)
  #define LOW_NIGHT_COLOR vec3(0.025, 0.035, 0.05) * NIGHT_BRIGHT

  #define WATER_COLOR vec3(0.04647059, 0.11082353, 0.11470588)
#elif COLOR_SCHEME == 5  // Psychedelic
  #define OMNI_TINT 0.45
  #define AMBIENT_MIDDLE_COLOR vec3(0.85 , 0.47058824, 0.17921569)
  #define AMBIENT_DAY_COLOR vec3(0.91021875, 0.95771875, 0.472625)
  #define AMBIENT_NIGHT_COLOR vec3(0.04223712, 0.04566177, 0.05393796) * NIGHT_BRIGHT

  #define HI_MIDDLE_COLOR vec3(0.1745098, 0.22352941, 0.34901961)
  #define HI_DAY_COLOR vec3(0.02745098, 0.22941176, 0.71176471)
  #define HI_NIGHT_COLOR vec3(0.00905881, 0.02078822, 0.039) * NIGHT_BRIGHT

  #define LOW_MIDDLE_COLOR vec3(1.0, 0.4, 0.194)
  #define LOW_DAY_COLOR vec3(0.36019608, 0.60058824, 1.0)
  #define LOW_NIGHT_COLOR vec3(0.01392647, 0.0415147, 0.0675) * NIGHT_BRIGHT

  #define WATER_COLOR vec3(0.018, 0.12 , 0.18)
#elif COLOR_SCHEME == 6  // Cocoa
  #define OMNI_TINT 0.4
  #define AMBIENT_MIDDLE_COLOR vec3(0.918528, 0.660192, 0.301392)
  #define AMBIENT_DAY_COLOR vec3(0.897, 0.897, 0.5718375)
  #define AMBIENT_NIGHT_COLOR vec3(0.04693014, 0.0507353, 0.05993107) * NIGHT_BRIGHT

  #define HI_MIDDLE_COLOR vec3(0.117, 0.26, 0.494)
  #define HI_DAY_COLOR vec3(0.234, 0.403, 0.676)
  #define HI_NIGHT_COLOR vec3(0.014, 0.019, 0.031) * NIGHT_BRIGHT

  #define LOW_MIDDLE_COLOR vec3(1.183, 0.858, 0.611)
  #define LOW_DAY_COLOR vec3(0.52, 0.975, 1.3)
  #define LOW_NIGHT_COLOR vec3(0.022, 0.029, 0.049) * NIGHT_BRIGHT

  #define WATER_COLOR vec3(0.018, 0.12 , 0.18)
#endif

#if BLOCKLIGHT_TEMP == 0
  #define CANDLE_BASELIGHT vec3(0.29975, 0.15392353, 0.0799)
#elif BLOCKLIGHT_TEMP == 1
  #define CANDLE_BASELIGHT vec3(0.27475, 0.17392353, 0.0899)
#elif BLOCKLIGHT_TEMP == 2
  #define CANDLE_BASELIGHT vec3(0.24975, 0.19392353, 0.0999)
#elif BLOCKLIGHT_TEMP == 3
  #define CANDLE_BASELIGHT vec3(0.22, 0.19, 0.14)
#else
  #define CANDLE_BASELIGHT vec3(0.19, 0.19, 0.19)
#endif

vec3 day_blend(vec3 middle, vec3 day, vec3 night) {
  // f(x) = min(-((x-.25)^2)∙20 + 1.25, 1)
  // g(x) = min(-((x-.75)^2)∙50 + 3.125, 1)

  vec3 day_color = mix(middle, day, day_mixer);
  vec3 night_color = mix(middle, night, night_mixer);

  return mix(day_color, night_color, step(0.5, day_moment));
}

float day_blend_float(float middle, float day, float night) {
  // f(x) = min(-((x-.25)^2)∙20 + 1.25, 1)
  // g(x) = min(-((x-.75)^2)∙50 + 3.125, 1)

  float day_value = mix(middle, day, day_mixer);
  float night_value = mix(middle, night, night_mixer);

  return mix(day_value, night_value, step(0.5, day_moment));
}

// Ambient color luma per hour in exposure calculation
#if !defined UNKNOWN_DIM
  #define EXPOSURE_DAY 1.0
  #define EXPOSURE_MIDDLE 1.0
  #define EXPOSURE_NIGHT 0.01
#else
  #define EXPOSURE_DAY 1.0
  #define EXPOSURE_MIDDLE 1.0
  #define EXPOSURE_NIGHT 1.0
#endif

// Fog parameter per hour
#if VOL_LIGHT == 1 || (VOL_LIGHT == 2 && defined SHADOW_CASTING) || defined UNKNOWN_DIM
    #define FOG_DENSITY 3.0
#else
  #define FOG_DAY 3.0
  #define FOG_MIDDLE 2.0
  #define FOG_NIGHT 3.0
#endif
