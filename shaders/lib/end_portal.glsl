/*
This code is adapted from:

   ____    __   ______________
  / ______/ /  /  _/_  __/ __/
 / _//___/ /___/ /  / / / _/
/___/   /____/___/ /_/ /___/

E-LITE shaders 5 - end_portal.glsl #include "/lib/end_portal.glsl"
End portal render. - Renderização do portal do End. */

float noise2DGrid(vec2 p) {
    vec2 i = floor(p); 
    return hash12(i);
}

vec3 reconstructWorldPosition(float depth, vec2 resolution) {
    vec2 ndcXY = (gl_FragCoord.xy / resolution) * 2.0 - 1.0;
    vec4 fragViewSpace = gbufferProjectionInverse * vec4(ndcXY, depth, 1.0);
    fragViewSpace.xyz /= fragViewSpace.w; 
    return (gbufferModelViewInverse * fragViewSpace).xyz - gbufferModelViewInverse[3].xyz;
}

vec3 endPortal() {
    const int maxLayers = 10;
    const float depthFalloffSpeed = 4.0;
    const float layerScaleFactor = 20.0;
    const vec2 flowDirection = vec2(0.618034);
    const float flowSpeed = 0.2;
    const float noiseBaseScale = 5;
    const float colorMixSpeed = 0.67;
    const float clipMin = 0.75;
    const float clipMax = 1.0;
    const vec3 baseColor = vec3(0.0, 0.0, 0.0);

    const vec3 C0 = vec3(0.498, 0.2353, 0.498);
    const vec3 C1 = vec3(0.1765, 0.2863, 0.7255);
    const vec3 C2 = vec3(0.1608, 0.3961, 0.4941);

    vec2 resolution = vec2(viewWidth, viewHeight);
    float time = mod(frameTimeCounter, 1000.0);

    vec3 worldPosCurrent = reconstructWorldPosition(gl_FragCoord.z, resolution);

    vec3 finalColor = baseColor;
    float tMix = time * colorMixSpeed;
    vec3 currentLayerColor = mix(C0, C1, sin(tMix) * 0.5 + 0.5);
    currentLayerColor = mix(currentLayerColor, C2, cos(tMix * 0.7) * 0.5 + 0.5);

    vec2 flowOffset = flowDirection * (mod(frameTimeCounter, 1000.0) * flowSpeed);
    vec2 baseUV = worldPosCurrent.xz + cameraPosition.xz + worldPosCurrent.y + flowOffset + (cameraPosition.y * 1.96);

    for (int i = 0; i < maxLayers; i++) {
        float layerFactor = float(i) / float(maxLayers);
        float inverseFactor = 1.0 - layerFactor;
        
        vec2 uvLayer = baseUV * (noiseBaseScale * (1.0 + layerFactor * layerScaleFactor));
        uvLayer -= (cameraPosition.xz * layerFactor * 50.0);
        uvLayer += (flowOffset * (inverseFactor * 10.0));

        float noiseVal = noise2DGrid(uvLayer);
        float baseIntensity = fifthPow(noiseVal);
        float intensity = smoothstep(clipMin, clipMax, baseIntensity);

        float layerFade = fourthPow(inverseFactor);
        finalColor += currentLayerColor * intensity * layerFade * 3.0;

        if (layerFade < 0.01) break;
    }
    return finalColor;
}