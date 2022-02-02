/* MakeUp - volumetric_clouds.glsl
Volumetric light - MakeUp implementation
*/

#if VOL_LIGHT == 2

  #define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)

  vec3 get_volumetric_pos(vec3 the_pos) {
    vec3 shadow_pos = mat3(shadowModelView) * the_pos + shadowModelView[3].xyz;
    shadow_pos = diagonal3(shadowProjection) * shadow_pos + shadowProjection[3].xyz;

    float distortion = ((1.0 - SHADOW_DIST) + length(shadow_pos.xy * 1.25) * SHADOW_DIST) * 0.85;
    shadow_pos.xy /= distortion;
    shadow_pos.xyz = shadow_pos.xyz * 0.5 + 0.5;

    return shadow_pos;
  }

  float get_volumetric_light(float dither, float view_distance, mat4 modeli_times_projectioni) {
    float light = 0.0;

    float current_depth;
    vec3 view_pos;
    vec4 pos;
    vec3 shadow_pos;

    for (int i = 0; i < GODRAY_STEPS; i++) {
      // Exponentialy spaced shadow samples
      current_depth = exp2(i + dither) - 0.96;  // 0.96 avoids points behind near plane2
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

      light += texture(shadowtex1, shadow_pos);
    }

    light /= GODRAY_STEPS;

    return light;
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

        shadow_detector = texture(shadowtex0, vec3(shadow_pos.xy, shadow_pos.z - 0.001));
        if (shadow_detector < 1.0) {
          shadow_black = texture(shadowtex1, vec3(shadow_pos.xy, shadow_pos.z - 0.001));
          if (shadow_black != shadow_detector) {
            shadow_color = texture(shadowcolor0, shadow_pos.xy);
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

  // float ss_godrays(float dither) {
  //   float light = 0.0;
  //   float comp = 1.0 - near / far / far;

  //   vec2 deltatexcoord = vec2(lightpos - texcoord) * 0.2;
  //   vec2 dither2d = texcoord;

  //   float depth;

  //   for (int i = 0; i < CHEAP_GODRAY_SAMPLES; i++) {
  //     depth = texture(depthtex1, dither2d).x;
  //     dither2d += deltatexcoord * dither;
  //     light += clamp(dot(step(comp, depth), 1.0), 0.0, 1.0);
  //   }

  //   return light / CHEAP_GODRAY_SAMPLES;
  // }

// #endif







vec3 projectOrthographicMAD(in vec3 position, in mat4 projectionMatrix) {
    return vec3(projectionMatrix[0].x, projectionMatrix[1].y, projectionMatrix[2].z) * position + projectionMatrix[3].xyz;
}

vec4 projectHomogeneousMAD(in vec3 position, in mat4 projectionMatrix) {
    return vec4(projectOrthographicMAD(position, projectionMatrix), -position.z);
}

float sqmag(vec2 v) {
    return dot(v, v);
}

float dr_godrays(vec3 lightPosition, float dither) {
  vec2 coord = gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y);
  vec2 screenSize = vec2(viewWidth, viewHeight);
  float fovScale = gbufferProjection[1][1] * 0.7299270073;
  // Start transforming sunPosition from view space to screen space
  vec4 tmp = projectHomogeneousMAD(lightPosition, gbufferProjection);
  float light = 1.0;

  if (tmp.w > 0) { // If w is negative, the sun is on the opposite side of the screen (this causes bugs, I don't want that)
    // Finish screen space transformation
    vec2 sunScreen    = (tmp.xy / tmp.w) * .5 + .5;

    // Create ray pointing from the current pixel to the sun
    vec2 ray          = sunScreen - coord;
    vec2 rayCorrected = vec2(ray.x * aspectRatio, ray.y); // Aspect Ratio corrected ray for accurate exponential decay

    vec2 rayStep      = ray / CHEAP_GODRAY_SAMPLES;
    // #ifndef TAA
    // vec2 rayPos       = coord - (grid_noise(coord * screenSize) * rayStep);
    vec2 rayPos       = coord - (dither * rayStep);
    // #else
    // vec2 taa_offs     = fract(vec2(frameCounter * 0.2, -frameCounter * 0.2 - 0.5)) * 5 - 10;
    // vec2 rayPos       = coord - (grid_noise(coord * screenSize + taa_offs) * rayStep);
    // #endif

    for (int i = 0; i < CHEAP_GODRAY_SAMPLES; i++) {
      rayPos += rayStep;
      if (texture(depthtex1, rayPos).x != 1.0) { // Subtract from light when there is an occlusion
        light -= 1.0 / GODRAY_STEPS;
      }
    }

    // Exponential falloff (also making it FOV independent)
    light *= exp2(-sqmag(rayCorrected / (fovScale * 0.40)));

  //     // #if FOG != 0
  //     //     color += saturate(light * (0.35 * 4) * customFogColor); // Additive Effect
  //     // #else
  //     //     color += saturate(light * 0.35 * fogColor); // Additive Effect
  //     // #endif

  }

  return light;
}

#endif
