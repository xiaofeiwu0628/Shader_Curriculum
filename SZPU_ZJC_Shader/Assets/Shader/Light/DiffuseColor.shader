Shader "Study/DiffuseShader" {
    Properties {
        _Color ("Diffuse Color", Color) = (1,1,1,1)  // 材质的漫反射颜色
    }
    SubShader {
        Tags { "LightMode"="ForwardBase" }  // 启用基础光照

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"  // 引入光照计算函数

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;  // 顶点法线
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;  // 世界空间法线
                float3 worldPos : TEXCOORD1;    // 世界空间顶点位置
            };

            float4 _Color;

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);  // 顶点位置变换到裁剪空间
                o.worldNormal = UnityObjectToWorldNormal(v.normal);  // 法线转到世界空间
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; // 顶点位置转到世界空间
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                // 归一化法线
                float3 N = normalize(i.worldNormal);
                // 计算光源方向（假设是平行光）
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                // 计算漫反射强度（Lambert）
                float diffuse = max(0, dot(N, L));
                // 综合颜色
                fixed4 col = _LightColor0 * _Color * diffuse;
                return col;
            }
            ENDCG
        }
    }
}