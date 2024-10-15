/* MakeUp - shadow_vertex.glsl
Vertex shadow function.

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)

vec3 get_shadow_pos(vec3 shadow_pos) {
    shadow_pos = mat3(shadowModelView) * shadow_pos + shadowModelView[3].xyz;
    shadow_pos = diagonal3(shadowProjection) * shadow_pos + shadowProjection[3].xyz;

    float distb = length(shadow_pos.xy);
    float distortion = distb * SHADOW_DIST + (1.0 - SHADOW_DIST);

    shadow_pos.xy /= distortion;
    shadow_pos.z *= 0.2;
    
    return shadow_pos * 0.5 + 0.5;
}
