﻿Shader "Hidden/BakeNormalMap"
{
CGINCLUDE
#include "UnityCG.cginc"

struct appdata
{
    float4 vertex : POSITION;
    float4 normal : NORMAL;
    float4 uv : TEXCOORD0;
    uint vertexID : SV_VertexID;
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float4 normal : TEXCOORD0;
};

StructuredBuffer<float3> _BaseNormals;
StructuredBuffer<float4> _BaseTangents;

sampler2D _NormalMap;
RWStructuredBuffer<float3> _DstNormals;

float3 ToBaseTangentSpace(uint vid, float3 n)
{
    float3 base_normal = _BaseNormals[vid];
    float4 base_tangent = _BaseTangents[vid];
    float3 base_binormal = normalize(cross(base_normal, base_tangent.xyz) * base_tangent.w);
    float3x3 tbn = float3x3(base_tangent.xyz, base_binormal, base_normal);
    return normalize(mul(n, transpose(tbn)));
}

float3 ToTangentSpace(uint vid, float3 n)
{
    float3 base_normal = _BaseNormals[vid];
    float4 base_tangent = _BaseTangents[vid];
    float3 base_binormal = normalize(cross(base_normal, base_tangent.xyz) * base_tangent.w);
    float3x3 tbn = float3x3(base_tangent.xyz, base_binormal, base_normal);
    return normalize(mul(n, tbn));
}

v2f vert_world(appdata v)
{
    v2f o;
    o.normal.rgb = ToBaseTangentSpace(v.vertexID, v.normal.xyz) * 0.5 + 0.5;
    o.normal.a = 1.0;
    o.vertex = UnityObjectToClipPos(v.vertex);
    return o;
}

v2f vert_uv(appdata v)
{
    v2f o;
    o.normal.rgb = ToBaseTangentSpace(v.vertexID, v.normal.xyz) * 0.5 + 0.5;
    o.normal.a = 1.0;
    o.vertex = float4(v.uv.xy * 2 - 1, 0.0, 1.0);
    return o;
}

v2f vert_write(appdata v)
{
    float3 n = tex2Dlod(_NormalMap, float4(v.uv.xy, 0, 0)).xyz * 2.0 - 1.0;
    _DstNormals[v.vertexID] = ToTangentSpace(v.vertexID, n);

    v2f o;
    o.normal = 0.0;
    o.vertex = 0.0;
    return o;
}

float4 frag(v2f i) : SV_Target
{
    return i.normal;
}
ENDCG

    SubShader
    {
        Tags{ "RenderType" = "Transparent" "Queue" = "Transparent+1" }

        // pass 0: world space
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_world
            #pragma fragment frag
            #pragma target 4.5
            ENDCG
        }

        // pass 1: uv space
        Pass
        {
            Cull Front

            CGPROGRAM
            #pragma vertex vert_uv
            #pragma fragment frag
            #pragma target 4.5
            ENDCG
        }

        // pass 2: bake normal map to vertices
        Pass
        {
            ColorMask 0

            CGPROGRAM
            #pragma vertex vert_write
            #pragma fragment frag
            #pragma target 4.5
            ENDCG
        }
    }
}
