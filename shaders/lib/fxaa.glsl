/* MakeUp Ultra Fast - fxaa_intel.glsl
FXAA 3.11 from Simon Rodriguez
http://blog.simonrodriguez.fr/articles/30-07-2016_implementing_fxaa.html

*/

const float quality[12] = float[12] (1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.5f, 2.0f, 2.0f, 2.0f, 2.0f, 4.0f, 8.0f);

vec3 fxaa311(vec3 color, int iterations){
  vec3 aa = color;

  float edgeThresholdMin = 0.03125f;
  float edgeThresholdMax = 0.0625f;
  float subpixelQuality = 0.75f;

  // Luma at the current fragment
  float lumaCenter = luma(color);
  // Luma at the four direct neighbours of the current fragment.
  float lumaDown = luma(texture2D(colortex1, texcoord.xy + vec2(0.0f,-pixel_size_y), 0.0).rgb);
  float lumaUp = luma(texture2D(colortex1, texcoord.xy + vec2(0.0f,pixel_size_y), 0).rgb);
  float lumaLeft = luma(texture2D(colortex1, texcoord.xy + vec2(-pixel_size_x,0.0f), 0).rgb);
  float lumaRight = luma(texture2D(colortex1, texcoord.xy + vec2(pixel_size_x, 0.0f), 0).rgb);

  // Find the maximum and minimum luma around the current fragment.
  float lumaMin = min(lumaCenter, min(min(lumaDown, lumaUp), min(lumaLeft, lumaRight)));
  float lumaMax = max(lumaCenter, max(max(lumaDown, lumaUp), max(lumaLeft, lumaRight)));

  // Compute the delta.
  float lumaRange = lumaMax - lumaMin;

  // If the luma variation is lower that a threshold (or if we are in a really dark area), we are not on an edge, don't perform any FXAA.
  if (lumaRange > max(edgeThresholdMin, lumaMax * edgeThresholdMax)) {
    // Query the 4 remaining corners lumas.
    float lumaDownLeft = luma(texture2D(colortex1, texcoord.xy + vec2(-pixel_size_x, -pixel_size_y), 0).rgb);
    float lumaUpRight = luma(texture2D(colortex1, texcoord.xy + vec2(pixel_size_x, pixel_size_y), 0).rgb);
    float lumaUpLeft = luma(texture2D(colortex1, texcoord.xy + vec2(-pixel_size_x, pixel_size_y), 0).rgb);
    float lumaDownRight = luma(texture2D(colortex1, texcoord.xy + vec2(pixel_size_x, -pixel_size_y), 0).rgb);

    // Combine the four edges lumas (using intermediary variables for future computations with the same values).
    float lumaDownUp = lumaDown + lumaUp;
    float lumaLeftRight = lumaLeft + lumaRight;

    // Same for corners
    float lumaLeftCorners = lumaDownLeft + lumaUpLeft;
    float lumaDownCorners = lumaDownLeft + lumaDownRight;
    float lumaRightCorners = lumaDownRight + lumaUpRight;
    float lumaUpCorners = lumaUpRight + lumaUpLeft;

    // Compute an estimation of the gradient along the horizontal and vertical axis.
    float edgeHorizontal = abs(-2.0f * lumaLeft + lumaLeftCorners) + abs(-2.0f * lumaCenter + lumaDownUp ) * 2.0f + abs(-2.0f * lumaRight + lumaRightCorners);
    float edgeVertical = abs(-2.0f * lumaUp + lumaUpCorners) + abs(-2.0f * lumaCenter + lumaLeftRight) * 2.0f + abs(-2.0f * lumaDown + lumaDownCorners);

    // Is the local edge horizontal or vertical ?
    bool isHorizontal = (edgeHorizontal >= edgeVertical);

    // Select the two neighboring texels lumas in the opposite direction to the local edge.
    float luma1 = isHorizontal ? lumaDown : lumaLeft;
    float luma2 = isHorizontal ? lumaUp : lumaRight;
    // Compute gradients in this direction.
    float gradient1 = luma1 - lumaCenter;
    float gradient2 = luma2 - lumaCenter;

    // Which direction is the steepest ?
    bool is1Steepest = abs(gradient1) >= abs(gradient2);
    // Gradient in the corresponding direction, normalized.
    float gradientScaled = 0.25f*max(abs(gradient1), abs(gradient2));

    // Choose the step size (one pixel) according to the edge direction.
    float stepLength = isHorizontal ? pixel_size_y : pixel_size_x;

    // Average luma in the correct direction.
    float lumaLocalAverage = 0.0;

    if (is1Steepest){
      // Switch the direction
      stepLength = - stepLength;
      lumaLocalAverage = 0.5f*(luma1 + lumaCenter);
    } else {
      lumaLocalAverage = 0.5f*(luma2 + lumaCenter);
    }

    // Shift UV in the correct direction by half a pixel.
    vec2 currentUv = texcoord.xy;
    if (isHorizontal){
      currentUv.y += stepLength * 0.5f;
    } else {
      currentUv.x += stepLength * 0.5f;
    }

    // Compute offset (for each iteration step) in the right direction.
    vec2 offset = isHorizontal ? vec2(pixel_size_x, 0.0) : vec2(0.0, pixel_size_y);

    // Compute UVs to explore on each side of the edge, orthogonally. The QUALITY allows us to step faster.
    vec2 uv1 = currentUv - offset;
    vec2 uv2 = currentUv + offset;

    // Read the lumas at both current extremities of the exploration segment, and compute the delta wrt to the local average luma.
    float lumaEnd1 = luma(texture2D(colortex1, uv1, 0).rgb);
    float lumaEnd2 = luma(texture2D(colortex1, uv2, 0).rgb);
    lumaEnd1 -= lumaLocalAverage;
    lumaEnd2 -= lumaLocalAverage;

    // If the luma deltas at the current extremities are larger than the local gradient, we have reached the side of the edge.
    bool reached1 = abs(lumaEnd1) >= gradientScaled;
    bool reached2 = abs(lumaEnd2) >= gradientScaled;
    bool reachedBoth = reached1 && reached2;

    // If the side is not reached, we continue to explore in this direction.
    if (!reached1){
      uv1 -= offset;
    }
    if (!reached2){
      uv2 += offset;
    }

    // If both sides have not been reached, continue to explore.
    if (!reachedBoth) {
      for(int i = 2; i < iterations; i++) {
        // If needed, read luma in 1st direction, compute delta.
        if (!reached1) {
          lumaEnd1 = luma(texture2D(colortex1, uv1, 0).rgb);
          lumaEnd1 = lumaEnd1 - lumaLocalAverage;
        }
        // If needed, read luma in opposite direction, compute delta.
        if (!reached2) {
          lumaEnd2 = luma(texture2D(colortex1, uv2, 0).rgb);
          lumaEnd2 = lumaEnd2 - lumaLocalAverage;
        }

        // If the luma deltas at the current extremities is larger than the
        // local gradient, we have reached the side of the edge.
        reached1 = abs(lumaEnd1) >= gradientScaled;
        reached2 = abs(lumaEnd2) >= gradientScaled;
        reachedBoth = reached1 && reached2;

        // If the side is not reached, we continue to explore in this direction,
        // with a variable quality.
        if (!reached1) {
          uv1 -= offset * quality[i];
        }
        if (!reached2) {
          uv2 += offset * quality[i];
        }

        // If both sides have been reached, stop the exploration.
        if (reachedBoth) {
          break;
        }
      }
    }

    // Compute the distances to each extremity of the edge.
    float distance1 = isHorizontal ? (texcoord.x - uv1.x) : (texcoord.y - uv1.y);
    float distance2 = isHorizontal ? (uv2.x - texcoord.x) : (uv2.y - texcoord.y);

    // In which direction is the extremity of the edge closer ?
    bool isDirection1 = distance1 < distance2;
    float distanceFinal = min(distance1, distance2);

    // Length of the edge.
    float edgeThickness = (distance1 + distance2);

    // UV offset: read in the direction of the closest side of the edge.
    float pixelOffset = - distanceFinal / edgeThickness + 0.5f;


    // Is the luma at center smaller than the local average ?
    bool isLumaCenterSmaller = lumaCenter < lumaLocalAverage;

    // If the luma at center is smaller than at its neighbour, the delta luma at
    // each end should be positive (same variation).
    // (in the direction of the closer side of the edge.)
    bool correctVariation = ((isDirection1 ? lumaEnd1 : lumaEnd2) < 0.0) != isLumaCenterSmaller;

    // If the luma variation is incorrect, do not offset.
    float finalOffset = correctVariation ? pixelOffset : 0.0f;

    // Sub-pixel shifting
    // Full weighted average of the luma over the 3x3 neighborhood.
    float lumaAverage = (1.0f/12.0f) * (2.0f * (lumaDownUp + lumaLeftRight) + lumaLeftCorners + lumaRightCorners);
    // Ratio of the delta between the global average and the center luma, over
    // the luma range in the 3x3 neighborhood.
    float subPixelOffset1 = clamp(abs(lumaAverage - lumaCenter)/lumaRange,0.0f,1.0f);
    float subPixelOffset2 = (-2.0f * subPixelOffset1 + 3.0f) * subPixelOffset1 * subPixelOffset1;
    // Compute a sub-pixel offset based on this delta.
    float subPixelOffsetFinal = subPixelOffset2 * subPixelOffset2 * subpixelQuality;

    // Pick the biggest of the two offsets.
    finalOffset = max(finalOffset, subPixelOffsetFinal);

    // Compute the final UV coordinates.
    vec2 finalUv = texcoord.xy;
    if (isHorizontal){
      finalUv.y += finalOffset * stepLength;
    } else {
      finalUv.x += finalOffset * stepLength;
    }

    // Read the color at the new UV coordinates, and use it.
    aa = texture2D(colortex1, finalUv, 0).rgb;
  }

  return aa;
}