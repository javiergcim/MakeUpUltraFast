float NdotL = clamp(
  dot(
    normal,
    normalize(shadowLightPosition)
    ),
  0.0,
  1.0
  );
shadow_pos = get_shadow_pos(position, normal, NdotL);
