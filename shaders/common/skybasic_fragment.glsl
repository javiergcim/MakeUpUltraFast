#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

/* Config, uniforms, ins, outs */
uniform sampler2D gaux4;
uniform float pixel_size_x;
uniform float pixel_size_y;

varying vec4 star_data;

void main() {
  #if defined THE_END || defined NETHER
    // vec4 background_color = vec4(ZENITH_DAY_COLOR, 1.0);
    vec4 block_color = vec4(0.0, 0.0, 0.0, 1.0);
  #else
    // Toma el color puro del bloque
    vec4 background_color = texture2D(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y));
    vec4 block_color = star_data;

    block_color = mix(background_color, block_color, block_color);
    block_color.a = star_data.a;
  #endif

  #include "/src/writebuffers.glsl"
}
