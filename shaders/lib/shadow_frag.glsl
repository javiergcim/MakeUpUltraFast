float get_shadow(vec3 the_shadow_pos) {
  float shadow_sample = 1.0;

  if (the_shadow_pos.x > 0.0 && the_shadow_pos.x < 1.0 &&
      the_shadow_pos.y > 0.0 && the_shadow_pos.y < 1.0 &&
      the_shadow_pos.z > 0.0 && the_shadow_pos.z < 1.0) {

    #if SHADOW_TYPE == 0  // Pixelated
      shadow_sample = shadow2D(shadowtex1, the_shadow_pos).r;
    #elif SHADOW_TYPE == 1  // Soft

      shadow_sample = shadow2D(shadowtex1, the_shadow_pos).r;
      #if SHADOW_RES == 0
        float new_z = the_shadow_pos.z - .00045;

        // vec2 offset = vec2(halton[i] / shadowMapResolution * SHADOW_SMOOTH);

        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0008300781, -0.0024902344), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0008300781, 0.0024902344), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0041503906, 0.0008300781), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0024902344, -0.0041503906), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0041503906, 0.0041503906), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0058105469, -0.0008300781), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0024902344, 0.0058105469), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0058105469, -0.0058105469), new_z)).r;
      #elif SHADOW_RES == 1 || SHADOW_RES == 2
        float new_z = the_shadow_pos.z - .0002;

        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0004882812, -0.0014648438), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0004882812, 0.0014648438), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0024414062, 0.0004882812), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0014648438, -0.0024414062), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0024414062, 0.0024414062), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0034179688, -0.0004882812), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0014648438, 0.0034179688), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0034179688, -0.0034179688), new_z)).r;
      #elif SHADOW_RES == 3 || SHADOW_RES == 4
        float new_z = the_shadow_pos.z - .0001;

        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0002441406, -0.0007324219), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0002441406, 0.0007324219), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0012207031, 0.0002441406), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0007324219, -0.0012207031), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0012207031, 0.0012207031), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0017089844, -0.0002441406), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0007324219, 0.0017089844), new_z)).r;
        shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0017089844, -0.0017089844), new_z)).r;
      #elif SHADOW_RES == 5
      float new_z = the_shadow_pos.z - .00005;

      shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0001220703, -0.0003662109), new_z)).r;
      shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0001220703, 0.0003662109), new_z)).r;
      shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0006103516, 0.0001220703), new_z)).r;
      shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0003662109, -0.0006103516), new_z)).r;
      shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0006103516, 0.0006103516), new_z)).r;
      shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(-0.0008544922, -0.0001220703), new_z)).r;
      shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0003662109, 0.0008544922), new_z)).r;
      shadow_sample += shadow2D(shadowtex1, vec3(the_shadow_pos.st + vec2(0.0008544922, -0.0008544922), new_z)).r;
      #endif

      // Average
      shadow_sample *= 0.111111111111111;
    #endif

    shadow_sample = mix(1.0, shadow_sample, shadow_force);
    shadow_sample = (shadow_sample * .5) + .5;
  }

  return shadow_sample;
}
