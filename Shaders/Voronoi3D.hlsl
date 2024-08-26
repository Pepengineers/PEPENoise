#ifndef _INCLUDE_VORONOINOISE_HLSL_
#define _INCLUDE_VORONOINOISE_HLSL_

#include "NoiseCommon.hlsl"

inline float3 VoronoiVector(float3 UV, float offset)
{
    float3x3 m = float3x3(15.27, 47.63, 99.41, 89.98, 95.07, 38.39, 33.83, 51.06, 60.77);
    UV = frac(sin(mul(UV, m)) * 46839.32);
    return float3(sin(UV.y * +offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5, sin(UV.z * offset) * 0.5 + 0.5);
}

float2 vnoise(float3 UV, float AngleOffset, float CellDensity)
{
    float3 g = floor(UV * CellDensity);
    float3 f = frac(UV * CellDensity);
    float3 res = float3(8.0, 8.0, 8.0);

    UNITY_UNROLL for (int y = -1; y <= 1; y++)
    {
        UNITY_UNROLL for (int x = -1; x <= 1; x++)
        {
            UNITY_UNROLL for (int z = -1; z <= 1; z++)
            {
                float3 lattice = float3(x, y, z);
                float3 offset = VoronoiVector(g + lattice, AngleOffset);
                float3 v = lattice + offset - f;
                float d = dot(v, v);

                if (d < res.x)
                {
                    res.y = res.x;
                    res.x = d;
                    res.z = offset.x;
                }
                else if (d < res.y)
                {
                    res.y = d;
                }
            }
        }
    }
    return res;
}

void Voronoi3D_float(float3 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
{
    float2 res = vnoise(UV, AngleOffset, CellDensity);
    Out = res.x;
    Cells = res.y;
}

#endif
