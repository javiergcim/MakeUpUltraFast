vec3 light_direction;
#ifdef THE_END
    light_direction = normalize(gbufferModelView * vec4(0.0, 0.89442719, 0.4472136, 0.0)).xyz;
#else
    light_direction = normalize(shadowLightPosition);
#endif

float dot_product = dot(normal, light_direction);
float NdotL;

#ifdef FOLIAGE_V
    float foliage_factor = step(0.2, is_foliage);
    NdotL = mix(dot_product, abs(dot_product), foliage_factor);
#else
    NdotL = dot_product;
#endif

NdotL = clamp(NdotL, 0.0, 1.0);

vec3 shadow_world_normal = normalize(mat3(gbufferModelViewInverse) * normal);

vec3 bias = shadow_world_normal * min(SHADOW_FIX_FACTOR + length(position.xyz) * 0.005, 0.5) * (2.0 - max(NdotL, 0.0));
vec3 shadow_world = position.xyz + bias;

shadow_pos = get_shadow_pos(shadow_world);

// --- OPTIMIZACIÓN: Reemplazar sqrt() y el costoso pow() ---
vec2 shadow_diffuse_aux = shadow_pos.xy * 2.0 - 1.0;
float diffuse = length(shadow_diffuse_aux);

// Reemplazo ultra-rápido de pow(diffuse, 10.0)
float diffuse2 = diffuse * diffuse;
float diffuse4 = diffuse2 * diffuse2;
float diffuse8 = diffuse4 * diffuse4;
shadow_diffuse = diffuse8 * diffuse2;

shadow_diffuse = clamp(shadow_diffuse, 0.0, 1.0);