/* MakeUp Ultra Fast - blur.glsl
Blur auxiliar.

Javier Garduño - GNU Lesser General Public License v3.0
*/

float fogify(float x, float width) {
  return width / (x * x + width);
}
