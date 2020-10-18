/* MakeUp Ultra Fast - water.glsl
Water reflection and refraction related functions.
Based on work from RRe36.
https://rre36.github.io/
*/

#if SUN_REFLECTION == 1
  #ifndef NETHER
    #ifndef THE_END

      vec3 sun_reflection(vec3 fragpos) {
        vec3 astro_pos = sunPosition;
        if (worldTime > 12900) {
          astro_pos = moonPosition;
        }
        float astro_vector =
          max(dot(normalize(fragpos), normalize(astro_pos)), 0.0);

        return vec3(
          clamp(
            smoothstep(0.997, 1.0, astro_vector) * clamp(4.0 * lmcoord.y - 3.0, 0.0, 1.0) * (1.0 - wetness),
            0.0,
            1.0
          ));
      }

    #endif
  #endif
#endif

float water_waves(vec3 world_pos) {
  float wave = 0.0;

  world_pos.z += world_pos.y;
  world_pos.x += world_pos.y;

  world_pos.z *= 0.5;
  world_pos.x += sin(world_pos.x) * 0.3;

  // Defined as: mat2 rotate_mat = mat2(cos(.5), -sin(.5), sin(.5), cos(.5));
  const mat2 rotate_mat = mat2(
    0.8775825618903728, -0.479425538604203,
    -0.479425538604203, 0.8775825618903728
    );

  wave = texture2D(
    noisetex,
    world_pos.xz * 0.05625 + vec2(frameTimeCounter * 0.015)
    ).x * 0.02;
  wave += texture2D(
    noisetex,
    world_pos.xz * 0.015 - vec2(frameTimeCounter * 0.0075)
    ).x * 0.1;
  wave += texture2D(
    noisetex,
    world_pos.xz * 0.015 * rotate_mat + vec2(frameTimeCounter * 0.0075)
    ).x * 0.1;

  return wave;
}

vec3 waves_to_normal(vec3 pos) {
  float delta_pos = 0.1;
  float h0 = water_waves(pos.xyz);
  float h1 = water_waves(pos.xyz + vec3(delta_pos, 0.0, 0.0));
  float h2 = water_waves(pos.xyz + vec3(-delta_pos, 0.0, 0.0));
  float h3 = water_waves(pos.xyz + vec3(0.0, 0.0, delta_pos));
  float h4 = water_waves(pos.xyz + vec3(0.0, 0.0, -delta_pos));

  float x_delta = ((h1 - h0) + (h0 - h2)) / delta_pos;
  float y_delta = ((h3 - h0) + (h0 - h4)) / delta_pos;

  return normalize(
    vec3(x_delta, y_delta, 1.0 - x_delta * x_delta - y_delta * y_delta)
    );
}

vec3 to_NDC(vec3 pos){
  vec4 i_proj_diag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
    vec3 p3 = pos * 2. - 1.;
    vec4 fragpos = i_proj_diag * p3.xyzz + gbufferProjectionInverse[3];
    return fragpos.xyz / fragpos.w;
}

vec3 camera_to_screen(vec3 fragpos) {
  vec4 pos  = gbufferProjection * vec4(fragpos, 1.0);
   pos /= pos.w;

  return pos.xyz * 0.5 + 0.5;
}

vec3 camera_to_world(vec3 fragpos) {
  vec4 pos  = gbufferProjectionInverse * vec4(fragpos, 1.0);
  pos /= pos.w;

  return pos.xyz;
}

vec3 refraction(vec3 fragpos, vec3 color, vec3 refraction) {
  vec3 pos = camera_to_screen(fragpos);

  #if REFRACTION == 1

    float  refraction_strength = 0.1;
    refraction_strength /= 1.0 + length(fragpos) * 0.4;
    vec2 medium_texcoord = pos.xy + refraction.xy * refraction_strength;

    return texture2D(colortex4, medium_texcoord.st).rgb * color;

  #else

    return texture2D(colortex4, pos.xy).rgb * color;

  #endif
}

vec3 get_normals(vec3 bump) {
  float NdotE = abs(dot(water_normal, normalize(position2.xyz)));

  bump *= vec3(NdotE) + vec3(0.0, 0.0, 1.0 - NdotE);

  mat3 tbn_matrix = mat3(
    tangent.x, binormal.x, water_normal.x,
    tangent.y, binormal.y, water_normal.y,
    tangent.z, binormal.z, water_normal.z
    );

  return normalize(bump * tbn_matrix);
}

