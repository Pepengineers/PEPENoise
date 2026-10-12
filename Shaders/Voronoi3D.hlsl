#ifndef PEPENOISE_VORONOI3D_INCLUDED
#define PEPENOISE_VORONOI3D_INCLUDED

#pragma use_dxc
#pragma require int64bufferatomics

#include "NoiseCommon.hlsl"

inline float3 VoronoiVector(float3 UV, float offset)
{
    float3x3 m = float3x3(15.27, 47.63, 99.41, 89.98, 95.07, 38.39, 33.83, 51.06, 60.77);
    UV = frac(sin(mul(UV, m)) * 46839.32);
    return float3(sin(UV.y * offset) * 0.5 + 0.5, cos(UV.x * offset) * 0.5 + 0.5, sin(UV.z * offset) * 0.5 + 0.5);
}

float2 vnoise(float3 UV, float AngleOffset, float CellDensity)
{
    float3 p = UV * CellDensity;
    float3 g = floor(p);
    float3 f = frac(p);
    float2 res = float2(8.0, 8.0);

#if defined(UNITY_COMPILER_DXC) || (defined(__SHADER_TARGET_MAJOR) && (__SHADER_TARGET_MAJOR > 6 || (__SHADER_TARGET_MAJOR == 6 && __SHADER_TARGET_MINOR >= 6)))
    bool helper = false;
#if defined(SHADER_STAGE_FRAGMENT) || (defined(__SHADER_TARGET_STAGE) && __SHADER_TARGET_STAGE == 0)
    helper = IsHelperLane();
#endif
    bool distribute = false;
    [branch] if (!helper)
    {
        uint4 key = asuint(float4(g, AngleOffset));
        uint4 active = WaveActiveBallot(true);
        uint4 firstKey = WaveReadLaneFirst(key);
        bool sameKey = WaveActiveAllTrue(all(key == firstKey));
        // Fixed sources 0..26 are valid only when every lane of this wave32 is active.
        distribute = WaveGetLaneCount() == 32 && active.x == 0xffffffffu && sameKey;
    }

    [branch] if (distribute)
    {
        uint lane = WaveGetLaneIndex();
        float3 feature = 0.0;
        [branch] if (lane < 27)
        {
            float3 lattice = float3((int)(lane / 3 % 3) - 1,
                                    (int)(lane / 9) - 1,
                                    (int)(lane % 3) - 1);
            feature = VoronoiVector(g + lattice, AngleOffset);
        }
        // Reconverge producers before any lane reads their feature offsets.
        uint candidate = 0;
        [unroll] for (int y = -1; y <= 1; y++)
        {
            [unroll] for (int x = -1; x <= 1; x++)
            {
                [unroll] for (int z = -1; z <= 1; z++)
                {
                    float3 lattice = float3(x, y, z);
                    float3 offset = WaveReadLaneAt(feature, candidate++);
                    float3 v = lattice + offset - f;
                    float d = dot(v, v);

                    res.y = min(res.y, max(res.x, d));
                    res.x = min(res.x, d);
                }
            }
        }
    }
    else
#endif
    {
        [unroll] for (int y = -1; y <= 1; y++)
        {
            [unroll] for (int x = -1; x <= 1; x++)
            {
                [unroll] for (int z = -1; z <= 1; z++)
                {
                    float3 lattice = float3(x, y, z);
                    float3 offset = VoronoiVector(g + lattice, AngleOffset);
                    float3 v = lattice + offset - f;
                    float d = dot(v, v);

                    res.y = min(res.y, max(res.x, d));
                    res.x = min(res.x, d);
                }
            }
        }
    }

    // A feature in the outer shell can be closer than either of the first 27 candidates.
    float3 boundary = 1.0 + min(f, 1.0 - f);
    float minBoundary = min(boundary.x, min(boundary.y, boundary.z));
    [branch] if (res.y > minBoundary * minBoundary)
    {
        float radius = sqrt(res.y);
        // Round the cell bounds outward to keep FP32 culling conservative.
        int3 lower = max((int3)floor(f - radius - 1e-6), -2);
        int3 upper = min((int3)floor(f + radius + 1e-6), 2);
        [loop] for (int y = lower.y; y <= upper.y; y++)
        {
            [loop] for (int x = lower.x; x <= upper.x; x++)
            {
                [loop] for (int z = lower.z; z <= upper.z; z++)
                {
                    if (abs(x) < 2 && abs(y) < 2 && abs(z) < 2)
                        continue;

                    float3 lattice = float3(x, y, z);
                    float3 nearest = max(max(lattice - f, f - lattice - 1.0), 0.0);
                    [branch] if (dot(nearest, nearest) < res.y)
                    {
                        float3 offset = VoronoiVector(g + lattice, AngleOffset);
                        float3 v = lattice + offset - f;
                        float d = dot(v, v);
                        res.y = min(res.y, max(res.x, d));
                        res.x = min(res.x, d);
                    }
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

void Voronoi3D_half(half3 UV, half AngleOffset, half CellDensity, out half Out, out half Cells)
{
    float2 res = vnoise((float3)UV, (float)AngleOffset, (float)CellDensity);
    Out = (half)res.x;
    Cells = (half)res.y;
}

#endif
