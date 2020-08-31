vec4 cristalShader(vec3 fragpos, vec3 normal, vec4 color, vec3 skyReflection) {
  vec4 reflection = vec4(0.0);

  #if REFLECTION == 1 && NICE_WATER
    reflection = cristalRaytrace(fragpos, normal);
  #endif

  reflection.rgb = mix(skyReflection * pow(lmcoord.t, 2.0), reflection.rgb, reflection.a);

  float normalDotEye = dot(normal, normalize(fragpos));
  float fresnel = clamp(pow(1.0 + normalDotEye, 4.0) + 0.1, 0.0, 1.0);

  float reflection_index = min(fresnel * (-color.a + 1.0) * 2.0, 1.0);

  color.rgb = mix(color.rgb, skyReflection, reflection_index);
  color.rgb = mix(color.rgb, reflection.rgb, reflection_index);

  color.a = mix(color.a, 1.0, fresnel * .8);

  return color;
}
