/* MakeUp - volumetric_clouds.glsl
Fast volumetric clouds - MakeUp implementation
*/

vec3 get_cloud(vec3 view_vector, vec3 block_color, float bright) {
  float plane_distance;
  float cloud_value;
  float umbral;
  float density;
  vec3 intersection_pos;
  vec3 intersection_pos_sup;
  float dif_inf;
  float dif_sup;
  float dist_aux_coeff;
  float current_value;
  float surface_inf;
  float surface_sup;
  bool first_contact = true;
  float opacity_dist;
  vec3 increment;
  float increment_dist;
  int real_steps;
  float view_y_inv = 1.0 / view_vector.y;
  float distance_aux;
  vec3 cloud_color_aux;
  float cloud_value_aux;
  float dist_aux_coeff_blur;

  #if AA_TYPE == 0
    float dither = phi_noise(uvec2(gl_FragCoord.xy));
  #else
    float dither = shifted_phi_noise(uvec2(gl_FragCoord.xy));
  #endif

  block_color.rgb *=
    clamp(bright + ((dither - .5) * .1), 0.0, 1.0) * .3 + 1.0;

  if (cameraPosition.y < CLOUD_PLANE) {
    if (view_vector.y > .055) {  // Vista sobre el horizonte
      umbral = (smoothstep(1.0, 0.0, rainStrength) * .3) + .25;
      // umbral = mix(0.6, 0.3, rainStrength);

      cloud_color_aux = day_color_mixer(
        AMBIENT_MIDDLE_COLOR,
        AMBIENT_DAY_COLOR,
        AMBIENT_NIGHT_COLOR,
        day_moment
      );

      vec3 cloud_color = mix(
        luma(cloud_color_aux) * vec3(2.0),
          day_color_mixer(
            LOW_MIDDLE_COLOR,
            LOW_DAY_COLOR,
            LOW_NIGHT_COLOR,
            day_moment
          ),
        0.3
      ) * mix(1.0, 0.6, rainStrength);

      vec3 dark_color_aux = day_color_mixer(
        HI_MIDDLE_COLOR,
        HI_DAY_COLOR,
        HI_NIGHT_COLOR,
        day_moment
      );

      vec3 dark_luma = vec3(luma(dark_color_aux));
      vec3 dark_cloud_color = mix(dark_luma, dark_color_aux, 0.9);

      // real_steps = int((dither * .5 + .5) * CLOUD_STEPS);
      real_steps = int((dither - .5) * CLOUD_STEPS_RANGE + CLOUD_STEPS_AVG);

      plane_distance = (CLOUD_PLANE - cameraPosition.y) * view_y_inv;
      intersection_pos = (view_vector * plane_distance) + cameraPosition;

      plane_distance = (CLOUD_PLANE_SUP - cameraPosition.y) * view_y_inv;
      intersection_pos_sup = (view_vector * plane_distance) + cameraPosition;

      dif_sup = CLOUD_PLANE_SUP - CLOUD_PLANE_CENTER;
      dif_inf = CLOUD_PLANE_CENTER - CLOUD_PLANE;
      dist_aux_coeff = (CLOUD_PLANE_SUP - CLOUD_PLANE) * 0.075;
      dist_aux_coeff_blur = dist_aux_coeff * 0.4;

      opacity_dist = dist_aux_coeff * 2.5 * view_y_inv;

      increment = (intersection_pos_sup - intersection_pos) / real_steps;
      increment_dist = length(increment);

      cloud_value = 0.0;

      for (int i = 0; i < real_steps; i++) {
        current_value =
          texture(
            colortex6,
            (intersection_pos.xz * .0002) + (frameTimeCounter * 0.002777777777777778)
          ).r;
        current_value +=
          texture(
            colortex6,
            (intersection_pos.xz * .0002) + (frameTimeCounter * 0.0002777777777777778)
          ).r;
        current_value *= 0.5;

        // Ajuste por umbral
        current_value = (current_value - umbral) / (1.0 - umbral);
        // current_value = (current_value - umbral);

        // Superficies inferior y superior de nubes
        surface_inf = CLOUD_PLANE_CENTER - (current_value * dif_inf);
        surface_sup = CLOUD_PLANE_CENTER + (current_value * dif_sup);

        if (  // Dentro de la nube
          intersection_pos.y > surface_inf &&
          intersection_pos.y < surface_sup
          ) {
            cloud_value += min(increment_dist, surface_sup - surface_inf);

            if (first_contact) {
              first_contact = false;
              density =
                (surface_sup - intersection_pos.y) /
                (CLOUD_PLANE_SUP - CLOUD_PLANE);
            }
        }
        else if (surface_inf < (surface_sup) && i > 0) {  // Fuera de la nube

          if (surface_inf < surface_sup) {
            distance_aux = min(
              abs(intersection_pos.y - surface_inf),
              abs(intersection_pos.y - surface_sup)
              );
          } else {
            distance_aux = abs(intersection_pos.y - surface_inf);
          }

          if (distance_aux < dist_aux_coeff_blur) {
            cloud_value += min(
              (clamp(dist_aux_coeff_blur - distance_aux, 0.0, dist_aux_coeff_blur) / dist_aux_coeff_blur) * increment_dist,
              surface_sup - surface_inf
              );

            if (first_contact) {
              first_contact = false;
              density =
              ((surface_sup - intersection_pos.y) /
              (CLOUD_PLANE_SUP - CLOUD_PLANE));
            }
          }
        }

        intersection_pos += increment;
      }

      // cloud_value -= (dist_aux_coeff * view_y_inv * 0.5);
      cloud_value = clamp(cloud_value / opacity_dist, 0.0, 1.0);

      density = clamp(density, .0001, 1.0);

      dark_cloud_color = mix(dark_cloud_color, cloud_color_aux, clamp((1.0 - bright) * .4, 0.0, 1.0));

      cloud_color = mix(cloud_color, dark_cloud_color, sqrt(density));
      cloud_color = mix(cloud_color, cloud_color_aux, clamp(bright * .2, 0.0, 1.0));

      block_color =
        mix(
          block_color,
          cloud_color,
          cloud_value * clamp((view_vector.y - 0.055) * 10.0, 0.0, 1.0)
        );
    }
  }

  return block_color;
}
