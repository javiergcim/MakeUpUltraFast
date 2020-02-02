/* MakeUp Ultra Fast - color_utils.glsl
Luma related functions.

Javier Garduño - GNU Lesser General Public License v3.0
*/

float luma(vec3 color) {
  /* Calcula la luma del color dado.

  Args:
  color (vec3). El color a calcular el luma.

  Returns:
  float: La luma del color dado.

  */
  return dot(color, vec3(0.299, 0.587, 0.114));
}