float cdist(vec2 coord) {
  return max(abs(coord.s - 0.5), abs(coord.t - 0.5)) * 2.0;
}

vec4 raytrace(vec3 fragpos, vec3 normal) {
  #if SSR_METHOD == 0

    vec3 reflected_vector = reflect(normalize(fragpos), normal) * 30.0;
    vec3 pos = camera_to_screen(fragpos + reflected_vector);

    float border =
      clamp((1.0 - (max(0.0, abs(pos.y - 0.5)) * 2.0)) * 50.0, 0.0, 1.0);

    return vec4(texture2D(colortex4, pos.xy, 0.0).rgb, border);

  #else
    #if AA_TYPE == 2
      float dither = timed_hash12(gl_FragCoord.xy);
    #else
      float dither = grid_noise(gl_FragCoord.xy);
    #endif

    const int samples = RT_SAMPLES;
    const int max_refine = 10;
    const float step_size = 1.2;
    const float step_refine = 0.28;
    const float step_increment = 1.8;

    vec3 col = vec3(0.0);
    vec3 ray_start = fragpos;
    vec3 ray_dir = reflect(normalize(fragpos), normal);
    vec3 ray_step = (step_size + dither - 0.5) * ray_dir;
    vec3 ray_pos = ray_start + ray_step;
    vec3 ray_pos_past = ray_start;
    vec3 ray_refine  = ray_step;

    int refine = 0;
    vec3 pos = vec3(0.0);
    float border = 0.0;

    for (int i = 0; i < samples; i++) {
      pos = camera_to_screen(ray_pos);

      if (
        pos.x < 0.0 ||
        pos.x > 1.0 ||
        pos.y < 0.0 ||
        pos.y > 1.0 ||
        pos.z < 0.0 ||
        pos.z > 1.0
        ) break;

      vec3 screen_pos = vec3(pos.xy, texture2D(depthtex1, pos.xy).x);
      screen_pos = camera_to_world(screen_pos * 2.0 - 1.0);

      float dist = distance(ray_pos, screen_pos);

      if (
        dist < pow(length(ray_step) * pow(length(ray_refine), 0.11), 1.1) * 1.22
        ) {
        refine++;
        if (refine >= max_refine) break;

        ray_refine -= ray_step;
        ray_step *= step_refine;
      }

      ray_step *= step_increment;
      ray_pos_past = ray_pos;
      ray_refine += ray_step;
      ray_pos = ray_start + ray_refine;
    }

    if (pos.z < 1.0-1e-5) {
      float depth = texture2D(depthtex0, pos.xy).x;

      float comp = 1.0 - near / far / far;
      bool land = depth < comp;

      if (land) {
        col = texture2D(colortex4, pos.xy).rgb;
        border = clamp((1.0 - cdist(pos.st)) * 50.0, 0.0, 1.0);
      }
    }

    // Difumina la orilla del área reflejable para evitar el "corte" del mismo.
    float border_mix = abs((pos.x * 2.0) - 1.0);
    border_mix *= border_mix;
    border = mix(border, 0.0, border_mix);

    return vec4(col, border);

  #endif
}

vec3 water_shader(vec3 fragpos, vec3 normal, vec3 color, vec3 sky_reflect) {
  vec4 reflection = vec4(0.0);

  #if REFLECTION == 1
    reflection = raytrace(fragpos, normal);
  #endif

  float normal_dot_eye = dot(normal, normalize(fragpos));
  float fresnel = clamp(fourth_pow(1.0 + normal_dot_eye) + 0.1, 0.0, 1.0);

  reflection.rgb = mix(
    sky_reflect * lmcoord.y * lmcoord.y,
    reflection.rgb,
    reflection.a
  );

  #if SUN_REFLECTION == 1
     #ifndef NETHER
      #ifndef THE_END
        return mix(color, reflection.rgb, fresnel) +
          sun_reflection(reflect(normalize(fragpos), normal));
      #else
        return mix(color, reflection.rgb, fresnel);
      #endif
    #else
      return mix(color, reflection.rgb, fresnel);
    #endif
  #else
    return mix(color, reflection.rgb, fresnel);
  #endif
}
