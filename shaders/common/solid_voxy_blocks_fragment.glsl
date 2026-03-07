layout(location = 0) out vec4 gbufferData0;
layout(location = 1) out vec4 gbufferData1;

void voxy_emitFragment(VoxyFragmentParameters parameters) {
    gbufferData0 = vec4(1.0, 0.0, 0.0, 1.0);
    gbufferData1 = vec4(1.0, 0.0, 0.0, 1.0);
}