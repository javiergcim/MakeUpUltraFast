float get_shadow(vec3 the_shadow_pos) {
  float shadow_sample = 1.0;

  if (the_shadow_pos.x > 0.0 && the_shadow_pos.x < 1.0 &&
      the_shadow_pos.y > 0.0 && the_shadow_pos.y < 1.0 &&
      the_shadow_pos.z > 0.0 && the_shadow_pos.z < 1.0) {

    #if SHADOW_TYPE == 0  // Pixelated
      shadow_sample = shadow2D(shadowtex1, the_shadow_pos).r;
    #elif SHADOW_TYPE == 1  // Soft
      float dither_o = grid_noise(gl_FragCoord.xy);
      float dither = dither_o * 25.132741228718345; // PI * 8
      dither_o = dither_o * .7 + .3;
      vec2 offset = (vec2(cos(dither), sin(dither)) * dither_o / shadowMapResolution * 2.0);

      #if SHADOW_RES == 0 || SHADOW_RES == 1
        float new_z = the_shadow_pos.z - (0.0004 * dither_o);
      #elif SHADOW_RES == 2 || SHADOW_RES == 3
        float new_z = the_shadow_pos.z - (0.0003 * dither_o);
      #elif SHADOW_RES == 4 || SHADOW_RES == 5
        float new_z = the_shadow_pos.z - (0.00015 * dither_o);
      #endif

      shadow_sample = shadow2D(shadowtex1, vec3(the_shadow_pos.st + offset, new_z)).r;
      shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st - offset, new_z)).r;
      shadow_sample *= 0.5;
    #endif

    shadow_sample = mix(1.0, shadow_sample, shadow_force);
  }

  return shadow_sample;
}
