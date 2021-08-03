#version 120
/* MakeUp - deferred.fsh
Render: Ambient occlusion, volumetric clouds

Javier Garduño - GNU Lesser General Public License v3.0
*/

// 'Global' constants from system
uniform sampler2D colortex0;
uniform float pixel_size_x;
uniform float pixel_size_y;
uniform int pixel_mod;

// Varyings (per thread shared variables)
varying vec2 texcoord;

void main() {
  vec4 block_color = texture2D(colortex0, texcoord);

  if (pixel_mod == mod(gl_FragCoord.x + gl_FragCoord.y, 2)) {
     block_color = texture2D(colortex0, texcoord);
  } else {
    block_color =
      texture2D(colortex0, texcoord + vec2(0.0, pixel_size_y)) +
      texture2D(colortex0, texcoord + vec2(0.0, -pixel_size_y)) +
      texture2D(colortex0, texcoord + vec2(-pixel_size_x, 0.0)) +
      texture2D(colortex0, texcoord + vec2(pixel_size_x, 0.0));
    block_color *= 0.25;
  }

  /* DRAWBUFFERS:0 */
  gl_FragData[0] = block_color;
}
