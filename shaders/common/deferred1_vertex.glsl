/* Config, uniforms, ins, outs */
#include "/lib/config.glsl"

uniform mat4 gbufferModelView;

in vec3 vaPosition;

out vec2 texcoord;

void main() {
  gl_Position = vec4(vaPosition.xy * 2.0 - 1.0, 0.0, 1.0);
  texcoord = vaPosition.xy;
}