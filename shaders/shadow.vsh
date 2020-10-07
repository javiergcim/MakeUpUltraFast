#version 120

uniform vec3 cameraPosition;
uniform mat4 shadowProjection;
uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;

varying vec2 coord;
varying vec4 tint_color;

#include "/lib/shadow_utils.glsl"

void main() {
  //   vec4 position   = gl_Vertex;
  //       position    = gl_ModelViewMatrix*position;
	//
	// position = gl_ProjectionMatrix * position;

  vec4 position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;

  warpShadowmap(position.xy);
  position.z *= 0.2;

  gl_Position = position;

  coord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
  tint_color = gl_Color;
}
