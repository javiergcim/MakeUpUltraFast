layout(location = 0) out vec4 gbufferData0;

void voxy_emitFragment(VoxyFragmentParameters parameters) {
    gbufferData0 = parameters.sampledColour * parameters.tinting;
}