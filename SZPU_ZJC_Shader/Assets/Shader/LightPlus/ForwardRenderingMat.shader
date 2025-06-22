// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Study/ForwardRenderingMat"
{
    Properties
    {
        _Diffuse("Diffuse",Color) = (0,0,0,0)
        _Specular ("SPecular",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(2.0,256.0)) = 32
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        // LOD 100

        Pass
        {
            Tags { "LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            // #include "UnityCG.cginc"
            #include "Lighting.cginc"

            float _Gloss;
            fixed4 _Specular;
            fixed4 _Diffuse;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i):SV_TARGET
            {
                float3 N = normalize(i.worldNormal);
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                float3 H = normalize(L + V);

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // 漫反射计算
                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(N, L));
                // 镜面反射计算（Blinn-Phong）
                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(N, H)), _Gloss);

                fixed atten = 1.0;
                // 综合颜色（叠加漫反射和镜面反射）
                return fixed4(ambient + (diffuse + specular) * atten, 1.0);
            }
            ENDCG
        }
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }

            Blend One One
            CGPROGRAM
            #pragma multi_compile_fwdadd
            #pragma vertex vert
            #pragma fragment frag
            // #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            float _Gloss;
            fixed4 _Specular;
            fixed4 _Diffuse;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i):SV_TARGET
            {
                float3 N = normalize(i.worldNormal);
                #ifdef USING_DIRECTIONAL_LIGHT
                    float3 L = normalize(_WorldSpaceLightPos0.xyz);
                #else 
                    float3 L = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
                #endif
                float3 V = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz); // 视线方向
                float3 H = normalize(L + V);                            // 半角向量

                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(N, L));

                float3 specular = _Specular * pow(max(0, dot(N, H)), _Gloss);

                #ifdef USING_DIRECTIONAL_LIGHT 
                    fixed atten = 1.0;
                #else 
                    #if defined (POINT)
				        float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
				        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #elif defined (SPOT)
				        float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
				        fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #else
				        fixed atten = 1.0;
				    #endif
                #endif
                // 综合颜色（叠加漫反射和镜面反射）
                // return fixed4(ambient + (diffuse) * atten,1.0);
                return fixed4((diffuse + specular) * atten,1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
