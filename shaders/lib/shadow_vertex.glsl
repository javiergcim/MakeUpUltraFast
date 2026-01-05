/* MakeUp - shadow_vertex.glsl
Vertex shadow function.

Javier Garduño - GNU Lesser General Public License v3.0
*/

#define diagonal3(m) vec3((m)[0].x, (m)[1].y, m[2].z)

vec3 get_shadow_pos(vec3 shadowPos) {
    shadowPos = mat3(shadowModelView) * shadowPos + shadowModelView[3].xyz;
    shadowPos = diagonal3(shadowProjection) * shadowPos + shadowProjection[3].xyz;

    float distb = length(shadowPos.xy);
    float distortion = distb * SHADOW_DIST + (1.0 - SHADOW_DIST);

    shadowPos.xy /= distortion;
    shadowPos.z *= 0.2;
    
    return shadowPos * 0.5 + 0.5;
}
