/* MakeUp - water.glsl
Water reflection and refraction related functions.
*/

vec3 fastRaymarch(vec3 direction, vec3 hitPoint, inout float infinite, float dither) {
    vec3 pathIncrement;
    vec3 currentMarchPoint = hitPoint;
    vec3 oldMarchPoint;
    float screenDepth;
    float depthDifference = 1.0;
    vec3 screenMarchPos = camera_to_screen(hitPoint);
    float prevScreenDepth = screenMarchPos.z;
    float hitPointDepth = screenMarchPos.z;
    bool searchFlag = false;
    bool hiddenFlag = false;
    bool firstHidden = true;
    bool outOfEyeFlag = false;
    bool toFar = false;
    vec3 lastScreenMarchPos;
    
    int no_hidden_steps = 0;
    bool hiddens = false;

    // Ray marching
    for (int i = 0; i < RAYMARCH_STEPS; i++) {
        if (searchFlag) {
            pathIncrement *= 0.5;
            currentMarchPoint += pathIncrement * sign(depthDifference);
        } else {
            oldMarchPoint = currentMarchPoint;
            currentMarchPoint = hitPoint + ((direction * exp2(i + dither)) - direction);
            pathIncrement = currentMarchPoint - oldMarchPoint;
        }

        lastScreenMarchPos = screenMarchPos;
        screenMarchPos = camera_to_screen(currentMarchPoint);

        if ( // Is outside screen space
            screenMarchPos.x < 0.0 ||
            screenMarchPos.x > 1.0 ||
            screenMarchPos.y < 0.0 ||
            screenMarchPos.y > 1.0 ||
            screenMarchPos.z < 0.0
        ) {
            outOfEyeFlag = true;
        }

        if (screenMarchPos.z > 0.9999) {
            toFar = true;
        }

        screenDepth = texture2D(depthtex1, screenMarchPos.xy).x;
        depthDifference = screenDepth - screenMarchPos.z;

        if (depthDifference < 0.0 && abs(screenDepth - prevScreenDepth) > abs(screenMarchPos.z - lastScreenMarchPos.z)) {
            hiddenFlag = true;
            hiddens = true;
            if (firstHidden) {
                firstHidden = false;
            }
        } else if (depthDifference > 0.0) {
            hiddenFlag = false;
            if (!hiddens) {
                no_hidden_steps++;
            }
        }

        if (searchFlag == false && depthDifference < 0.0 && hiddenFlag == false) {
            searchFlag = true;
        }

        prevScreenDepth = screenDepth;
    }

    infinite = float(screenDepth > 0.9999);

    if (outOfEyeFlag) {
        infinite = 1.0;
        return screenMarchPos;
    } else if (toFar) {
        if (screenDepth > 0.9999) {
            infinite = 1.0;
            return screenMarchPos;
        } else if (no_hidden_steps < 3 || screenDepth > hitPointDepth) {
            return screenMarchPos;
        } else {
            infinite = 1.0;
            return vec3(1.0);
        }
    } else {
        return screenMarchPos;
    }
}

#if SUN_REFLECTION == 1
    #if !defined NETHER && !defined THE_END
        float sun_reflection(vec3 fragpos) {
            vec3 astroLightPos = worldTime > 12900 ? moonPosition : sunPosition;
            float astroAlignment =
                max(dot(normalize(fragpos), normalize(astroLightPos)), 0.0);

            return smoothstep(0.995, 1.0, astroAlignment) *
                clamp(lmcoord.y, 0.0, 1.0) *
                (1.0 - rainStrength) * 3.0;
        }
    #endif
#endif

vec3 normal_waves(vec3 pos) {
    float speed = frameTimeCounter * .025;
    vec2 wave_1 =
        texture2D(noisetex, ((pos.xy - pos.z * 0.2) * 0.05) + vec2(speed, speed)).rg;
    wave_1 = wave_1 - .5;
    vec2 wave_2 =
        texture2D(noisetex, ((pos.xy - pos.z * 0.2) * 0.03125) - speed).rg;
    wave_2 = wave_2 - .5;
    vec2 wave_3 =
        texture2D(noisetex, ((pos.xy - pos.z * 0.2) * 0.125) + vec2(speed, -speed)).rg;
    wave_3 = wave_3 - .5;
    wave_3 *= 0.66;

    vec2 partialWave = wave_1 + wave_2 + wave_3;
    vec3 finalWave = vec3(partialWave, WATER_TURBULENCE - (rainStrength * 0.6 * WATER_TURBULENCE * visible_sky));

    return normalize(finalWave);
}

vec3 refraction(vec3 fragpos, vec3 color, vec3 refraction) {
    vec2 pos = gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y);

    #if REFRACTION == 1
        pos = pos + refraction.xy * (0.075 / (1.0 + length(fragpos) * 0.4));
    #endif

    float water_absortion;
    if (isEyeInWater == 0) {
        float water_distance =
        2.0 * near * far / (far + near - (2.0 * gl_FragCoord.z - 1.0) * (far - near));

        float earth_distance = texture2D(depthtex1, pos.xy).r;
        earth_distance =
            2.0 * near * far / (far + near - (2.0 * earth_distance - 1.0) * (far - near));

        #if defined DISTANT_HORIZONS
            float earth_distance_dh = texture2D(dhDepthTex1, pos.xy).r;
            earth_distance_dh =
                2.0 * dhNearPlane * dhFarPlane / (dhFarPlane + dhNearPlane - (2.0 * earth_distance_dh - 1.0) * (dhFarPlane - dhNearPlane));
            earth_distance = min(earth_distance, earth_distance_dh);
        #endif

        water_absortion = earth_distance - water_distance;
        water_absortion *= water_absortion;
        water_absortion = (1.0 / -((water_absortion * WATER_ABSORPTION) + 1.125)) + 1.0;
    } else {
        water_absortion = 0.0;
    }

    return mix(texture2D(gaux1, pos.xy).rgb, color, water_absortion);
}

