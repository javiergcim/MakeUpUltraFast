#include "/lib/config.glsl"

// Pseudo-uniforms uniforms
uniform float viewWidth;
uniform float viewHeight;

#include "/iris_uniforms/pixel_size_x.glsl"
#include "/iris_uniforms/pixel_size_y.glsl"

/* Config, uniforms, ins, outs */
uniform sampler2D tex;
uniform float far;

#if MC_VERSION >= 11900
  uniform float darknessFactor;
#endif

#if V_CLOUDS == 0 || defined UNKNOWN_DIM
  // uniform float pixel_size_x;
  // uniform float pixel_size_y;
  uniform sampler2D gaux4;
#endif

// Varyings (per thread shared variables)
varying vec2 texcoord;
varying vec4 tint_color;
varying float frog_adjust;

void main() {
  // Pseudo-uniforms section
  #if V_CLOUDS == 0 || defined UNKNOWN_DIM
    float pixel_size_x = pixel_size_x();
    float pixel_size_y = pixel_size_y();
  #endif

  #if V_CLOUDS == 0 || defined UNKNOWN_DIM
    vec4 block_color = texture2D(tex, texcoord) * tint_color;
    #include "/src/cloudfinalcolor.glsl"
  #else
    vec4 block_color = vec4(0.0);
  #endif

  #include "/src/writebuffers.glsl"
}
