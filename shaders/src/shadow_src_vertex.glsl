#ifdef FOLIAGE_V
  float NdotL;
  if (is_foliage > .2) {
    #ifdef THE_END
      vec3 custom_light_pos = normalize(gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
      NdotL = clamp(
        abs(dot(normal, custom_light_pos)),
        0.0,
        1.0
        );
    #else
      vec3 normal_light_pos = normalize(shadowLightPosition);
      NdotL = clamp(
        abs(dot(normal, normal_light_pos)),
        0.0,
        1.0
        );
    #endif
  } else {
    #ifdef THE_END
      NdotL = clamp(
        dot(
          normal,
          normalize(gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz
          ),
        0.0,
        1.0
        );
    #else
      NdotL = clamp(
        dot(
          normal,
          normalize(shadowLightPosition)
          ),
        0.0,
        1.0
        );
    #endif
  }
#else
  #ifdef THE_END
    float NdotL = clamp(
      dot(
        normal,
        normalize(gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz
        ),
      0.0,
      1.0
      );
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
#endif

vec3 shadow_world_normal = normalize(mat3(gbufferModelViewInverse) * (normal * 1024.0) + gbufferModelViewInverse[3].xyz);
vec3 bias = shadow_world_normal * min(SHADOW_FIX_FACTOR + length(position.xyz) * 0.005, 0.5) * (2.0 - max(NdotL, 0.0));
vec3 shadow_world = position.xyz + bias;

shadow_pos = get_shadow_pos(shadow_world);

vec2 shadow_diffuse_aux = (shadow_pos.xy - 0.5) * 2.0;
shadow_diffuse = sqrt(shadow_diffuse_aux.x * shadow_diffuse_aux.x + shadow_diffuse_aux.y * shadow_diffuse_aux.y);
shadow_diffuse = clamp(pow(shadow_diffuse, 10.0), 0.0, 1.0);
