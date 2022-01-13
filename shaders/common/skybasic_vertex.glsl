#include "/lib/config.glsl"

/* Config, uniforms, ins, outs */
uniform mat4 gbufferModelView;
uniform vec3 chunkOffset;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

flat out vec3 up_vec;
out vec4 star_data;

in vec4 vaColor;
in vec3 vaPosition;

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

void main() {
  gl_Position = (projectionMatrix * modelViewMatrix) * vec4(vaPosition + chunkOffset, 1.0);
  #if AA_TYPE > 0
    // gl_Position.xy += offsets[frame_mod] * gl_Position.w * pixel_size;
    gl_Position.xy += taa_offset * gl_Position.w;
  #endif

  up_vec = normalize(gbufferModelView[1].xyz);
  star_data =
    vec4(
      vaColor.rgb * .25,
      float(
        vaColor.r == vaColor.g &&
        vaColor.g == vaColor.b &&
        vaColor.r > 0.0
      )
    );
}
