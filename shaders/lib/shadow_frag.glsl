/* MakeUp - shadow_frag.glsl
Fragment shadow function.

Javier Garduño - GNU Lesser General Public License v3.0
*/

float get_shadow(vec3 the_shadow_pos) {
  float shadow_sample = 1.0;

  #if SHADOW_TYPE == 0  // Pixelated
     shadow_sample = shadow2D(shadowtex1, vec3(the_shadow_pos.xy, the_shadow_pos.z - 0.001)).r;
  #elif SHADOW_TYPE == 1  // Soft
    #if AA_TYPE > 0
      float dither = shifted_dither13(gl_FragCoord.xy, dither_shift);
    #else
      float dither = dither13(gl_FragCoord.xy);
    #endif

    #if SHADOW_RES == 0 || SHADOW_RES == 1 || SHADOW_RES == 2
      float new_z = the_shadow_pos.z - 0.001 - (0.0009 * dither);
    #elif SHADOW_RES == 3 || SHADOW_RES == 4 || SHADOW_RES == 5
      float new_z = the_shadow_pos.z - 0.0005 - (0.0006 * dither);
    #elif SHADOW_RES == 6 || SHADOW_RES == 7 || SHADOW_RES == 8
      float new_z = the_shadow_pos.z - 0.0001 - (0.0006 * dither);
    #elif SHADOW_RES == 9 || SHADOW_RES == 10 || SHADOW_RES == 11
      float new_z = the_shadow_pos.z - 0.00005 - (0.0006 * dither);
    #endif

    float current_radius = dither;
    dither *= 6.283185307;

    shadow_sample = 0.0;

    vec2 offset = (vec2(cos(dither), sin(dither)) * current_radius * SHADOW_BLUR) / shadowMapResolution;

    shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + offset, new_z)).r;
    shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st - offset, new_z)).r;

    shadow_sample *= 0.5;
  #endif

  return clamp(shadow_sample * 2.0, 0.0, 1.0);
}

#if defined COLORED_SHADOW

  vec3 get_colored_shadow(vec3 the_shadow_pos) {

    #if SHADOW_TYPE == 0  // Pixelated
      float shadow_detector = 1.0;
      float shadow_black = 1.0;
      vec4 shadow_color = vec4(1.0);

      float alpha_complement;

      shadow_detector = shadow2D(shadowtex0, vec3(the_shadow_pos.xy, the_shadow_pos.z - 0.001)).r;
      if (shadow_detector < 1.0) {
        shadow_black = shadow2D(shadowtex1, vec3(the_shadow_pos.xy, the_shadow_pos.z - 0.001)).r;
        if (shadow_black != shadow_detector) {
          shadow_color = texture2D(shadowcolor0, the_shadow_pos.xy);
          alpha_complement = 1.0 - shadow_color.a;
          shadow_color.rgb = mix(shadow_color.rgb, vec3(1.0), alpha_complement);
          shadow_color.rgb *= alpha_complement;
        }
      }
      
      shadow_color *= shadow_black;
      shadow_color.rgb = clamp(shadow_color.rgb * (1.0 - shadow_detector) + shadow_detector, vec3(0.0), vec3(1.0));

      return shadow_color.rgb;

    #elif SHADOW_TYPE == 1  // Soft
      float shadow_detector_a = 1.0;
      float shadow_black_a = 1.0;
      vec4 shadow_color_a = vec4(1.0);

      float shadow_detector_b = 1.0;
      float shadow_black_b = 1.0;
      vec4 shadow_color_b = vec4(1.0);

      float alpha_complement;

      #if AA_TYPE > 0
        float dither = shifted_dither13(gl_FragCoord.xy, dither_shift);
      #else
        float dither = dither13(gl_FragCoord.xy);
      #endif

      #if SHADOW_RES == 0 || SHADOW_RES == 1 || SHADOW_RES == 2
        float new_z = the_shadow_pos.z - 0.001 - (0.0009 * dither);
      #elif SHADOW_RES == 3 || SHADOW_RES == 4 || SHADOW_RES == 5
        float new_z = the_shadow_pos.z - 0.0005 - (0.0006 * dither);
      #elif SHADOW_RES == 6 || SHADOW_RES == 7 || SHADOW_RES == 8
        float new_z = the_shadow_pos.z - 0.0001 - (0.0006 * dither);
      #elif SHADOW_RES == 9 || SHADOW_RES == 10 || SHADOW_RES == 11
        float new_z = the_shadow_pos.z - 0.00005 - (0.0006 * dither);
      #endif

      float current_radius = dither;
      dither *= 6.283185307;

      vec2 offset = (vec2(cos(dither), sin(dither)) * current_radius * SHADOW_BLUR) / shadowMapResolution;

      shadow_detector_a = shadow2D(shadowtex0, vec3(the_shadow_pos.xy + offset, new_z)).r;
      shadow_detector_b = shadow2D(shadowtex0, vec3(the_shadow_pos.xy - offset, new_z)).r;

      if (shadow_detector_a < 1.0) {
        shadow_black_a = shadow2D(shadowtex1, vec3(the_shadow_pos.xy + offset, new_z)).r;
        if (shadow_black_a != shadow_detector_a) {
          shadow_color_a = texture2D(shadowcolor0, the_shadow_pos.xy + offset);
          alpha_complement = 1.0 - shadow_color_a.a;
          shadow_color_a.rgb = mix(shadow_color_a.rgb, vec3(1.0), alpha_complement);
          shadow_color_a.rgb *= alpha_complement;
        }
      }
      
      shadow_color_a *= shadow_black_a;

      if (shadow_detector_b < 1.0) {
        shadow_black_b = shadow2D(shadowtex1, vec3(the_shadow_pos.xy - offset, new_z)).r;
        if (shadow_black_b != shadow_detector_b) {
          shadow_color_b = texture2D(shadowcolor0, the_shadow_pos.xy - offset);
          alpha_complement = 1.0 - shadow_color_b.a;
          shadow_color_b.rgb = mix(shadow_color_b.rgb, vec3(1.0), alpha_complement);
          shadow_color_b.rgb *= alpha_complement;
        }
      }
      
      shadow_color_b *= shadow_black_b;

      shadow_detector_a = (shadow_detector_a + shadow_detector_b) * 0.5;
      shadow_detector_a = clamp(shadow_detector_a * 2.0, 0.0, 1.0);

      shadow_color_a.rgb = (shadow_color_a.rgb + shadow_color_b.rgb) * 0.5;
      shadow_color_a.rgb = mix(shadow_color_a.rgb, vec3(1.0), shadow_detector_a);

      return shadow_color_a.rgb;
    #endif

  }

#endif