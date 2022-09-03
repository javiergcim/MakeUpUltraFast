vec2 taa_offset(int frame_mod, vec2 pixel_size) {
  // Pentagon
  vec2[10] offset = vec2[10] (
      vec2(0.7071067811865476, 0.0),
      vec2(-0.5720614028176843, 0.4156269377774535),
      vec2(0.2185080122244104, -0.6724985119639574),
      vec2(0.21850801222441057, 0.6724985119639574),
      vec2(-0.5720614028176845, -0.4156269377774534),
      vec2(0.7071067811865476, 0.0),
      vec2(-0.5720614028176843, 0.4156269377774535),
      vec2(0.2185080122244104, -0.6724985119639574),
      vec2(0.21850801222441057, 0.6724985119639574),
      vec2(-0.5720614028176845, -0.4156269377774534)
  );

  // Decagon ['A', 'E', 'I', 'C', 'H', 'D', 'J', 'F', 'B', 'G']
  // vec2[10] offset = vec2[10] (
  //     vec2(0.7071067811865476, 0.0),
  //     vec2(-0.5720614028176843, 0.4156269377774535),
  //     vec2(0.2185080122244104, -0.6724985119639574),
  //     vec2(0.21850801222441057, 0.6724985119639574),
  //     vec2(-0.21850801222441066, -0.6724985119639574),
  //     vec2(-0.2185080122244105, 0.6724985119639574),
  //     vec2(0.5720614028176843, -0.41562693777745363),
  //     vec2(-0.7071067811865476, 0.0),
  //     vec2(0.5720614028176844, 0.41562693777745346),
  //     vec2(-0.5720614028176845, -0.4156269377774534)
  // );

  // Double pentagon ['A', 'E', 'I', 'C', 'H', 'D', 'J', 'F', 'B', 'G']
  // vec2[10] offset = vec2[10] (
  //     vec2(0.7071067811865476, 0.0),
  //     vec2(-0.5720614028176843, 0.4156269377774535),
  //     vec2(0.2185080122244104, -0.6724985119639574),
  //     vec2(0.21850801222441057, 0.6724985119639574),
  //     vec2(-0.10925400611220533, -0.3362492559819787),
  //     vec2(-0.10925400611220525, 0.3362492559819787),
  //     vec2(0.2860307014088421, -0.20781346888872682),
  //     vec2(-0.3535533905932738, 0.0),
  //     vec2(0.2860307014088422, 0.20781346888872673),
  //     vec2(-0.5720614028176845, -0.4156269377774534)
  // );

  // Halton 10 (optimized maximal path) ['A', 'B', 'I', 'H', 'C', 'J', 'E', 'F', 'G', 'D']
  // vec2[10] offset = vec2[10] (
  //     vec2(0.0, -0.23570226),
  //     vec2(-0.35355339, 0.23570226),
  //     vec2(0.08838835, -0.6547285),
  //     vec2(-0.61871843, 0.54997194),
  //     vec2(0.35355339, -0.54997194),
  //     vec2(-0.26516504, -0.18332398),
  //     vec2(0.1767767, 0.3928371),
  //     vec2(-0.1767767, -0.3928371),
  //     vec2(0.53033009, 0.07856742),
  //     vec2(-0.53033009, -0.07856742)
  // );

  // Vogel 10 Optimized maximal path ['A', 'E', 'I', 'J', 'F', 'B', 'C', 'D', 'H', 'G']
  // vec2[10] offset = vec2[10] (
  //   vec2(0.223606797749979, 0),
  //   vec2(-0.6605658874578119, -0.11684480445049084),
  //   vec2(0.8660114451142193, 0.3162659907912668),
  //   vec2(-0.9009406039213251, 0.37189518443491276),
  //   vec2(0.6257456740866655, -0.3980481771869136),
  //   vec2(-0.2855817384808979, 0.2616162660199629),
  //   vec2(0.04371286235847994, -0.4980855204324139),
  //   vec2(0.35995728446892067, 0.46950053605694686),
  //   vec2(-0.3991571921844798, -0.7685528842749875),
  //   vec2(-0.2092996818683685, 0.7785843841034829)
  // );

  return offset[frame_mod] * pixel_size;
}