vec3 get_normals(vec3 bump, vec3 fragpos) {
    float NdotE = abs(dot(waterNormal, normalize(fragpos)));

    bump *= vec3(NdotE) + vec3(0.0, 0.0, 1.0 - NdotE);

    mat3 tbn_matrix = mat3(
        tangent.x, binormal.x, waterNormal.x,
        tangent.y, binormal.y, waterNormal.y,
        tangent.z, binormal.z, waterNormal.z
    );

    return normalize(bump * tbn_matrix);
}

vec4 reflection_calc(vec3 fragpos, vec3 normal, vec3 reflected, inout float infinite, float dither) {
    #if SSR_TYPE == 0  // Flipped image
        #if defined DISTANT_HORIZONS
            vec3 pos = camera_to_screen(fragpos + reflected * 768.0);
        #else
            vec3 pos = camera_to_screen(fragpos + reflected * 76.0);
        #endif
    #else  // Raymarch
        vec3 pos = fastRaymarch(reflected, fragpos, infinite, dither);
    #endif

    float border =
        clamp((1.0 - (max(0.0, abs(pos.y - 0.5)) * 2.0)) * 50.0, 0.0, 1.0);

    border = clamp(border - pow(pos.y, 10.0), 0.0, 1.0);

    pos.x = abs(pos.x);
    if (pos.x > 1.0) {
        pos.x = 1.0 - (pos.x - 1.0);
    }

    return vec4(texture2D(gaux1, pos.xy).rgb, border);
}

vec3 water_shader(
    vec3 fragpos,
    vec3 normal,
    vec3 color,
    vec3 sky_reflect,
    vec3 reflected,
    float fresnel,
    float visible_sky,
    float dither,
    vec3 lightColor
) {
    vec4 reflection = vec4(0.0);
    float infinite = 1.0;

    #if REFLECTION == 1
        reflection =
            reflection_calc(fragpos, normal, reflected, infinite, dither);
    #endif

    reflection.rgb = mix(
        sky_reflect * visible_sky,
        reflection.rgb,
        reflection.a
    );

    #ifdef VANILLA_WATER
        fresnel *= 0.8;
    #endif

    #if SUN_REFLECTION == 1
        #ifndef NETHER
            #ifndef THE_END
                return mix(color, reflection.rgb, fresnel * REFLEX_INDEX) +
                    vec3(sun_reflection(reflect(normalize(fragpos), normal))) * lightColor * infinite * visible_sky;          
            #else
                return mix(color, reflection.rgb, fresnel * REFLEX_INDEX);
            #endif
        #else
            return mix(color, reflection.rgb, fresnel * REFLEX_INDEX);
        #endif
    #else
        return mix(color, reflection.rgb, fresnel * REFLEX_INDEX);
    #endif
}

//  GLASS

vec4 cristal_reflection_calc(vec3 fragpos, vec3 normal, inout float infinite, float dither) {
    #if SSR_TYPE == 0
        #if defined DISTANT_HORIZONS
            vec3 reflectedVector = reflect(normalize(fragpos), normal) * 768.0;
        #else
            vec3 reflectedVector = reflect(normalize(fragpos), normal) * 76.0;
        #endif
            vec3 pos = camera_to_screen(fragpos + reflectedVector);
    #else
        vec3 reflectedVector = reflect(normalize(fragpos), normal);
        vec3 pos = fastRaymarch(reflectedVector, fragpos, infinite, dither);

        if (pos.x > 99.0) { // Fallback
            #if defined DISTANT_HORIZONS
                pos = camera_to_screen(fragpos + reflectedVector * 768.0);
            #else
                pos = camera_to_screen(fragpos + reflectedVector * 76.0);
            #endif
        }
    #endif

    float border_x = max(-fourth_pow(abs(2.0 * pos.x - 1.0)) + 1.0, 0.0);
    float border_y = max(-fourth_pow(abs(2.0 * pos.y - 1.0)) + 1.0, 0.0);
    float border = min(border_x, border_y);

    return vec4(texture2D(gaux1, pos.xy, 0.0).rgb, border);
}

vec4 cristal_shader(
    vec3 fragpos,
    vec3 normal,
    vec4 color,
    vec3 skyReflectionColor,
    float fresnel,
    float visible_sky,
    float dither,
    vec3 lightColor
) {
    vec4 reflection = vec4(0.0);
    float infinite = 0.0;

    #if REFLECTION == 1
        reflection = cristal_reflection_calc(fragpos, normal, infinite, dither);
    #endif

    skyReflectionColor = mix(color.rgb, skyReflectionColor, visible_sky * visible_sky);

    reflection.rgb = mix(
        skyReflectionColor,
        reflection.rgb,
        reflection.a
    );

    color.rgb = mix(color.rgb, skyReflectionColor, fresnel);
    color.rgb = mix(color.rgb, reflection.rgb, fresnel);

    color.a = mix(color.a, 1.0, fresnel * .9);

    #if SUN_REFLECTION == 1
        #ifndef NETHER
        #ifndef THE_END
            return color + vec4(
                mix(
                    vec3(sun_reflection(reflect(normalize(fragpos), normal)) * lightColor * infinite * visible_sky),
                    vec3(0.0),
                    reflection.a
                ),
                0.0
            );
        #else
            return color;
        #endif
        #else
            return color;
        #endif
    #else
        return color;
    #endif
}
