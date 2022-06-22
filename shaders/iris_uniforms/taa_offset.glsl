vec2 taa_offset(int frame_mod, vec2 pixel_size) {
    switch (frame_mod) {
    case 0:
        return vec2(0.7071067811865476, 0.0) * pixel_size;
        break;
    case 1:
        return vec2(-0.5720614028176843, 0.4156269377774535) * pixel_size;
        break;
    case 2:
        return vec2(0.2185080122244104, -0.6724985119639574) * pixel_size;
        break;
    case 3:
        return vec2(0.21850801222441057, 0.6724985119639574) * pixel_size;
        break;
    case 4:
        return vec2(-0.5720614028176845, -0.4156269377774534) * pixel_size;
        break;
    case 5:
        return vec2(0.7071067811865476, 0.0) * pixel_size;
        break;
    case 6:
        return vec2(-0.5720614028176843, 0.4156269377774535) * pixel_size;
        break;
    case 7:
        return vec2(0.2185080122244104, -0.6724985119639574) * pixel_size;
        break;
    case 8:
        return vec2(0.21850801222441057, 0.6724985119639574) * pixel_size;
        break;
    case 9:
        return vec2(-0.5720614028176845, -0.4156269377774534) * pixel_size;
  }
}