/* MakeUp - volumetric_clouds.glsl
Volumetric light - MakeUp implementation
*/

#if VOL_LIGHT == 2

  #define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)

  vec3 get_volumetric_pos(vec3 shadow_pos) {
    shadow_pos = mat3(shadowModelView) * shadow_pos + shadowModelView[3].xyz;
    shadow_pos = diagonal3(shadowProjection) * shadow_pos + shadowProjection[3].xyz;
    float distb = length(shadow_pos.xy);
    float distortion = distb * SHADOW_DIST + (1.0 - SHADOW_DIST);

    shadow_pos.xy /= distortion;
    shadow_pos.z *= 0.2;
    
    return shadow_pos * 0.5 + 0.5;
  }

  float get_volumetric_light(float dither, float view_distance, mat4 modeli_times_projectioni) {
    float light = 0.0;

    float current_depth;
    vec3 view_pos;
    vec4 pos;
    vec3 shadow_pos;

    for (int i = 0; i < GODRAY_STEPS; i++) {
      // Exponentialy spaced shadow samples
      current_depth = exp2(i + dither) - 0.6;
      if (current_depth > view_distance) {
        break;
      }

      // Distance to depth
      current_depth = (far * (current_depth - near)) / (current_depth * (far - near));

      view_pos = vec3(texcoord, current_depth);

      // Clip to world
      pos = modeli_times_projectioni * (vec4(view_pos, 1.0) * 2.0 - 1.0);
      view_pos = (pos.xyz /= pos.w).xyz;

      shadow_pos = get_volumetric_pos(view_pos);

      light += shadow2D(shadowtex1, shadow_pos).r;
    }

    light /= GODRAY_STEPS;

    return light * light;
  }

  #if defined COLORED_SHADOW

    vec3 get_volumetric_color_light(float dither, float view_distance, mat4 modeli_times_projectioni) {
      float light = 0.0;

      float current_depth;
      vec3 view_pos;
      vec4 pos;
      vec3 shadow_pos;

      float shadow_detector = 1.0;
      float shadow_black = 1.0;
      vec4 shadow_color = vec4(1.0);
      vec3 light_color = vec3(0.0);

      float alpha_complement;

      for (int i = 0; i < GODRAY_STEPS; i++) {
        // Exponentialy spaced shadow samples
        current_depth = exp2(i + dither) - 0.96;  // 0.96 avoids points behind near plane
        if (current_depth > view_distance) {
          break;
        }

        // Distance to depth
        current_depth = (far * (current_depth - near)) / (current_depth * (far - near));

        view_pos = vec3(texcoord, current_depth);

        // Clip to world
        pos = modeli_times_projectioni * (vec4(view_pos, 1.0) * 2.0 - 1.0);
        view_pos = (pos.xyz /= pos.w).xyz;

        shadow_pos = get_volumetric_pos(view_pos);

        shadow_detector = shadow2D(shadowtex0, vec3(shadow_pos.xy, shadow_pos.z - 0.001)).r;
        if (shadow_detector < 1.0) {
          shadow_black = shadow2D(shadowtex1, vec3(shadow_pos.xy, shadow_pos.z - 0.001)).r;
          if (shadow_black != shadow_detector) {
            shadow_color = texture2D(shadowcolor0, shadow_pos.xy);
            alpha_complement = 1.0 - shadow_color.a;
            shadow_color.rgb *= alpha_complement;
            shadow_color.rgb = mix(shadow_color.rgb, vec3(1.0), alpha_complement);
          }
        }
        
        shadow_color *= shadow_black;
        light_color += clamp(shadow_color.rgb * (1.0 - shadow_detector) + shadow_detector, vec3(0.0), vec3(1.0));
      }

      light_color /= GODRAY_STEPS;

      return light_color;
    }
    
  #endif

#elif VOL_LIGHT == 1

  float ss_godrays(float dither) {
    float light = 0.0;
    float comp = 1.0 - (near / (far * far));

    vec2 ray_step = vec2(lightpos - texcoord) * 0.2;
    vec2 dither2d = texcoord + (ray_step * dither);

    float depth;

    for (int i = 0; i < CHEAP_GODRAY_SAMPLES; i++) {
      depth = texture2D(depthtex1, dither2d).x;
      dither2d += ray_step;
      light += step(comp, depth);
    }

    return light / CHEAP_GODRAY_SAMPLES;
  }

#endif
