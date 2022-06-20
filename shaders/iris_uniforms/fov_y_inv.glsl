float fov_y_inv() {
  return 1.0 / atan(1.0 / gbufferProjection[1].y) * 0.5;
}