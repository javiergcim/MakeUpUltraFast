/* MakeUp Ultra Fast - water.glsl
Water reflection and refractiion related functions. Inspired by Project LUMA.
*/

float waterWaves(vec3 worldPos) {
  float wave = 0.0;

  worldPos.z += worldPos.y;
  worldPos.x += worldPos.y;

  worldPos.z *= 0.5;
  worldPos.x += sin(worldPos.x) * 0.3;

  // Defined as: mat2 rotate_mat = mat2(cos(.5), -sin(.5), sin(.5), cos(.5));
  const mat2 rotate_mat = mat2(0.8775825618903728, -0.479425538604203,
                         -0.479425538604203, 0.8775825618903728);

  wave = texture2D(noisetex, worldPos.xz * 0.05625 + vec2(frameTimeCounter * 0.015)).x * 0.02;
  wave += texture2D(noisetex, worldPos.xz * 0.015 - vec2(frameTimeCounter * 0.0075)).x * 0.1;
  wave += texture2D(noisetex, worldPos.xz * 0.015 * rotate_mat + vec2(frameTimeCounter * 0.0075)).x * 0.1;

  return wave;
}

vec3 waterwavesToNormal(vec3 pos) {
  float deltaPos = 0.1;
  float h0 = waterWaves(pos.xyz);
  float h1 = waterWaves(pos.xyz + vec3(deltaPos, 0.0, 0.0));
  float h2 = waterWaves(pos.xyz + vec3(-deltaPos, 0.0, 0.0));
  float h3 = waterWaves(pos.xyz + vec3(0.0, 0.0, deltaPos));
  float h4 = waterWaves(pos.xyz + vec3(0.0, 0.0, -deltaPos));

  float xDelta = ((h1 - h0) + (h0 - h2)) / deltaPos;
  float yDelta = ((h3 - h0) + (h0 - h4)) / deltaPos;

  return normalize(vec3(xDelta, yDelta, 1.0 - xDelta * xDelta - yDelta * yDelta));
}

vec3 toNDC(vec3 pos){
  vec4 iProjDiag = vec4(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y, gbufferProjectionInverse[2].zw);
    vec3 p3 = pos * 2. - 1.;
    vec4 fragpos = iProjDiag * p3.xyzz + gbufferProjectionInverse[3];
    return fragpos.xyz / fragpos.w;
}

vec3 cameraSpaceToScreenSpace(vec3 fragpos) {
  vec4 pos  = gbufferProjection * vec4(fragpos, 1.0);
   pos /= pos.w;

  return pos.xyz * 0.5 + 0.5;
}

vec3 cameraSpaceToWorldSpace(vec3 fragpos) {
  vec4 pos  = gbufferProjectionInverse * vec4(fragpos, 1.0);
  pos /= pos.w;

  return pos.xyz;
}

vec3 refraction(vec3 fragpos, vec3 color, vec3 waterRefract) {
  vec3 pos = cameraSpaceToScreenSpace(fragpos);

  #if REFRACTION == 1

    float  waterRefractionStrength = 0.1;
    waterRefractionStrength /= 1.0 + length(fragpos) * 0.4;
    vec2 waterTexcoord = pos.xy + waterRefract.xy * waterRefractionStrength;

    return texture2D(gaux2, waterTexcoord.st).rgb * color;

  #else

    return texture2D(gaux2, pos.xy).rgb * color;

  #endif
}

vec3 getNormals(vec3 bump) {
  float NdotE = abs(dot(normal, normalize(position2.xyz)));

  bump *= vec3(NdotE) + vec3(0.0, 0.0, 1.0 - NdotE);

  mat3 tbnMatrix = mat3(tangent.x, binormal.x, normal.x,
              tangent.y, binormal.y, normal.y,
              tangent.z, binormal.z, normal.z);

  return normalize(bump * tbnMatrix);
}

float cdist(vec2 coord) {
  return max(abs(coord.s - 0.5), abs(coord.t - 0.5)) * 2.0;
}

vec4 raytrace(vec3 fragpos, vec3 normal) {

  #if SSR_METHOD == 0

    vec3 reflectedVector = reflect(normalize(fragpos), normal) * 30.0;
    vec3 pos = cameraSpaceToScreenSpace(fragpos + reflectedVector);

    float border = clamp((1.0 - (max(0.0, abs(pos.y - 0.5)) * 2.0)) * 50.0, 0.0, 1.0);

    return vec4(texture2D(gaux2, pos.xy, 0.0).rgb, border);

  #else

    float dither = ditherGradNoise();
    // float dither = hash12();
    // float dither = dither17();
    // float dither = bayer4(gl_FragCoord.xy);

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

vec3 waterShader(vec3 fragpos, vec3 normal, vec3 color, vec3 skyReflection) {
  vec4 reflection = vec4(0.0);

  #if REFLECTION == 1
    reflection = raytrace(fragpos, normal);
  #endif

  float normalDotEye = dot(normal, normalize(fragpos));
  float fresnel = clamp(pow(1.0 + normalDotEye, 4.0) + 0.1, 0.0, 1.0);

   reflection.rgb = mix(skyReflection * lmcoord.t * lmcoord.t, reflection.rgb, reflection.a);

  return mix(color, reflection.rgb, fresnel);
}
