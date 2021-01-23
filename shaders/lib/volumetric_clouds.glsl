/* MakeUp Ultra Fast - volumetric_clouds.glsl
Fast volumetric clouds - MakeUp implementation
*/

vec3 get_cloud(vec3 view_vector, vec3 block_color) {
  #if V_CLOUDS == 1
    vec3 cloud_color;
    float plane_distance;
    float cloud_value;
    float umbral = 0.6;
    float density;
    float current_alpha = 0.0;
    vec2 intersection_pos;
  #elif V_CLOUDS == 2
    float plane_distance;
    float cloud_value;
    float umbral = 0.6;
    float density;
    vec3 intersection_pos;
    vec3 intersection_pos_sup;
    vec3 increment;
    float dif_inf;
    float dif_sup;
    float current_value;
    float surface_inf;
    float surface_sup;
    bool first_contact = true;
    float opacity_dist;
    float increment_dist;
    float increment_y_inv;
  #endif

  if (cameraPosition.y < CLOUD_PLANE) {
    if (view_vector.y > .05) {  // Vista sobre el horizonte
      vec3 cloud_color = luma(
        day_color_mixer(
          AMBIENT_MIDDLE_COLOR,
          AMBIENT_DAY_COLOR,
          AMBIENT_NIGHT_COLOR,
          day_moment
          )
        ) * vec3(1.0);

      vec3 dark_cloud_color = block_color * .75;

      #if V_CLOUDS == 1
        plane_distance = (CLOUD_PLANE - cameraPosition.y) / view_vector.y;
        intersection_pos = (view_vector * plane_distance).xz;
        intersection_pos *= .0002;

        cloud_value = texture2D(colortex3, intersection_pos).r;

        // Ajuste por umbral
        cloud_value = clamp((cloud_value - umbral) / (1.0 - umbral), 0.0, 1.0);
        density = cloud_value;
        current_alpha = sqrt(density);

      #elif V_CLOUDS == 2
        plane_distance = (CLOUD_PLANE - cameraPosition.y) / view_vector.y;
        intersection_pos = (view_vector * plane_distance) + cameraPosition;

        plane_distance = (CLOUD_PLANE_SUP - cameraPosition.y) / view_vector.y;
        intersection_pos_sup = (view_vector * plane_distance) + cameraPosition;

        dif_sup = CLOUD_PLANE_SUP - CLOUD_PLANE_CENTER;
        dif_inf = CLOUD_PLANE_CENTER - CLOUD_PLANE;

        opacity_dist = (CLOUD_PLANE_SUP - CLOUD_PLANE) * .25 / view_vector.y;

        increment = (intersection_pos_sup - intersection_pos) / CLOUD_STEPS;
        increment_dist = length(increment);
        increment_y_inv = 1.0 / increment.y;

        cloud_value = 0.0;

        for (int i = 0; i < CLOUD_STEPS; i++) {
          current_value = texture2D(colortex3, intersection_pos.xz * .0001).r;
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
        // cloud_value = clamp((cloud_value - increment_dist) / (1.0 - increment_dist), 0.0, 1.0);

        cloud_value = clamp(cloud_value / opacity_dist, 0.0, 1.0);
        // cloud_value = 0.0;

        // cloud_value /= CLOUD_STEPS;
        // cloud_value = clamp(cloud_value - .1, 0.0, 1.0);
      #endif

      cloud_color = mix(cloud_color, dark_cloud_color, density);
      block_color = mix(block_color, cloud_color, cloud_value);
    }
  }

  return block_color;
}
