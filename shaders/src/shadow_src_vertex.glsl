float NdotL = clamp(
  dot(
    normal,
    normalize(shadowLightPosition)
    ),
  0.0,
  1.0
  );
shadow_pos = get_shadow_pos(position, normal, NdotL);
shadow_diffuse = max(
  abs((shadow_pos.x - .5) * 2.0), abs((shadow_pos.y - .5) * 2.0)
  );
shadow_diffuse = pow(shadow_diffuse, 10.0);
