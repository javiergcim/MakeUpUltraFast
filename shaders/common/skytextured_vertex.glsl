#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

/* Config, uniforms, ins, outs */
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;
uniform vec3 chunkOffset;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

out vec2 texcoord;
out vec4 tint_color;
flat out float sky_luma_correction;

in vec2 vaUV0;  // Texture coordinates
in vec4 vaColor;
in vec3 vaPosition;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

void main() {
  texcoord = vaUV0;
  tint_color = vaColor;

  sky_luma_correction = day_blend_float(
    EXPOSURE_MIDDLE,
    EXPOSURE_DAY,
    EXPOSURE_NIGHT
  );

  #if (VOL_LIGHT == 1 && !defined NETHER) || (VOL_LIGHT == 2 && defined SHADOW_CASTING && !defined NETHER)
    sky_luma_correction = 3.5 / ((sky_luma_correction * -2.5) + 3.5);
  #else
    sky_luma_correction = 1.5 / ((sky_luma_correction * -2.5) + 3.5);
  #endif

  gl_Position = (projectionMatrix * modelViewMatrix) * vec4(vaPosition + chunkOffset, 1.0);
  #if AA_TYPE > 0
    // gl_Position.xy += offsets[frame_mod] * gl_Position.w * pixel_size;
    gl_Position.xy += taa_offset * gl_Position.w;
  #endif
}
