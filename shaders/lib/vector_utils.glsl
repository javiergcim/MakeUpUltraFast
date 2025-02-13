/* MakeUp - basic_utils.glsl
Moving vector utils.

Javier Garduño - GNU Lesser General Public License v3.0
*/

vec3 wave_move(vec3 pos) {
    float timer = (frameTimeCounter) * 3.141592653589793;
    pos = mod(pos, 157.07963267948966);  // PI * 25
    vec2 wave_x = vec2(timer * 0.5, timer) + pos.xy;
    vec2 wave_z = vec2(timer, timer * 1.5) + pos.xy;
    vec2 wave_y = vec2(timer * 0.5, timer * 0.25) - pos.zx;

    wave_x = sin(wave_x + wave_y);
    wave_z = cos(wave_z + wave_y);
    return vec3(wave_x.x + wave_x.y, 0.0, wave_z.x + wave_z.y);
}
