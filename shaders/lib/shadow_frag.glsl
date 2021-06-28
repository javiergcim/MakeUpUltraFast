/* MakeUp - shadow_frag.glsl
Fragment shadow function.

Javier Garduño - GNU Lesser General Public License v3.0
*/

float get_shadow(vec3 the_shadow_pos) {
  float shadow_sample = 1.0;

    #if SHADOW_TYPE == 0  // Pixelated
      shadow_sample = texture2D(shadowtex1, vec3(the_shadow_pos.xy, shadow_pos.z - 0.001));
    #elif SHADOW_TYPE == 1  // Soft
      #if MC_VERSION >= 11300
        #if AA_TYPE > 0
          float dither = shifted_texture_noise_64(gl_FragCoord.xy, colortex5);
        #else
          float dither = texture_noise_64(gl_FragCoord.xy, colortex5);
        #endif
      #else
        #if AA_TYPE > 0
          float dither = timed_hash12(gl_FragCoord.xy);
        #else
          float dither = dither_grad_noise(gl_FragCoord.xy);
        #endif
      #endif

      #if SHADOW_RES == 0 || SHADOW_RES == 1
        float new_z = the_shadow_pos.z - 0.0025 - (0.00045 * dither);
      #elif SHADOW_RES == 2 || SHADOW_RES == 3
        float new_z = the_shadow_pos.z - 0.001 - (0.0003 * dither);
      #elif SHADOW_RES == 4 || SHADOW_RES == 5
        float new_z = the_shadow_pos.z - 0.00075 - (0.00015 * dither);
      #elif SHADOW_RES == 6 || SHADOW_RES == 7
        float new_z = the_shadow_pos.z - 0.0000 - (0.00005 * dither);
      #endif

      float dither_base = dither;
      dither *= 6.283185307;

      float current_radius;
      vec2 offset;
      shadow_sample = 0.0;

      current_radius = dither_base * .8 + .2;
      offset = (vec2(cos(dither), sin(dither)) * current_radius * SHADOW_BLUR) / shadowMapResolution;

      shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + offset, new_z)).r;
      shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st - offset, new_z)).r;

      shadow_sample *= 0.5;
    #endif

  return shadow_sample;
}
