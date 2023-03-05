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

// varying vec3 up_vec;
varying vec4 star_data;

// #include "/lib/dither.glsl"
// #include "/lib/luma.glsl"

void main() {
  #if defined THE_END || defined NETHER
    vec4 block_color = vec4(0.0, 0.0, 0.0, 1.0);
    vec3 background_color = ZENITH_DAY_COLOR;
  #else
    // Toma el color puro del bloque
    vec4 block_color = vec4(star_data.rgb, 1.0);
    vec3 background_color = vec3(-1.0);

    if (star_data.a < 0.9) {
      block_color.rgb = background_color;
    }

  #endif

  #include "/src/writebuffers.glsl"
}
