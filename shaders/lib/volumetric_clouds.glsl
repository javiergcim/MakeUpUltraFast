/* MakeUp Ultra Fast - volumetric_clouds.glsl
Fast volumetric clouds - MakeUp implementation
*/

vec3 get_cloud(vec3 view_vector, vec3 block_color) {
  float plane_distance;
  float cloud_value;
  float umbral;
  float density;
  vec3 intersection_pos;
  vec3 intersection_pos_sup;
  float dif_inf;
  float dif_sup;
  float current_value;
  float surface_inf;
  float surface_sup;
  bool first_contact = true;
  float opacity_dist;
  vec3 increment;
  float increment_dist;
  float increment_y_inv;
  int real_steps;

  if (cameraPosition.y < CLOUD_PLANE) {
    if (view_vector.y > .055) {  // Vista sobre el horizonte
      umbral = mix(0.6, 0.4, rainStrength);
      vec3 cloud_color = mix(
        luma(
          day_color_mixer(
            AMBIENT_MIDDLE_COLOR,
            AMBIENT_DAY_COLOR,
            AMBIENT_NIGHT_COLOR,
            day_moment
          )
        ) * vec3(1.5),
          day_color_mixer(
            LOW_MIDDLE_COLOR,
            LOW_DAY_COLOR,
            LOW_NIGHT_COLOR,
            day_moment
          ),
        .3
      ) * mix(1.0, 0.6, rainStrength);

      vec3 dark_cloud_color = block_color;

      #if AA_TYPE == 0
        real_steps = int((hash12(gl_FragCoord.xy) * .5 + .5) * CLOUD_STEPS);
      #else
        real_steps = int((timed_hash12(gl_FragCoord.xy) * .5 + .5) * CLOUD_STEPS);
      #endif

      plane_distance = (CLOUD_PLANE - cameraPosition.y) / view_vector.y;
      intersection_pos = (view_vector * plane_distance) + cameraPosition;

      plane_distance = (CLOUD_PLANE_SUP - cameraPosition.y) / view_vector.y;
      intersection_pos_sup = (view_vector * plane_distance) + cameraPosition;

      dif_sup = CLOUD_PLANE_SUP - CLOUD_PLANE_CENTER;
      dif_inf = CLOUD_PLANE_CENTER - CLOUD_PLANE;

      opacity_dist = (CLOUD_PLANE_SUP - CLOUD_PLANE) * .25 / view_vector.y;

      // increment = (intersection_pos_sup - intersection_pos) / CLOUD_STEPS;
      increment = (intersection_pos_sup - intersection_pos) / real_steps;
      increment_dist = length(increment);
      increment_y_inv = 1.0 / increment.y;

      cloud_value = 0.0;

      // for (int i = 0; i < CLOUD_STEPS; i++) {
      for (int i = 0; i < real_steps; i++) {
        current_value =
          texture2D(
            colortex3,
            (intersection_pos.xz * .0002) + (frameTimeCounter * 0.001388888888888889)
          ).r;
        // Ajuste por umbral
        current_value = clamp((current_value - umbral) / (1.0 - umbral), 0.0, 1.0);

        // Superficies inferior y superior de nubes
        surface_inf = CLOUD_PLANE_CENTER - (current_value * dif_inf);
        surface_sup = CLOUD_PLANE_CENTER + (current_value * dif_sup);

        if (  // Dentro de la nube
          intersection_pos.y > surface_inf &&
          intersection_pos.y < surface_sup
          ) {
            cloud_value += increment_dist;

            if (first_contact) {
              first_contact = false;
              density =
                (surface_sup - intersection_pos.y) /
                (CLOUD_PLANE_SUP - CLOUD_PLANE);
            }
        } else {  // Fuera de la nube
          cloud_value += (1.0 - clamp(
            min(
              abs(intersection_pos.y - surface_inf),
              abs(intersection_pos.y - surface_sup)
            ) * increment_y_inv,
            0.0,
            1.0
          )) * increment_dist;

          if (first_contact) {
            first_contact = false;
            density =
              (surface_sup - intersection_pos.y) /
              (CLOUD_PLANE_SUP - CLOUD_PLANE);
          }
        }

        intersection_pos += increment;
      }

      cloud_value -= increment_dist;

      cloud_value = clamp(cloud_value / opacity_dist, 0.0, 1.0);

      cloud_color = mix(cloud_color, dark_cloud_color, sqrt(density));
      block_color = mix(block_color, cloud_color, cloud_value);
    }
  }

  return block_color;
}
