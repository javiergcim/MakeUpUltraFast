#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

/* Config, uniforms, ins, outs */
uniform int isEyeInWater;
uniform mat4 gbufferProjectionInverse;
uniform float viewWidth;
uniform float viewHeight;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform float rainStrength;

varying vec3 up_vec;
varying vec4 star_data;

#include "/lib/dither.glsl"
#include "/lib/luma.glsl"

void main() {
  #if defined THE_END || defined NETHER
    vec4 block_color = vec4(0.0, 0.0, 0.0, 1.0);
    vec3 background_color = ZENITH_DAY_COLOR;
  #else
    // Toma el color puro del bloque
    vec4 block_color = vec4(star_data.rgb, 1.0);

    #if AA_TYPE > 0
      float dither = shifted_dither13(gl_FragCoord.xy);
    #else
      float dither = dither13(gl_FragCoord.xy);
    #endif

    dither = (dither - .5) * 0.0625;

    #ifdef UNKNOWN_DIM
      vec3 hi_sky_color = skyColor;
      vec3 low_sky_color = fogColor;
    #else
      vec3 hi_sky_color = day_blend(
        ZENITH_SUNSET_COLOR,
        ZENITH_DAY_COLOR,
        ZENITH_NIGHT_COLOR
        );

      hi_sky_color = mix(
        hi_sky_color,
        ZENITH_SKY_RAIN_COLOR * luma(hi_sky_color),
        rainStrength
      );

      vec3 low_sky_color = day_blend(
        HORIZON_SUNSET_COLOR,
        HORIZON_DAY_COLOR,
        HORIZON_NIGHT_COLOR
        );

      low_sky_color = mix(
        low_sky_color,
        HORIZON_SKY_RAIN_COLOR * luma(low_sky_color),
        rainStrength
      );
    #endif

    vec4 fragpos = gbufferProjectionInverse *
    (
      vec4(
        gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y),
        gl_FragCoord.z,
        1.0
      ) * 2.0 - 1.0
    );
    vec3 nfragpos = normalize(fragpos.xyz);
    float n_u = clamp(dot(nfragpos, up_vec) + dither, 0.0, 1.0);
    vec3 background_color = mix(
      low_sky_color,
      hi_sky_color,
      sqrt(n_u)
    );

    if (star_data.a < 0.9) {
      block_color.rgb = background_color;
    }

  #endif

  #include "/src/writebuffers.glsl"
}
