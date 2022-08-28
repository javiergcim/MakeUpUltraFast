/* MakeUp - basic_utils.glsl
Depth utilities.

Javier Garduño - GNU Lesser General Public License v3.0
*/

float ld(float depth) {
  // return near / ((1.0 - depth) * far);  // Fast and inaccurate linear depth
  return (2.0 * near) / (far + near - depth * (far - near));
}

// float linearizeDepthfDivisor(float d, float near) { // Returns 1 / linearizeDepthf
//     return (1 - d) / near;
// }
// float linearizeDepthfInverse(float ld, float near) { // Inverts linearizeDepthf
//     return 1 - near / ld;
// }
