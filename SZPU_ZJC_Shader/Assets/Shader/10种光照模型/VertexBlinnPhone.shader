Shader "Unlit/VertexBlinnPhone"
{
    Properties
    {
        _Diffuse("Diffuse",Color)=(1,1,1,1)
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",range(2,256)) = 10
        _MainTex("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #include "Lighting.cginc"
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            struct a2v {
                float3 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 Pos: SV_POSITION;
                float3 col: COLOR;
            };

            v2f vert(a2v v) 
            {
                v2f o;

                o.Pos = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                float3 WorldNormal = normalize(UnityObjectToWorldNormal(v.normal));

                float3 LightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);

                fixed3 halfDir = normalize(viewDir + LightDir);

                fixed3 diffuse = _LightColor0.rgb * _Diffuse * (dot(LightDir, WorldNormal));

                fixed3 specular = _LightColor0.rgb * _Specular * pow(max(dot(WorldNormal, halfDir), 0), _Gloss);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                o.col = specular + diffuse + ambient;

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET 
            {
                return fixed4(tex2D(_MainTex, i.uv) * i.col, 1);
            }
            ENDCG
        }
    }
}
