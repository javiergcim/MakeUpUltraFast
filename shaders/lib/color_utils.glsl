/* MakeUp - color_utils.glsl
Usefull data for color manipulation.

Javier Garduño - GNU Lesser General Public License v3.0
*/

uniform float day_moment;
uniform float day_mixer;
uniform float night_mixer;

#if COLOR_SCHEME == 0  // Legacy
  #define OMNI_TINT 0.5
  #define AMBIENT_MIDDLE_COLOR vec3(1.0764, 0.54453175, 0.23638589)
  #define AMBIENT_DAY_COLOR vec3(0.88504, 0.88504, 0.8372)
  #define AMBIENT_NIGHT_COLOR vec3(0.04693014, 0.0507353 , 0.05993107) * NIGHT_BRIGHT

  #define HI_MIDDLE_COLOR vec3(0.22941177, 0.45372549, 1.07568627)
  #define HI_DAY_COLOR vec3(0.182, 0.351, 0.754)
  #define HI_NIGHT_COLOR vec3(0.00647058, 0.01270587, 0.03) * NIGHT_BRIGHT

  #define LOW_MIDDLE_COLOR vec3(1.3, 0.65764706, 0.28549019)
  #define LOW_DAY_COLOR vec3(0.572, 1.014, 1.248)
  #define LOW_NIGHT_COLOR vec3(0.01078431, 0.02117647, 0.05) * NIGHT_BRIGHT

  #define WATER_COLOR vec3(0.018, 0.12 , 0.18)
  #define CANDLE_BASELIGHT vec3(0.24975, 0.19392353, 0.0999)
#elif COLOR_SCHEME == 1  // Cocoa
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
  #define CANDLE_BASELIGHT vec3(0.24975, 0.19392353, 0.0999)
#elif COLOR_SCHEME == 2  // Captain
  #define OMNI_TINT 0.5
  #define AMBIENT_MIDDLE_COLOR vec3(0.84456, 0.52992, 0.26496001)
  #define AMBIENT_DAY_COLOR vec3(0.83064961, 0.93448079, 1.1032065)
  #define AMBIENT_NIGHT_COLOR vec3(0.02597646, 0.05195295, 0.069) * NIGHT_BRIGHT

  #define HI_MIDDLE_COLOR vec3(0.30225, 0.359775, 0.519675)
  #define HI_DAY_COLOR vec3(0.104, 0.26, 0.507)
  #define HI_NIGHT_COLOR vec3(0.004 ,0.01, 0.0195) * NIGHT_BRIGHT

  #define LOW_MIDDLE_COLOR vec3(1.3, 1.079, 0.494)
  #define LOW_DAY_COLOR vec3(0.65, 0.91, 1.3)
  #define LOW_NIGHT_COLOR vec3(0.025, 0.035, 0.05) * NIGHT_BRIGHT

  #define WATER_COLOR vec3(0.018, 0.12 , 0.18)
  #define CANDLE_BASELIGHT vec3(0.24975, 0.19392353, 0.0999)
#elif COLOR_SCHEME == 3  // Shoka
  #define OMNI_TINT 0.5
  #define AMBIENT_MIDDLE_COLOR vec3(0.8832, 0.6348, 0.2898)
  #define AMBIENT_DAY_COLOR vec3(0.91640625, 0.91640625, 0.635375)
  #define AMBIENT_NIGHT_COLOR vec3(0.02815808, 0.03044118, 0.03595864) * NIGHT_BRIGHT

  #define HI_MIDDLE_COLOR vec3(0.13, 0.22176471, 0.33137255)
  #define HI_DAY_COLOR vec3(0.13, 0.22176471, 0.33137255)
  #define HI_NIGHT_COLOR vec3(0.014, 0.019, 0.025) * NIGHT_BRIGHT

  #define LOW_MIDDLE_COLOR vec3(0.715, 0.611, 0.52)
  #define LOW_DAY_COLOR vec3(0.364 , 0.6825, 0.91)
  #define LOW_NIGHT_COLOR vec3(0.0213, 0.0306, 0.0387) * NIGHT_BRIGHT

  #define WATER_COLOR vec3(0.018, 0.12 , 0.18)
  #define CANDLE_BASELIGHT vec3(0.24975, 0.19392353, 0.0999)
