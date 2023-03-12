#include "/lib/config.glsl"

/* Config, uniforms, ins, outs */
uniform sampler2D tex;
uniform float far;
uniform float blindness;

#if MC_VERSION >= 11900
  uniform float darknessFactor;
  uniform float darknessLightFactor;
#endif

#if V_CLOUDS == 0 || defined UNKNOWN_DIM
  uniform mat4 gbufferProjectionInverse;
  uniform float pixel_size_x;
  uniform float pixel_size_y;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec4 tint_color;
varying float frog_adjust;

#if V_CLOUDS == 0 || defined UNKNOWN_DIM
  varying vec3 up_vec;
  varying vec3 hi_sky_color;
  varying vec3 low_sky_color;
#endif

#if V_CLOUDS == 0 || defined UNKNOWN_DIM
  #include "/lib/dither.glsl"
#endif

void main() {
  #if V_CLOUDS == 0 || defined UNKNOWN_DIM
    vec4 block_color = texture2D(tex, texcoord) * tint_color;

    #if AA_TYPE > 0
      float dither = shifted_r_dither(gl_FragCoord.xy);
    #else
      float dither = r_dither(gl_FragCoord.xy);
    #endif

    #include "/src/sky_color_fragment.glsl"
    #include "/src/cloudfinalcolor.glsl"
  #else
    vec4 block_color = vec4(0.0);
  #endif

  #include "/src/writebuffers.glsl"
}
