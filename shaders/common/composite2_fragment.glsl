#include "/lib/config.glsl"

const bool colortex0Clear = false;
const bool colortex1Clear = false;
#ifdef SELECTIVE_TAA_V2
    const bool colortex2Clear = true;
#else
    const bool colortex2Clear = false;
#endif
const bool colortex3Clear = false;
const bool gaux1Clear = false;
const bool gaux2Clear = false;
const bool gaux3Clear = false;
const bool gaux4Clear = false;

/* Uniforms */

uniform sampler2D colortex1;
#ifdef SELECTIVE_TAA_V2
    uniform sampler2D colortex2;
    uniform sampler2D colortex5;
#endif

#if AA_TYPE > 0 || defined MOTION_BLUR
    uniform sampler2D colortex3;  // TAA past averages
    uniform float pixelSizeX;
    uniform float pixelSizeY;
    uniform mat4 gbufferProjectionInverse;
    uniform mat4 gbufferProjection;
    uniform mat4 gbufferModelViewInverse;
    uniform vec3 cameraPosition;
    uniform vec3 previousCameraPosition;
    uniform mat4 gbufferPreviousProjection;
    uniform mat4 gbufferPreviousModelView;
    uniform sampler2D depthtex1;
    uniform float frameTime;
#endif

/* Ins / Outs */

varying vec2 texcoord;

/* Utility functions */

#if AA_TYPE > 0 || defined MOTION_BLUR
    #include "/lib/projection_utils.glsl"
#endif

#ifdef MOTION_BLUR
    #include "/lib/dither.glsl"
    #include "/lib/motion_blur.glsl"
#endif

#if AA_TYPE > 0
    #include "/lib/luma.glsl"
    #include "/lib/color_conversion.glsl"
    #include "/lib/fast_taa.glsl"

    #ifdef SELECTIVE_TAA_V2
        #include "/lib/fxaa.glsl"
    #endif

#endif

// MAIN FUNCTION ------------------

void main() {
    vec4 blockColor = texture2DLod(colortex1, texcoord, 0);

    // Precalc past position and velocity
    #if AA_TYPE > 0 || defined MOTION_BLUR
        // Retrojection of previous frame
        float z_depth = texture2DLod(depthtex1, texcoord, 0).r;
        vec2 texcoordPast;
        vec3 curr_view_pos;
        vec3 curr_feet_player_pos;
        vec3 prev_feet_player_pos;
        vec3 prev_view_pos;
        vec2 final_pos;

        if(z_depth < 0.56) {
            texcoordPast = texcoord;
        } else {
            curr_view_pos =
                vec3(vec2(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y) * (texcoord * 2.0 - 1.0) + gbufferProjectionInverse[3].xy, gbufferProjectionInverse[3].z);
            curr_view_pos /= (gbufferProjectionInverse[2].w * (z_depth * 2.0 - 1.0) + gbufferProjectionInverse[3].w);
            curr_feet_player_pos = mat3(gbufferModelViewInverse) * curr_view_pos + gbufferModelViewInverse[3].xyz;

            prev_feet_player_pos =
                z_depth > 0.56 ? curr_feet_player_pos + cameraPosition - previousCameraPosition : curr_feet_player_pos;
            prev_view_pos = mat3(gbufferPreviousModelView) * prev_feet_player_pos + gbufferPreviousModelView[3].xyz;
            final_pos =
                vec2(gbufferPreviousProjection[0].x, gbufferPreviousProjection[1].y) * prev_view_pos.xy + gbufferPreviousProjection[3].xy;
            texcoordPast = (final_pos / -prev_view_pos.z) * 0.5 + 0.5;
        }

    #endif

    #ifdef MOTION_BLUR
        #if AA_TYPE > 0
           float dither = shiftedDitherMakeup(gl_FragCoord.xy);
        #else
           float dither = ditherMakeup(gl_FragCoord.xy);
        #endif
        // "Speed"
        vec2 velocity = texcoord - texcoordPast;
        blockColor.rgb = motionBlur(blockColor.rgb, z_depth, velocity, dither, colortex1);
    #endif

    #if AA_TYPE > 0
        #ifdef SELECTIVE_TAA_V2
            float objectMask = texture2DLod(colortex2, texcoord, 0.0).r;
            float nextPreviousMask = objectMask;
            vec2 mp = vec2(pixelSizeX, pixelSizeY);
            objectMask = max(objectMask, texture2DLod(colortex2, texcoord + vec2(mp.x, 0.0), 0.0).r);
            objectMask = max(objectMask, texture2DLod(colortex2, texcoord - vec2(mp.x, 0.0), 0.0).r);
            objectMask = max(objectMask, texture2DLod(colortex2, texcoord + vec2(0.0, mp.y), 0.0).r);
            objectMask = max(objectMask, texture2DLod(colortex2, texcoord - vec2(0.0, mp.y), 0.0).r);
            float previousObjectMask = texture2DLod(colortex5, texcoordPast, 0.0).r;
            if(objectMask > 0.5 || previousObjectMask > 0.5) {
                blockColor.rgb = fxaa311(blockColor.rgb, 6);
            } else {
        #endif

        #ifdef DOF
            blockColor = fastTaaDepth(blockColor, texcoordPast);
        #else
            blockColor.rgb = fastTaa(blockColor.rgb, texcoordPast);
        #endif

        #ifdef SELECTIVE_TAA_V2
            }
        #endif

        blockColor=clamp(blockColor, vec4(0.0), vec4(vec3(50.0), 1.0));

        #ifdef SELECTIVE_TAA_V2
            /* DRAWBUFFERS:135 */
            gl_FragData[0] = blockColor;
            gl_FragData[1] = blockColor;
            gl_FragData[2] = vec4(nextPreviousMask);  // Current mask to next frame's previous mask
        #else
            /* DRAWBUFFERS:13 */
            gl_FragData[0] = blockColor;
            gl_FragData[1] = blockColor;
        #endif
        
    #else
        blockColor=clamp(blockColor,vec4(0.0),vec4(vec3(50.0),1.0));
        /* DRAWBUFFERS:1 */
        gl_FragData[0]=blockColor;
    #endif
}
