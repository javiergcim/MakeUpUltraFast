/* MakeUp Ultra Fast - water.glsl
Water reflection and refraction related functions.
Based on work from RRe36.
https://rre36.github.io/
*/

#if SUN_REFLECTION == 1
  #ifndef NETHER
    #ifndef THE_END

      vec3 sun_reflection(vec3 fragpos) {
        vec3 astro_pos = sunPosition;
        if (worldTime > 12900) {
          astro_pos = moonPosition;
        }
        float astro_vector =
          max(dot(normalize(fragpos), normalize(astro_pos)), 0.0);

        return vec3(
          clamp(
            smoothstep(
              0.997, 1.0, astro_vector) *
              clamp(4.0 * lmcoord.y - 3.0, 0.0, 1.0) *
              (1.0 - rainStrength),
            0.0,
            1.0
          ));
      }

    #endif
  #endif
#endif

vec3 normal_waves(vec3 pos) {
  float timer = frameTimeCounter;

  vec3 wave_1 =
    texture2D(noisetex, (pos.xy * 0.0625) + (timer * .04)).rgb * 2.0 - 1.0;
  vec3 wave_2 =
    texture2D(noisetex, (pos.yx * 0.03125) - (timer * .02)).rgb * 3.0 - 1.5;

  vec3 final_wave = wave_1 + wave_2;

  return normalize(final_wave);
}

vec3 to_NDC(vec3 pos){
  vec4 i_proj_diag =
    vec4(
      gbufferProjectionInverse[0].x,
      gbufferProjectionInverse[1].y,
      gbufferProjectionInverse[2].zw
    );
    vec3 p3 = pos * 2.0 - 1.0;
    vec4 fragpos = i_proj_diag * p3.xyzz + gbufferProjectionInverse[3];

    return fragpos.xyz / fragpos.w;
}

vec3 camera_to_screen(vec3 fragpos) {
  vec4 pos  = gbufferProjection * vec4(fragpos, 1.0);
   pos /= pos.w;

  return pos.xyz * 0.5 + 0.5;
}

vec3 refraction(vec3 fragpos, vec3 color, vec3 refraction) {
  vec3 pos = camera_to_screen(fragpos);

  #if REFRACTION == 1

    float  refraction_strength = 0.1;
    refraction_strength /= 1.0 + length(fragpos) * 0.4;
    vec2 medium_texcoord = pos.xy + refraction.xy * refraction_strength;

    return texture2D(gaux1, medium_texcoord.st).rgb * color;

  #else

    return texture2D(gaux1, pos.xy).rgb * color;

  #endif
}

vec3 get_normals(vec3 bump) {
  float NdotE = abs(dot(water_normal, normalize(position2.xyz)));

  bump *= vec3(NdotE) + vec3(0.0, 0.0, 1.0 - NdotE);

  mat3 tbn_matrix = mat3(
    tangent.x, binormal.x, water_normal.x,
    tangent.y, binormal.y, water_normal.y,
    tangent.z, binormal.z, water_normal.z
    );

  return normalize(bump * tbn_matrix);
}

float cdist(vec2 coord) {
  return max(abs(coord.s - 0.5), abs(coord.t - 0.5)) * 2.0;
}

vec4 reflection_calc(vec3 fragpos, vec3 normal) {
  vec3 reflected_vector = reflect(normalize(fragpos), normal) * 30.0;
  vec3 pos = camera_to_screen(fragpos + reflected_vector);

  float border =
    clamp((1.0 - (max(0.0, abs(pos.y - 0.5)) * 2.0)) * 50.0, 0.0, 1.0);

  return vec4(texture2D(gaux1, pos.xy, 0.0).rgb, border);
}

vec3 water_shader(vec3 fragpos, vec3 normal, vec3 color, vec3 sky_reflect) {
  vec4 reflection = vec4(0.0);

  #if REFLECTION == 1
    reflection = reflection_calc(fragpos, normal);
  #endif

  float normal_dot_eye = dot(normal, normalize(fragpos));
  float fresnel = clamp(fourth_pow(1.0 + normal_dot_eye) + 0.1, 0.0, 1.0);

  reflection.rgb = mix(
    sky_reflect * lmcoord.y * lmcoord.y,
    reflection.rgb,
    reflection.a
  );

  #if SUN_REFLECTION == 1
     #ifndef NETHER
      #ifndef THE_END
        return mix(color, reflection.rgb, fresnel) +
          sun_reflection(reflect(normalize(fragpos), normal));
      #else
        return mix(color, reflection.rgb, fresnel);
      #endif
    #else
      return mix(color, reflection.rgb, fresnel);
    #endif
  #else
    return mix(color, reflection.rgb, fresnel);
  #endif
}
