/* MakeUp - water.glsl
Water reflection and refraction related functions.
*/

vec3 fast_raymarch(vec3 direction, vec3 hit_coord) {
  vec3 hit_pos = camera_to_screen(hit_coord);
  float hit_depth = texture(depthtex0, hit_pos.xy).x;

  vec3 dir_increment = direction * RAY_STEP;
  vec3 current_march = hit_coord + dir_increment;
  float screen_depth;
  float depth_diff;
  vec3 march_pos;

  // Ray marching
  for (int i = 0; i < RAYMARCH_STEPS; i++) {
    march_pos = camera_to_screen(current_march);

    if ( // Is outside sreen space (except x cordinate)
      march_pos.y < 0.0 ||
      march_pos.y > 1.0 ||
      march_pos.z < 0.0 ||
      march_pos.z > 1.0
      ) {
        march_pos = vec3(0.0);
        break;
      }

    screen_depth = texture(depthtex1, march_pos.xy).x;
    depth_diff = screen_depth - march_pos.z;

    if (depth_diff < 0.0) {
      float prev_screen_depth = screen_depth;
      float prev_march_pos_z = march_pos.z;
      // Binary search for best screen space sample
      for (int j = 0; j < RAYSEARCH_STEPS; j++) {
        dir_increment = dir_increment * .5;
        current_march += (dir_increment * sign(depth_diff));

        march_pos = camera_to_screen(current_march);
        screen_depth = texture(depthtex1, march_pos.xy).x;
        depth_diff = screen_depth - march_pos.z;

        // Remove unnecesary iterations
        if (abs(depth_diff) < 0.0001) {
          break;
        }

        // Searching fallbacks
        if (abs(screen_depth - prev_screen_depth) > abs(march_pos.z - prev_march_pos_z) * 2.5) {
          return camera_to_screen(hit_coord + (direction * 64.0));
        }
        prev_screen_depth = screen_depth;
        prev_march_pos_z = march_pos.z;
      }

      return march_pos;
    }

    dir_increment *= 2.0;
    current_march += dir_increment;
  }

  return camera_to_screen(current_march + (dir_increment * 100.0));
}

#if SUN_REFLECTION == 1
  #ifndef NETHER
    #ifndef THE_END

      float sun_reflection(vec3 fragpos) {
        vec3 astro_pos = worldTime > 12900 ? moonPosition : sunPosition;
        float astro_vector =
          max(dot(normalize(fragpos), normalize(astro_pos)), 0.0);

        return clamp(
            smoothstep(
              0.997, 1.0, astro_vector) *
              clamp(4.0 * lmcoord.y - 3.0, 0.0, 1.0) *
              (1.0 - rainStrength),
            0.0,
            1.0
          );
      }

    #endif
  #endif
#endif

vec3 normal_waves(vec3 pos) {
  float timer = frameTimeCounter;

  vec3 wave_1 =
     texture(noisetex, (pos.xy * 0.0625) + (timer * .025)).rgb;
     wave_1 = wave_1 * vec3(0.6, 0.6, 1.0) - vec3(0.3, 0.3, 0.5);
  vec3 wave_2 =
     texture(noisetex, (pos.yx * 0.03125) - (timer * .025)).rgb;
  wave_2 = wave_2 * vec3(0.6, 0.6, 1.0) - vec3(0.3, 0.3, 0.5);

  vec3 final_wave = wave_1 + wave_2;

  return normalize(final_wave);
}

