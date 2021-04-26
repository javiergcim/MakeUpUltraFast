#version 130
/* MakeUp - gbuffers_skybasic.vsh
Render: Sky

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define NO_SHADOWS

#include "/lib/config.glsl"

// 'Global' constants from system
uniform mat4 gbufferModelView;

// Varyings (per thread shared variables)
flat out vec3 up_vec;
out vec4 star_data;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

void main() {
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  #if AA_TYPE > 0
    gl_Position.xy += offsets[frame_mod] * gl_Position.w * pixel_size;
  #endif

  up_vec = normalize(gbufferModelView[1].xyz);
  star_data =
    vec4(
      gl_Color.rgb,
      float(
        gl_Color.r == gl_Color.g &&
        gl_Color.g == gl_Color.b &&
        gl_Color.r > 0.0
      )
    );
}
