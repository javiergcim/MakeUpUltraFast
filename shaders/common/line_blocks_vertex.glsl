#include "/lib/config.glsl"

// Pseudo-uniforms uniforms
uniform int frameCounter;
uniform float viewWidth;
uniform float viewHeight;

#include "/iris_uniforms/pixel_size_x.glsl"
#include "/iris_uniforms/pixel_size_y.glsl"
#include "/iris_uniforms/frame_mod.glsl"
#include "/iris_uniforms/taa_offset.glsl"

varying vec4 tint_color;

#if AA_TYPE > 1
  #include "/src/taa_offset.glsl"
#endif

vec4 mu_ftransform()
{
  float lineWidth = 1.75;
  vec2 screenSize = vec2(viewWidth, viewHeight);
  mat4 VIEW_SCALE = mat4(mat3(1.0 - 0.00390625));
  mat4 tempmat = gl_ProjectionMatrix * VIEW_SCALE * gl_ModelViewMatrix;
  vec4 linePosStart = tempmat * gl_Vertex;
  vec4 linePosEnd = tempmat * vec4(gl_Vertex.xyz + gl_Normal, 1.0);
  vec3 ndc1 = linePosStart.xyz / linePosStart.w;
  vec3 ndc2 = linePosEnd.xyz / linePosEnd.w;
  vec2 lineScreenDirection = normalize((ndc2.xy - ndc1.xy) * screenSize);
  vec2 lineOffset = vec2(-lineScreenDirection.y, lineScreenDirection.x) * lineWidth / screenSize;
  if (lineOffset.x < 0.0)
    lineOffset *= -1.0;
  if (gl_VertexID % 2 == 0)
    return vec4((ndc1 + vec3(lineOffset, 0.0)) * linePosStart.w, linePosStart.w);
  else
    return vec4((ndc1 - vec3(lineOffset, 0.0)) * linePosStart.w, linePosStart.w);
}

void main() {
  // Pseudo-uniforms section
  #if AA_TYPE > 0
    int frame_mod = frame_mod();
    vec2 pixel_size = vec2(pixel_size_x(), pixel_size_y());
    vec2 taa_offset = taa_offset(frame_mod, pixel_size);
  #endif
  
  tint_color = gl_Color;
  gl_Position = mu_ftransform();
  #if AA_TYPE > 1
    gl_Position.xy += taa_offset * gl_Position.w;
  #endif
}
