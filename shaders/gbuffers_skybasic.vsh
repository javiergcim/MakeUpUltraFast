#version 120
/* MakeUp Ultra Fast - gbuffers_skybasic.vsh
Render: Sky

Javier Garduño - GNU Lesser General Public License v3.0
*/

// 'Global' constants from system
uniform mat4 gbufferModelView;

// Varyings (per thread shared variables)
varying vec3 up_vec;
varying vec4 star_data;

void main() {
  gl_Position = ftransform();

  up_vec = normalize(gbufferModelView[1].xyz);
  star_data = vec4(gl_Color.rgb, float(gl_Color.r == gl_Color.g && gl_Color.g == gl_Color.b && gl_Color.r > 0.0));
}
