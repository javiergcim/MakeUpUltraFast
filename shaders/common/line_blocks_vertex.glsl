in vec4 vaColor;
in vec3 vaPosition;
in vec3 vaNormal;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

uniform float viewHeight;
uniform float viewWidth;

#include "/lib/config.glsl"

#ifdef THE_END
  #include "/lib/color_utils_end.glsl"
#elif defined NETHER
  #include "/lib/color_utils_nether.glsl"
#else
  #include "/lib/color_utils.glsl"
#endif

out vec4 tint_color;

#include "/lib/luma.glsl"
#include "/lib/basic_utils.glsl"

#if AA_TYPE > 0
  #include "/src/taa_offset.glsl"
#endif

vec4 my_ftransform()
{
  float lineWidth = 2.5;
  vec2 screenSize = vec2(viewWidth, viewHeight);
  const mat4 VIEW_SCALE = mat4(mat3(1.0 - 0.00390625));
  mat4 tempmat = projectionMatrix * VIEW_SCALE * modelViewMatrix;
  vec4 linePosStart = tempmat * vec4(vaPosition, 1.0);
  vec4 linePosEnd = tempmat * vec4(vaPosition + vaNormal, 1.0);
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
  tint_color = vaColor;
  gl_Position = my_ftransform();
  #if AA_TYPE == 1
    gl_Position.xy += taa_offset * gl_Position.w;
  #endif
}
