/* MakeUp - depth_hd.glsl
Depth utilities (dh).

Javier Garduño - GNU Lesser General Public License v3.0
*/

float ld_dh(float depth) {
    return (2.0 * dhNearPlane) / (dhFarPlane + dhNearPlane - depth * (dhFarPlane - dhNearPlane));
}
