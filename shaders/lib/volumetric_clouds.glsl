/* MakeUp Ultra Fast - volumetric_clouds.glsl
Fast volumetric clouds - MakeUp implementation
*/

vec3 get_cloud(vec3 view_vector, vec3 block_color) {
  vec3 cloud_color;
  float plane_distance;
  float cloud_value;
  float umbral = 0.6;
  float density;

  #if V_CLOUDS == 1
    vec2 intersection_pos;
  #elif V_CLOUDS == 2
    vec3 intersection_pos;
    vec3 intersection_pos_sup;
    vec3 increment;
    float dif_inf;
    float dif_sup;
    float current_value;
    float plane_inf;
    float plane_sup;
    bool first_contact = true;
    float current_alpha = 0.0;
    float opacity_dist;
    float increment_dist;
  #endif

  if (cameraPosition.y < CLOUD_PLANE) {
    if (view_vector.y > .0001) {  // Vista sobre el horizonte
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

      #elif V_CLOUDS == 2
        plane_distance = (CLOUD_PLANE - cameraPosition.y) / view_vector.y;
        intersection_pos = (view_vector * plane_distance) + cameraPosition;

        plane_distance = (CLOUD_PLANE_SUP - cameraPosition.y) / view_vector.y;
        intersection_pos_sup = (view_vector * plane_distance) + cameraPosition;

        dif_sup = CLOUD_PLANE_SUP - CLOUD_PLANE_CENTER;
        dif_inf = CLOUD_PLANE_CENTER - CLOUD_PLANE;

        opacity_dist = (CLOUD_PLANE_SUP - CLOUD_PLANE);
        // current_alpha = 0.0;

        increment = (intersection_pos_sup - intersection_pos) / CLOUD_STEPS;
        increment_dist = length(increment);

        cloud_value = 0.0;
        for (int i = 0; i < CLOUD_STEPS; i++) {
          current_value = texture2D(colortex3, intersection_pos.xz * .0002).r;
          // Ajuste por umbral
          current_value = clamp((current_value - umbral) / (1.0 - umbral), 0.0, 1.0);

          // Planos inferior y superior de nube
          plane_inf = CLOUD_PLANE_CENTER - (current_value * dif_inf);
          plane_sup = CLOUD_PLANE_CENTER + (current_value * dif_sup);

          if (intersection_pos.y > plane_inf && intersection_pos.y < plane_sup) {
            cloud_value += 1.0;
            // cloud_value += current_value;
            current_alpha += increment_dist;
            if (first_contact) {
              first_contact = false;
              density = (plane_sup - intersection_pos.y) / (CLOUD_PLANE_SUP - CLOUD_PLANE);
            }
          }

          intersection_pos += increment;
        }

        current_alpha = clamp(current_alpha / opacity_dist, 0.0, 1.0);

        cloud_value /= CLOUD_STEPS;
      #endif

      block_color = mix(block_color, vec3(1.0), current_alpha);
      block_color = mix(block_color, dark_cloud_color, density);
    }
  }

  return block_color;
}
