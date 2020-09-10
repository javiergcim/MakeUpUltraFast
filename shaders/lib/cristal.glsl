/* MakeUp Ultra Fast - cristal.glsl
Water reflection and refraction related functions. Inspired by Project LUMA.

*/

vec4 cristalRaytrace(vec3 fragpos, vec3 normal) {

  #if SSR_METHOD == 0

    vec3 reflectedVector = reflect(normalize(fragpos), normal) * 30.0;
    vec3 pos = cameraSpaceToScreenSpace(fragpos + reflectedVector);

    float border_x = max(-fourth_pow(abs(2 * pos.x - 1.0)) + 1.0, 0.0);
    float border_y = max(-fourth_pow(abs(2 * pos.y - 1.0)) + 1.0, 0.0);
    float border = min(border_x, border_y);

    return vec4(texture2D(gaux2, pos.xy, 0.0).rgb, border);

  #else

    float dither = ditherGradNoise();

    const int samples       = RT_SAMPLES;
    const int maxRefinement = 10;
    const float stepSize    = 1.2;
    const float stepRefine  = 0.28;
    const float stepIncrease = 1.8;

    vec3 col        = vec3(0.0);
    vec3 rayStart   = fragpos;
    vec3 rayDir     = reflect(normalize(fragpos), normal);
    vec3 rayStep    = (stepSize+dither-0.5)*rayDir;
    vec3 rayPos     = rayStart + rayStep;
    vec3 rayPrevPos = rayStart;
    vec3 rayRefine  = rayStep;

    int refine  = 0;
    vec3 pos    = vec3(0.0);
    float border = 0.0;

    for (int i = 0; i < samples; i++) {

    pos = cameraSpaceToScreenSpace(rayPos);

    if (pos.x < 0.0 ||
        pos.x > 1.0 ||
        pos.y < 0.0 ||
        pos.y > 1.0 ||
        pos.z < 0.0 ||
        pos.z > 1.0) break;

    vec3 screenPos  = vec3(pos.xy, texture2D(depthtex1, pos.xy).x);
     screenPos  = cameraSpaceToWorldSpace(screenPos * 2.0 - 1.0);

    float dist = distance(rayPos, screenPos);

    if (dist < pow(length(rayStep) * pow(length(rayRefine), 0.11), 1.1) * 1.22) {

    refine++;
    if (refine >= maxRefinement)  break;

    rayRefine  -= rayStep;
    rayStep    *= stepRefine;

    }

    rayStep        *= stepIncrease;
    rayPrevPos      = rayPos;
    rayRefine      += rayStep;
    rayPos          = rayStart+rayRefine;

    }

    if (pos.z < 1.0-1e-5) {
      float depth = texture2D(depthtex0, pos.xy).x;

      float comp = 1.0 - near / far / far;
      bool land = depth < comp;

      if (land) {
        col = texture2D(gaux2, pos.xy).rgb;
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

vec4 cristalShader(vec3 fragpos, vec3 normal, vec4 color, vec3 skyReflection) {
  vec4 reflection = vec4(0.0);

  #if REFLECTION == 1
    reflection = cristalRaytrace(fragpos, normal);
  #endif

  reflection.rgb = mix(skyReflection * lmcoord.t * lmcoord.t, reflection.rgb, reflection.a);

  float normalDotEye = dot(normal, normalize(fragpos));
  float fresnel = clamp(fifth_pow(1.0 + normalDotEye) + 0.1, 0.0, 1.0);

  float reflection_index = min(fresnel * (-color.a + 1.0) * 2.0, 1.0);

  color.rgb = mix(color.rgb, skyReflection, reflection_index);
  color.rgb = mix(color.rgb, reflection.rgb, reflection_index);

  color.a = mix(color.a, 1.0, fresnel * .8);

  return color;
}
