Shader "Study/VertexSpecularLightShader"
{
    Properties
    {
        _Diffuse("Diffuse",Color) = (1,1,1,1)
        _Specular ("SPecular",Color) = (1,1,1,1)
        _Gloss("Gloss",Range(2.0,256.0)) = 32.0
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include"Lighting.cginc"

            float _Gloss;
            fixed4 _Specular;
            fixed4 _Diffuse;
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float3 color : COLOR;
                float4 pos : SV_POSITION;
            };

            v2f vert(a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

                fixed3 reflectDir = normalize(reflect(-worldLight, worldNormal));

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld,v.vertex).xyz);

                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

                o.color = ambient + diffuse + specular;
                
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                return fixed4(i.color,1);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
