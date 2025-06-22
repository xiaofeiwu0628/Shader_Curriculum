Shader "Study/VertexPhone"
{
    Properties
    {
        _Diffuse("Diffuse",Color) = (1,1,1,1)
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss("Gloss",range(2,256)) = 10
        _MainTex("Texture", 2D) = "white" {}
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

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            struct a2v
            {
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 color : COLOR;
                float4 pos : SV_POSITION;
            };

            v2f vert(a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);

                float3 H = normalize(worldLight + viewDir);

                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                fixed3 specular = _Specular * pow(max(0, dot(worldNormal, H)), _Gloss);

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

                o.color = ambient + diffuse + specular;
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                return fixed4(tex2D(_MainTex, i.uv) * i.color,1);
            }
            ENDCG
        }
    }
}
