layout(location = 0) out vec4 gbufferData0;

void voxy_emitFragment(VoxyFragmentParameters parameters) {
    gbufferData0 = vec4(1.0, 0.0, 0.0, 1.0);
}