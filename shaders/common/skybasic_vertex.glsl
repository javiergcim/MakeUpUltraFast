#include "/lib/config.glsl"

/* Config, uniforms, ins, outs */
uniform mat4 gbufferModelView;
uniform mat4 modelViewMatrix;

varying vec3 up_vec;
varying vec4 star_data;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

void main() {
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
