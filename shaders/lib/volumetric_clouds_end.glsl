/* MakeUp Ultra Fast - volumetric_clouds_end.glsl
Fast volumetric clouds (for The End) - MakeUp implementation
*/

vec3 get_end_cloud(vec3 view_vector, vec3 block_color, float bright) {
  float plane_distance;
  float cloud_value;
  float umbral = 0.3;
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
  int real_steps;
  float view_y_inv = 1.0 / view_vector.y;
  float distance_aux;

  #if AA_TYPE == 0
    float dither = dither_grad_noise(gl_FragCoord.xy);
  #else
    float dither = shifted_phi_noise(uvec2(gl_FragCoord.xy));
  #endif

  block_color.rgb *=
  	clamp(bright + ((dither - .5) * .1), 0.0, 1.0) * 2.0 + 1.0;

  if (cameraPosition.y < CLOUD_PLANE) {
    if (view_vector.y > 0.055) {  // Vista sobre el horizonte
      vec3 cloud_color = block_color * 2.0;
      vec3 dark_cloud_color = block_color;

      real_steps = int((dither * .5 + .5) * CLOUD_STEPS);

      plane_distance = (CLOUD_PLANE - cameraPosition.y) * view_y_inv;
      intersection_pos = (view_vector * plane_distance) + cameraPosition;

      plane_distance = (CLOUD_PLANE_SUP - cameraPosition.y) * view_y_inv;
      intersection_pos_sup = (view_vector * plane_distance) + cameraPosition;

      dif_sup = CLOUD_PLANE_SUP - CLOUD_PLANE_CENTER;
      dif_inf = CLOUD_PLANE_CENTER - CLOUD_PLANE;

      opacity_dist = (CLOUD_PLANE_SUP - CLOUD_PLANE) * .25 * view_y_inv;

      increment = (intersection_pos_sup - intersection_pos) / real_steps;
      increment_dist = length(increment);

      cloud_value = 0.0;

      for (int i = 0; i < real_steps; i++) {
        current_value =
          texture(
            gaux3,
            (intersection_pos.xz * .0002) + (frameTimeCounter * 0.002777777777777778)
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
          distance_aux = min(
            abs(intersection_pos.y - surface_inf),
            abs(intersection_pos.y - surface_sup)
          );

          if (distance_aux < (CLOUD_PLANE_SUP - CLOUD_PLANE) * 0.25 && i > 0) {
            cloud_value += (1.0 - clamp(
              distance_aux / increment.y,
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
        }

        intersection_pos += increment;
      }

      cloud_value -= increment_dist;

      cloud_value = clamp(cloud_value / opacity_dist, 0.0, 1.0);

      cloud_color = mix(cloud_color, dark_cloud_color, sqrt(density));
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
