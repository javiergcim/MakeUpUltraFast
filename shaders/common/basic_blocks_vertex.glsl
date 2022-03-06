#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

uniform vec3 chunkOffset;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform int current_hour_floor;
uniform int current_hour_ceil;
uniform float current_hour_fract;

in ivec2 vaUV2;  // Light coordinates
in vec2 vaUV0;  // Texture coords
in vec4 vaColor;
in vec3 vaPosition;

out vec4 tint_color;
out vec2 texcoord;
out float basic_light;

#include "/lib/luma.glsl"
#include "/lib/basic_utils.glsl"

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

void main() {
  #include "/src/basiccoords_vertex.glsl"
  #include "/src/position_vertex.glsl"
  tint_color = vaColor;

  vec2 va_UV2 = vec2(vaUV2);

  vec2 lmcoord = va_UV2 * 0.0041841004184100415;

  vec2 basic_light_2 = (max(lmcoord, vec2(0.065)) - vec2(0.065)) * 1.06951871657754;

  basic_light = (mix(
      ambient_exposure[current_hour_floor],
      ambient_exposure[current_hour_ceil],
      current_hour_fract
    ) + .05) * basic_light_2.y;

  basic_light = clamp((basic_light_2.x * 0.2) + basic_light, 0.0, 1.0);
}
