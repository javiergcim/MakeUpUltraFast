/* Config, uniforms, ins, outs */
#include "/lib/config.glsl"

uniform mat4 gbufferModelView;

in vec3 vaPosition;

out vec2 texcoord;
flat out vec3 up_vec;

void main() {
  gl_Position = vec4(vaPosition.xy * 2.0 - 1.0, 0.0, 1.0);
  texcoord = vaPosition.xy;
  up_vec = normalize(gbufferModelView[1].xyz);
}

