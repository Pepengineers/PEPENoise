#ifndef PEPENOISE_COMMON_INCLUDED
#define PEPENOISE_COMMON_INCLUDED

float4 PEPENoiseMod(float4 x, float4 y)
{
    return x - y * floor(x / y);
}

float3 PEPENoiseMod(float3 x, float3 y)
{
    return x - y * floor(x / y);
}

float2 PEPENoiseMod289(float2 x)
{
    return x - floor(x / 289.0) * 289.0;
}

float3 PEPENoiseMod289(float3 x)
{
    return x - floor(x / 289.0) * 289.0;
}

float4 PEPENoiseMod289(float4 x)
{
    return x - floor(x / 289.0) * 289.0;
}

float4 PEPENoisePermute(float4 x)
{
    return PEPENoiseMod289(((x * 34.0) + 1.0) * x);
}

float3 PEPENoisePermute(float3 x)
{
    return PEPENoiseMod289((x * 34.0 + 1.0) * x);
}

float4 PEPENoiseTaylorInvSqrt(float4 r)
{
    return mad(-0.85373472095314, r, 1.79284291400159);
}

float3 PEPENoiseTaylorInvSqrt(float3 r)
{
    return mad(-0.85373472095314, r, 1.79284291400159);
}

float3 PEPENoiseFade(float3 t)
{
    return t * t * t * mad(t, mad(t, 6.0, -15.0), 10.0);
}

float2 PEPENoiseFade(float2 t)
{
    return t * t * t * mad(t, mad(t, 6.0, -15.0), 10.0);
}

float PEPENoiseRand2dTo1d(float2 value, float2 dotDir = float2(12.9898, 78.233))
{
    float2 smallValue = sin(value);
    float random = dot(smallValue, dotDir);
    random = frac(sin(random) * 143758.5453);
    return random;
}

float PEPENoiseRand1dTo1d(float3 value, float mutator = 0.546)
{
    float random = frac(sin(value.x + mutator) * 143758.5453);
    return random;
}

float PEPENoiseRand3dTo1d(float3 value, float3 dotDir = float3(12.9898, 78.233, 37.719))
{
    //make value smaller to avoid artefacts
    float3 smallValue = sin(value);
    //get scalar value from 3d vector
    float random = dot(smallValue, dotDir);
    //make value more random by making it bigger and then taking the factional part
    random = frac(sin(random) * 143758.5453);
    return random;
}

#endif
