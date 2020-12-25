/* MakeUp Ultra Fast - shadow_frag.glsl
Fragment shadow function.

Javier Garduño - GNU Lesser General Public License v3.0
*/

float get_shadow(vec3 the_shadow_pos) {
  float shadow_sample = 1.0;

  if (the_shadow_pos.x > 0.0 && the_shadow_pos.x < 1.0 &&
      the_shadow_pos.y > 0.0 && the_shadow_pos.y < 1.0 &&
      the_shadow_pos.z > 0.0 && the_shadow_pos.z < 1.0) {

    #if SHADOW_TYPE == 0  // Pixelated
      shadow_sample = shadow2D(shadowtex1, vec3(the_shadow_pos.xy, shadow_pos.z - 0.001)).r;
    #elif SHADOW_TYPE == 1  // Soft
      #if AA_TYPE == 1 || AA_TYPE == 2
        float dither = timed_hash12(gl_FragCoord.xy);
      #else
        float dither = grid_noise(gl_FragCoord.xy);
      #endif

      #if SHADOW_RES == 0 || SHADOW_RES == 1
        float new_z = the_shadow_pos.z - 0.0025 - (0.00045 * dither);
      #elif SHADOW_RES == 2 || SHADOW_RES == 3
        float new_z = the_shadow_pos.z - 0.001 - (0.0003 * dither);
      #elif SHADOW_RES == 4 || SHADOW_RES == 5
        float new_z = the_shadow_pos.z - 0.0005 - (0.00015 * dither);
      #endif

      float dither_base = dither;
      dither *= 6.283185307;

      float inv_steps = 1.0 / SHADOW_STEPS;
      float sample_angle_increment = 3.1415926535 * inv_steps;
      float current_radius;
      vec2 offset;
      shadow_sample = 0.0;

      for (int i = 0; i < SHADOW_STEPS; i++) {
        dither += sample_angle_increment;
        current_radius = dither_base * .7 + .3;
        offset = (vec2(cos(dither), sin(dither)) * current_radius * SHADOW_BLUR) / shadowMapResolution;

        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + offset, new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st - offset, new_z)).r;
      }

      shadow_sample *= (inv_steps * .5);
    #endif
  }

  return shadow_sample;
}
