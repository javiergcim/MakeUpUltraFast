int frame_mod() {
    // int a = int(mod(frameCounter, 10));
    return int(mod(float(frameCounter), 10.0));
}