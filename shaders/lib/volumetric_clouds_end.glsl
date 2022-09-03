/* MakeUp - volumetric_clouds_end.glsl
Fast volumetric clouds (for The End) - MakeUp implementation
*/

vec3 get_end_cloud(vec3 view_vector, vec3 block_color, float bright, float dither, vec3 base_pos, int samples) {
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

  block_color.rgb *=
    clamp(bright + ((dither - .5) * .1), 0.0, 1.0) * .3 + 1.0;

  if (view_vector.y > 0.0) {  // Vista sobre el horizonte
    umbral = 0.25;

    vec3 cloud_color = block_color * 1.75;
    vec3 dark_cloud_color = block_color * 0.9;

    plane_distance = (CLOUD_PLANE - base_pos.y) * view_y_inv;
    intersection_pos = (view_vector * plane_distance) + base_pos;

    plane_distance = (CLOUD_PLANE_SUP - base_pos.y) * view_y_inv;
    intersection_pos_sup = (view_vector * plane_distance) + base_pos;

    dif_sup = CLOUD_PLANE_SUP - CLOUD_PLANE_CENTER;
    dif_inf = CLOUD_PLANE_CENTER - CLOUD_PLANE;
    dist_aux_coeff = (CLOUD_PLANE_SUP - CLOUD_PLANE) * 0.075;
    dist_aux_coeff_blur = dist_aux_coeff * 0.4;

    opacity_dist = dist_aux_coeff * 2.5 * view_y_inv;

    increment = (intersection_pos_sup - intersection_pos) / samples;
    increment_dist = length(increment);

    cloud_value = 0.0;

    intersection_pos += (increment * dither);

    for (int i = 0; i < samples; i++) {
      #if CLOUD_VOL_STYLE == 0
        current_value =
          texture2D(
            gaux2,
            (intersection_pos.xz * .0008) + (frameTimeCounter * CLOUD_HI_FACTOR * 3.0)
          ).r;
      #else
        current_value =
          texture2D(
            colortex2,
            (intersection_pos.xz * .0008) + (frameTimeCounter * CLOUD_HI_FACTOR * 3.0)
          ).r;
      #endif

      #if V_CLOUDS == 2 && CLOUD_VOL_STYLE == 0
        current_value +=
          texture2D(
            gaux2,
            (intersection_pos.zx * .0008) + (frameTimeCounter * CLOUD_LOW_FACTOR * 3.0)
          ).r;
        current_value *= 0.5;
        current_value = smoothstep(0.05, 0.95, current_value);
      #endif

      // Ajuste por umbral
      current_value = (current_value - umbral) / (1.0 - umbral);

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
      else if (surface_inf < surface_sup && i > 0) {  // Fuera de la nube
        distance_aux = min(
          abs(intersection_pos.y - surface_inf),
          abs(intersection_pos.y - surface_sup)
          );

        if (distance_aux < dist_aux_coeff_blur) {
          cloud_value += min(
            (clamp(dist_aux_coeff_blur - distance_aux, 0.0, dist_aux_coeff_blur) / dist_aux_coeff_blur) * increment_dist,
            surface_sup - surface_inf
            );

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

    cloud_value = clamp(cloud_value / opacity_dist, 0.0, 1.0);
    density = clamp(density, 0.0001, 1.0);

    cloud_color = mix(cloud_color, dark_cloud_color, sqrt(density));

    // Halo brillante de contra al sol
    cloud_color = mix(cloud_color, cloud_color * 2.0, (1.0 - cloud_value) * bright);

    block_color = mix(
      block_color,
      cloud_color,
      cloud_value * clamp((view_vector.y - 0.06) * 5.0, 0.0, 1.0)
    );
    
    block_color =
      mix(block_color, vec3(1.0), clamp(bright * .04, 0.0, 1.0));
  }

  return block_color;
}