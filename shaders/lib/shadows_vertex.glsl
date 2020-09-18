#define diag3(mat) vec3((mat)[0].x, (mat)[1].y, (mat)[2].z)

vec3 get_shadow_pos(in vec3 shadow_pos, in vec3 normal){
  shadow_pos = mat3(shadowModelView) * shadow_pos + shadowModelView[3].xyz;
  shadow_pos = diag3(shadowProjection) * shadow_pos + shadowProjection[3].xyz;

  float distortion = ((1.0 - SHADOW_BIAS) + length(shadow_pos.xy * 1.25) * SHADOW_BIAS) * 0.85;
  shadow_pos.xy /= distortion;

  NdotL = clamp(
    dot(
      normal,
      normalize(shadowLightPosition)
      ) * 1.02 - 0.02,
    0.0,
    1.0
    );
  float bias = distortion * distortion * (0.0046 * tan(acos(NdotL)));

  // Mejora de sombra sobre elementos pequeños (como plantas)
  if (mc_Entity.x == ENTITY_SMALLGRASS
  || mc_Entity.x == ENTITY_LOWERGRASS
  || mc_Entity.x == ENTITY_UPPERGRASS
  || mc_Entity.x == ENTITY_SMALLENTS
  || mc_Entity.x == ENTITY_LEAVES
  || mc_Entity.x == ENTITY_VINES
  || mc_Entity.x == ENTITY_LILYPAD
  || mc_Entity.x == ENTITY_FIRE
  || mc_Entity.x == 10030.0  //cobweb
  || mc_Entity.x == 10115.0 //nether wart
  || mc_Entity.x == 10032.0  //dead bush
  || mc_Entity.x == 10006.0) {
    NdotL = 0.75;
    bias = 0.0010;
  }
  shadow_pos.xyz = shadow_pos.xyz * 0.5 + 0.5;
  shadow_pos.z -= bias;

  return shadow_pos.xyz;
}
