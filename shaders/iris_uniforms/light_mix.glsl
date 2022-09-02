float light_mix() {
    float light_mix;

    if ((worldTime >= 0 && worldTime < 12485) || worldTime >= 23515) {
        light_mix = 1.0;
    } else if (worldTime >= 12485 && worldTime < 13085) {
        light_mix = 1.0 - ((worldTime - 12485) * 0.0016666666666666668);
    } else if (worldTime >= 13085 && worldTime < 22915) {
        light_mix = 0.0;
    } else {
        light_mix = (worldTime - 22915) * 0.0016666666666666668;
    }

    return light_mix;
}