vec3 refraction(vec3 fragpos, vec3 color, vec3 refraction) {
  vec3 pos = camera_to_screen(fragpos);

  #if REFRACTION == 1

    float  refraction_strength = 0.1;
    refraction_strength /= 1.0 + length(fragpos) * 0.4;
    vec2 medium_texcoord = pos.xy + refraction.xy * refraction_strength;

    return texture(gaux1, medium_texcoord.st).rgb * color;

  #else

    return texture(gaux1, pos.xy).rgb * color;

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

vec4 reflection_calc(vec3 fragpos, vec3 normal, vec3 reflected) {
  #if SSR_TYPE == 0  // Flipped image
    // vec3 reflected_vector = reflect(normalize(fragpos), normal) * 35.0;
    vec3 reflected_vector = reflected * 35.0;
    vec3 pos = camera_to_screen(fragpos + reflected_vector);
  #else  // Raymarch
    vec3 reflected_vector = reflect(normalize(fragpos), normal);
    vec3 pos = fast_raymarch(reflected_vector, fragpos);
  #endif

  float border =
    clamp((1.0 - (max(0.0, abs(pos.y - 0.5)) * 2.0)) * 50.0, 0.0, 1.0);

  pos.x = abs(pos.x);
  if (pos.x > 1.0) {
    pos.x = 1.0 - (pos.x - 1.0);
  }

  return vec4(texture(gaux1, pos.xy).rgb, border);
}

vec3 water_shader(vec3 fragpos, vec3 normal, vec3 color, vec3 sky_reflect, vec3 reflected) {
  vec4 reflection = vec4(0.0);

  #if REFLECTION == 1
    reflection = reflection_calc(fragpos, normal, reflected);
  #endif

  float normal_dot_eye = dot(normal, normalize(fragpos));
  float fresnel = clamp(fourth_pow(1.0 + normal_dot_eye), 0.0, 1.0);

  reflection.rgb = mix(
    sky_reflect * pow(visible_sky, 10.0),
    reflection.rgb,
    reflection.a
  );

  #if SUN_REFLECTION == 1
     #ifndef NETHER
      #ifndef THE_END
        return mix(color, reflection.rgb, fresnel) +
          vec3(sun_reflection(reflect(normalize(fragpos), normal)));
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

//  GLASS

vec4 cristal_reflection_calc(vec3 fragpos, vec3 normal) {
  #if SSR_TYPE == 0
    vec3 reflected_vector = reflect(normalize(fragpos), normal) * 35.0;
    vec3 pos = camera_to_screen(fragpos + reflected_vector);
  #else
    vec3 reflected_vector = reflect(normalize(fragpos), normal);
    vec3 pos = fast_raymarch(reflected_vector, fragpos);

    if (pos.x > 99.0) { // Fallback
      pos = camera_to_screen(fragpos + (reflected_vector * 35.0));
    }
  #endif

  float border_x = max(-fourth_pow(abs(2 * pos.x - 1.0)) + 1.0, 0.0);
  float border_y = max(-fourth_pow(abs(2 * pos.y - 1.0)) + 1.0, 0.0);
  float border = min(border_x, border_y);

  return vec4(texture(gaux1, pos.xy, 0.0).rgb, border);
}

vec4 cristal_shader(vec3 fragpos, vec3 normal, vec4 color, vec3 sky_reflection) {
vec4 reflection = vec4(0.0);

#if REFLECTION == 1
  reflection = cristal_reflection_calc(fragpos, normal);
#endif

reflection.rgb = mix(sky_reflection * lmcoord.y * lmcoord.y, reflection.rgb, reflection.a);

float normal_dot_eye = dot(normal, normalize(fragpos));
float fresnel = clamp(fifth_pow(1.0 + normal_dot_eye), 0.0, 1.0);

float reflection_index = min(fresnel * (-color.a + 1.0) * 2.0, 1.0);

color.rgb = mix(color.rgb, sky_reflection, reflection_index);
color.rgb = mix(color.rgb, reflection.rgb, reflection_index);

color.a = mix(color.a, 1.0, fresnel * .9);

#if SUN_REFLECTION == 1
   #ifndef NETHER
    #ifndef THE_END
      return color +
        vec4(
          mix(
            vec3(sun_reflection(reflect(normalize(fragpos), normal)) * 0.75),
            vec3(0.0),
            reflection.a
          ),
          0.0
        );
    #else
      return color;
    #endif
  #else
    return color;
  #endif
#else
  return color;
#endif
}
