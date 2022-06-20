float taa_offset(int frame_mod) {
  switch (frame_mod) {
    case 0:
        return 0.0;
    case 1:
        return 0.23357464195808708;
    case 2:
        return 0.5928235978395564;
    case 3:
        return 0.9007804890147557;
    case 4:
        return 0.2247837296466677;
    case 5:
        return 0.4376966419839634;
    case 6:
        return 0.811372918225491;
    case 7:
        return 0.041018671427652365;
    case 8:
        return 0.45487913258395407;
    case 9:
        return 0.7699489101682118;
  }
}