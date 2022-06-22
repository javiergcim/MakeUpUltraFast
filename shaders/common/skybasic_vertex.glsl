#include "/lib/config.glsl"

// Pseudo-uniforms uniforms
uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;

#include "/iris_uniforms/pixel_size_x.glsl"
#include "/iris_uniforms/pixel_size_y.glsl"
#include "/iris_uniforms/frame_mod.glsl"
#include "/iris_uniforms/taa_offset.glsl"

/* Config, uniforms, ins, outs */
uniform mat4 gbufferModelView;

varying vec3 up_vec;
varying vec4 star_data;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

void main() {
  // Pseudo-uniforms section
  #if AA_TYPE > 0
    int frame_mod = frame_mod();
    vec2 pixel_size = vec2(pixel_size_x(), pixel_size_y());
    vec2 taa_offset = taa_offset(frame_mod, pixel_size);
  #endif
  
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
  #if AA_TYPE > 0
    gl_Position.xy += taa_offset * gl_Position.w;
  #endif

  up_vec = normalize(gbufferModelView[1].xyz);
  star_data =
    vec4(
      gl_Color.rgb * .25,
      float(
        gl_Color.r == gl_Color.g &&
        gl_Color.g == gl_Color.b &&
        gl_Color.r > 0.0
      )
    );
}
