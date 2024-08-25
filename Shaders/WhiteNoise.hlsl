#ifndef _INCLUDE_WHITENOISE2D_HLSL_
#define _INCLUDE_WHITENOISE2D_HLSL_


#include "NoiseCommon.hlsl"



void WhiteNoise2D_float(float2 input, out float Out)
{
    Out = rand2dTo1d(input);
}

void WhiteNoise3D_float(float3 input, out float Out)
{
    Out = rand3dTo1d(input);
}
#endif
