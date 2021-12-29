/* MakeUp - shadow_frag.glsl
Fragment shadow function.

Javier Garduño - GNU Lesser General Public License v3.0
*/

float get_shadow(vec3 the_shadow_pos) {
  float shadow_sample = 1.0;

  #if SHADOW_TYPE == 0  // Pixelated
     shadow_sample = texture(shadowtex1, vec3(the_shadow_pos.xy, the_shadow_pos.z - 0.001));
  #elif SHADOW_TYPE == 1  // Soft
    #if AA_TYPE > 0
      float dither = shifted_dither_grad_noise(gl_FragCoord.xy);
    #else
      float dither = phi_noise(uvec2(gl_FragCoord.xy));
    #endif

    #if SHADOW_RES == 0 || SHADOW_RES == 1 || SHADOW_RES == 2
      float new_z = the_shadow_pos.z - 0.001 - (0.00045 * dither);
    #elif SHADOW_RES == 3 || SHADOW_RES == 4 || SHADOW_RES == 5
      float new_z = the_shadow_pos.z - 0.0005 - (0.0003 * dither);
    #elif SHADOW_RES == 6 || SHADOW_RES == 7 || SHADOW_RES == 8
      float new_z = the_shadow_pos.z - 0.000 - (0.00015 * dither);
    #elif SHADOW_RES == 9 || SHADOW_RES == 10 || SHADOW_RES == 11
      float new_z = the_shadow_pos.z - 0.0000 - (0.00005 * dither);
    #endif

    float dither_base = dither;
    dither *= 6.283185307;

    float current_radius;
    vec2 offset;
    shadow_sample = 0.0;

    // current_radius = dither_base * .8 + .2;
    current_radius = dither_base * .95 + .05;
    offset = (vec2(cos(dither), sin(dither)) * current_radius * SHADOW_BLUR) / shadowMapResolution;

    shadow_sample += texture(shadowtex1, vec3(the_shadow_pos.st + offset, new_z));
    shadow_sample += texture(shadowtex1, vec3(the_shadow_pos.st - offset, new_z));

    shadow_sample *= 0.5;
  #endif

  return clamp(shadow_sample * 2.0, 0.0, 1.0);
}
