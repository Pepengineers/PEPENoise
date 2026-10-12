#ifndef PEPENOISE_WHITE_INCLUDED
#define PEPENOISE_WHITE_INCLUDED


#include "NoiseCommon.hlsl"



void WhiteNoise2D_float(float2 input, out float Out)
{
    Out = PEPENoiseRand2dTo1d(input);
}

void WhiteNoise3D_float(float3 input, out float Out)
{
    Out = PEPENoiseRand3dTo1d(input);
}

void WhiteNoise2D_half(half2 input, out half Out)
{
    Out = (half)PEPENoiseRand2dTo1d((float2)input);
}

void WhiteNoise3D_half(half3 input, out half Out)
{
    Out = (half)PEPENoiseRand3dTo1d((float3)input);
}
#endif
