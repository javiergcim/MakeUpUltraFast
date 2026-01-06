vec3 dayBlend(vec3 sunset, vec3 day, vec3 night) {
    // f(x) = min(-((x-.25)^2)∙20 + 1.25, 1)
    // g(x) = min(-((x-.75)^2)∙50 + 3.125, 1)

    vec3 dayColor = mix(sunset, day, dayMixer);
    vec3 nightColor = mix(sunset, night, nightMixer);

    return mix(dayColor, nightColor, step(0.5, dayMoment));
}

float dayBlendFloat(float sunset, float day, float night) {
    // f(x) = min(-((x-.25)^2)∙20 + 1.25, 1)
    // g(x) = min(-((x-.75)^2)∙50 + 3.125, 1)

    float dayValue = mix(sunset, day, dayMixer);
    float nightValue = mix(sunset, night, nightMixer);

    return mix(dayValue, nightValue, step(0.5, dayMoment));
}