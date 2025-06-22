Shader "Study/FragmentLambert"
{
    Properties
    {
        _Diffuse("Diffuse",Color) = (0,0,0,0)
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
            sampler2D _MainTex;
            float4 _MainTex_ST;
            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD1;
                float3 normal : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert(a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.normal, worldLight));

                fixed3 color = ambient + diffuse;
                
                return fixed4(tex2D(_MainTex, i.uv) * color,1);
            }
            ENDCG
        }
    }
}
