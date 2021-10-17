#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

/* Config, uniforms, ins, outs */
uniform sampler2D tex;

varying vec2 texcoord;
varying vec4 tint_color;
varying float sky_luma_correction;  // Flat

void main() {
  #if defined THE_END || defined NETHER
    vec4 block_color = vec4(HI_DAY_COLOR, 1.0);
    vec3 background_color = HI_DAY_COLOR;
  #else
    // Toma el color puro del bloque
    vec4 block_color = texture2D(tex, texcoord) * tint_color;
    
    block_color.rgb *= sky_luma_correction;
  #endif

  #include "/src/writebuffers.glsl"
}
