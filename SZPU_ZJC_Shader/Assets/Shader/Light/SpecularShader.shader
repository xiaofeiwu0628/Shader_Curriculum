Shader "Study/SpecularShader" {
    Properties {
        _Color ("Diffuse Color", Color) = (1,1,1,1)
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)  // 高光颜色
        _Gloss ("Gloss", Range(1, 256)) = 32                   // 高光指数
    }
    SubShader {
        Tags { "LightMode"="ForwardBase" }
        
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            float4 _Color;
            float4 _SpecularColor;
            float _Gloss;

            v2f vert (appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                // 向量归一化
                float3 N = normalize(i.worldNormal);
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos); // 视线方向
                float3 H = normalize(L + V);                            // 半角向量

                // 漫反射计算
                float diffuse = max(0, dot(N, L));
                // 镜面反射计算（Blinn-Phong）
                float specular = pow(max(0, dot(N, H)), _Gloss);

                // 综合颜色（叠加漫反射和镜面反射）
                fixed4 col = _LightColor0 * (_Color * diffuse + _SpecularColor * specular);
                return col;
            }
            ENDCG
        }
    }
}