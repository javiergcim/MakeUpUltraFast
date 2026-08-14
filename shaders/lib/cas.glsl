// Copyright © 2023 Advanced Micro Devices, Inc.

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files(the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and /or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions :

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

vec3 CAS(vec2 texcoord) {
    vec3 e = texture2DLod(colortex1, texcoord, 0.0).rgb;

    vec3 left  = texture2DLod(colortex1, texcoord + vec2(-pixelSizeX, 0.0), 0.0).rgb;
    vec3 right = texture2DLod(colortex1, texcoord + vec2( pixelSizeX, 0.0), 0.0).rgb;
    vec3 down  = texture2DLod(colortex1, texcoord + vec2(0.0, -pixelSizeY), 0.0).rgb;
    vec3 up    = texture2DLod(colortex1, texcoord + vec2(0.0,  pixelSizeY), 0.0).rgb;
    vec3 ul    = texture2DLod(colortex1, texcoord + vec2(-pixelSizeX,  pixelSizeY), 0.0).rgb;
    vec3 ur    = texture2DLod(colortex1, texcoord + vec2( pixelSizeX,  pixelSizeY), 0.0).rgb;
    vec3 dl    = texture2DLod(colortex1, texcoord + vec2(-pixelSizeX, -pixelSizeY), 0.0).rgb;
    vec3 dr    = texture2DLod(colortex1, texcoord + vec2( pixelSizeX, -pixelSizeY), 0.0).rgb;

    vec3 mnRGB  = min(min(min(left,e),min(right,up)),down);
    vec3 mnRGB2 = min(min(min(mnRGB,ul),min(dl,ur)),dr);
    mnRGB += mnRGB2;

    vec3 mxRGB  = max(max(max(left,e),max(right,up)),down);
    vec3 mxRGB2 = max(max(max(mxRGB,ul),max(dl,ur)),dr);
    mxRGB += mxRGB2;

    vec3 rcpMxRGB = vec3(1.0) / mxRGB;
    vec3 ampRGB = clamp(min(mnRGB, 2.0 - mxRGB) * rcpMxRGB, 0.0, 1.0);

    ampRGB = inversesqrt(ampRGB);
    float peak = 8.0 - 3.0 * SHARPENING;
    vec3 wRGB = -vec3(1.0) / (ampRGB * peak);
    vec3 rcpWeightRGB = vec3(1.0) / (1.0 + 4.0 * wRGB);

    vec3 window = (up + down) + (left + right);
    vec3 outColor = clamp((window * wRGB + e) * rcpWeightRGB, 0.0, 1.0);

    return outColor;
}