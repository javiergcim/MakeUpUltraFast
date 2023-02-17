/* MakeUp - fast_taa.glsl
Temporal antialiasing functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 fast_taa(vec3 current_color, vec2 texcoord_past) {
  // Verificamos si proyección queda fuera de la pantalla actual
  if (clamp(texcoord_past, 0.0, 1.0) != texcoord_past) {
    return current_color;
  } else {
    // Previous color
    vec3 previous = texture2D(colortex3, texcoord_past).rgb;

    // Apply clamping on the history color.
    vec3 near_color0 = texture2D(colortex1, texcoord + vec2(-pixel_size_x, 0.0)).rgb;
    vec3 near_color1 = texture2D(colortex1, texcoord + vec2(pixel_size_x, 0.0)).rgb;
    vec3 near_color2 = texture2D(colortex1, texcoord + vec2(0.0, -pixel_size_y)).rgb;
    vec3 near_color3 = texture2D(colortex1, texcoord + vec2(0.0, pixel_size_y)).rgb;
    
    vec3 nmin = min(current_color, min(near_color0, min(near_color1, min(near_color2, near_color3))));
    vec3 nmax = max(current_color, max(near_color0, max(near_color1, max(near_color2, near_color3))));
    
    // Edge detection
    vec3 edge_color = -near_color0;
    edge_color -= near_color1;
    edge_color += current_color * 4.0;
    edge_color -= near_color2;
    edge_color -= near_color3;

    float edge = clamp(length(edge_color) * 0.5773502691896258, 0.0, 1.0);  // 1/sqrt(3)

    // nmax = current_color + (edge * 0.7 + 0.3) * (nmax - current_color);
    // nmin = current_color + (edge * 0.7 + 0.3) * (nmin - current_color);

    // Clip
    // previous = clamp(previous, nmin, nmax);

    vec3 center = (nmin + nmax) * 0.5;
    float radio = length(nmax - center);

    vec3 color_vector = previous - center;
    float color_dist = length(color_vector);

    float factor = 1.0;
    if (color_dist > radio) {
      factor = radio / color_dist;
    }

    previous = center + (color_vector * factor);


    return mix(current_color, previous, 0.8 + (edge * 0.19));
  }
}

vec4 fast_taa_depth(vec4 current_color, vec2 texcoord_past) {
  // Verificamos si proyección queda fuera de la pantalla actual
  if (clamp(texcoord_past, 0.0, 1.0) != texcoord_past) {
    return current_color;
  } else {
    // Muestra del pasado
    vec4 previous = texture2D(colortex3, texcoord_past);

    vec4 near_color0 = texture2D(colortex1, texcoord + vec2(-pixel_size_x, 0.0));
    vec4 near_color1 = texture2D(colortex1, texcoord + vec2(pixel_size_x, 0.0));
    vec4 near_color2 = texture2D(colortex1, texcoord + vec2(0.0, -pixel_size_y));
    vec4 near_color3 = texture2D(colortex1, texcoord + vec2(0.0, pixel_size_y));

    vec4 nmin = min(current_color, min(near_color0, min(near_color1, min(near_color2, near_color3))));
    vec4 nmax = max(current_color, max(near_color0, max(near_color1, max(near_color2, near_color3))));    

    // Clip
    vec3 center = (nmin.rgb + nmax.rgb) * 0.5;
    float radio = length(nmax.rgb - center);

    vec3 color_vector = previous.rgb - center;
    float color_dist = length(color_vector);

    float factor = 1.0;
    if (color_dist > radio) {
      factor = radio / color_dist;
    }

    previous = vec4(center + (color_vector * factor), previous.a);

    // Edge detection
    vec3 edge_color = -near_color0.rgb;
    edge_color -= near_color1.rgb;
    edge_color += current_color.rgb * 4.0;
    edge_color -= near_color2.rgb;
    edge_color -= near_color3.rgb;

    float edge = clamp(length(edge_color) * 0.5773502691896258, 0.0, 1.0);  // 1/sqrt(3)

    return mix(current_color, previous, 0.8 + (edge * 0.19));
  }
}