#elif COLOR_SCHEME == 4  // Ethereal
  #define OMNI_TINT 0.5
  #define AMBIENT_MIDDLE_COLOR vec3(0.987528, 0.591192, 0.301392)
  #define AMBIENT_DAY_COLOR vec3(0.90, 0.84, 0.79)
  #define AMBIENT_NIGHT_COLOR vec3(0.0317353, 0.0467353, 0.0637353) * NIGHT_BRIGHT

  #define HI_MIDDLE_COLOR vec3(0.0745098 , 0.22352941, 0.54901961)
  #define HI_DAY_COLOR vec3(0.0745098 , 0.22352941, 0.54901961)
  #define HI_NIGHT_COLOR vec3(0.0168, 0.0228, 0.03) * NIGHT_BRIGHT

  #define LOW_MIDDLE_COLOR vec3(1.183, 0.658, 0.311)
  #define LOW_DAY_COLOR vec3(0.65, 0.91, 1.3)
  #define LOW_NIGHT_COLOR vec3(0.02556, 0.03672, 0.04644) * NIGHT_BRIGHT

  #define WATER_COLOR vec3(0.018, 0.12 , 0.18)
  #define CANDLE_BASELIGHT vec3(0.24975, 0.19392353, 0.0999)
#elif COLOR_SCHEME == 5  // Vivid
  #define OMNI_TINT 0.35
  #define AMBIENT_MIDDLE_COLOR vec3(0.85 , 0.47058824, 0.17921569)
  #define AMBIENT_DAY_COLOR vec3(1.008125, 1.008125, 0.4475)
  #define AMBIENT_NIGHT_COLOR vec3(0.04223712, 0.04566177, 0.05393796) * NIGHT_BRIGHT

  #define HI_MIDDLE_COLOR vec3(0.01960784, 0.16862745, 0.65882353)
  #define HI_DAY_COLOR vec3(0.02745098, 0.22941176, 0.71176471)
  #define HI_NIGHT_COLOR vec3(0.00905881, 0.02078822, 0.039) * NIGHT_BRIGHT

  #define LOW_MIDDLE_COLOR vec3(1.0 , 0.47058824, 0.03921569)
  #define LOW_DAY_COLOR vec3(0.36019608, 0.60058824, 1.0)
  #define LOW_NIGHT_COLOR vec3(0.01856862, 0.05535294, 0.09) * NIGHT_BRIGHT

  #define WATER_COLOR vec3(0.018, 0.12 , 0.18)
  #define CANDLE_BASELIGHT vec3(0.29975, 0.15392353, 0.0799)
#elif COLOR_SCHEME == 6  // Vanilla vibe
  #define OMNI_TINT 0.5
  #define AMBIENT_MIDDLE_COLOR vec3(0.987528, 0.591192, 0.301392)
  #define AMBIENT_DAY_COLOR vec3(0.85, 0.83, 0.5)
  #define AMBIENT_NIGHT_COLOR vec3(0.0317353, 0.0467353, 0.0637353) * NIGHT_BRIGHT

  #define HI_MIDDLE_COLOR vec3(0.22941177, 0.45372549, 1.07568627)
  #define HI_DAY_COLOR vec3(0.182, 0.351, 0.754)
  #define HI_NIGHT_COLOR vec3(0.00647058, 0.01270587, 0.03) * NIGHT_BRIGHT

  #define LOW_MIDDLE_COLOR vec3(1.3, 0.65764706, 0.28549019)
  #define LOW_DAY_COLOR vec3(0.572, 1.014, 1.248)
  #define LOW_NIGHT_COLOR vec3(0.01078431, 0.02117647, 0.05) * NIGHT_BRIGHT

  #define WATER_COLOR vec3(0.018, 0.12 , 0.18)
  #define CANDLE_BASELIGHT vec3(0.24975, 0.19392353, 0.0999)
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
const float ambient_exposure[25] =
  float[25](
  1.0, // 6
  1.0, // 7
  1.0, // 8
  1.0, // 9
  1.0, // 10
  1.0, // 11
  1.0, // 12
  1.0, // 1
  1.0, // 2
  1.0, // 3
  1.0, // 4
  1.0, // 5
  1.0, // 6
  .4, // 7
  .01, // 8
  .01, // 9
  .01, // 10
  .01, // 11
  .01, // 12
  .01, // 1
  .01, // 2
  .01, // 3
  .01, // 4
  .4, // 5
  1.0 // 6
  );

// Fog parameter per hour
#if defined VOL_LIGHT && defined SHADOW_CASTING
    #define FOG_DENSITY 3.0
#else
  const float fog_density[25] =
    float[25](
    2.0, // 6
    2.5, // 7
    3.0, // 8
    3.0, // 9
    3.0, // 10
    3.0, // 11
    3.0, // 12
    3.0, // 13
    3.0, // 14
    3.0, // 15
    3.0, // 16
    2.5, // 17
    2.0, // 18
    2.25, // 19
    2.5, // 20
    3.0, // 21
    3.0, // 22
    3.0, // 23
    3.0, // 24
    3.0, // 1
    3.0, // 2
    3.0, // 3
    2.5, // 4
    2.25, // 5
    2.0 // 6
    );
#endif

// vec3 rgb2hsv(vec3 c) {
//     vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
//     vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
//     vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
//
//     float d = q.x - min(q.w, q.y);
//     float e = 1.0e-10;
//     return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
// }
//
// vec3 hsv2rgb(vec3 c) {
//     vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
//     vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
//     return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
// }
