#ifdef FOLIAGE_V
  float NdotL;
  if (is_foliage > .2) {
    NdotL = clamp(
      max(
        dot(normal, normalize(shadowLightPosition)),
        dot(-normal, normalize(shadowLightPosition))
      ),
      0.0,
      1.0
      );
  } else {
    NdotL = clamp(
      dot(
        normal,
        normalize(shadowLightPosition)
        ),
      0.0,
      1.0
      );
  }
#else
  float NdotL = clamp(
    dot(
      normal,
      normalize(shadowLightPosition)
      ),
    0.0,
    1.0
    );
#endif

shadow_pos = get_shadow_pos(position, NdotL);
shadow_diffuse = max(
  abs((shadow_pos.x - .5) * 2.0), abs((shadow_pos.y - .5) * 2.0)
  );
shadow_diffuse = pow(shadow_diffuse, 10.0);
