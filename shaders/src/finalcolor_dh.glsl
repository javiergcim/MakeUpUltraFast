float fog_factor = (view_dist - far) / (dhFarPlane - far);
vec3 fog_texture = texture2D(gaux4, gl_FragCoord.xy * vec2(pixel_size_x, pixel_size_y)).rgb;
block_color.rgb = mix(block_color.rgb, fog_texture, fog_factor);