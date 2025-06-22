Shader "Study/ZWriteForward"
{
    Properties
    {
        [HDR]_BackColor("BackColor",Color) = (1,1,1,1)
        _Diffuse("Diffuse",Color)=(1,1,1,1)
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",range(2,256)) = 10
        _MainTex("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            blend srcalpha oneminussrcalpha
            ztest greater
            zwrite off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            fixed4 _BackColor;
            struct v2f
            {
                float4 vertex :POSITION;
            };
            v2f vert (appdata_base v)
            {
                v2f o;
                // o.vertex = v.vertex;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : COLOR
            {
                // _A = sin(_Time.w)/2 + 0.5;
                return _BackColor;
            }
            ENDCG
        }
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
                fixed3 WorldNormal : COLOR;
                float3 worldPos: TEXCOORD1;
            };

            v2f vert(a2v v) 
            {
                v2f o;

                o.Pos = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                o.WorldNormal = normalize(UnityObjectToWorldNormal(v.normal));

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET 
            {
                float3 LightDir = normalize(_WorldSpaceLightPos0.xyz);
                
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

                fixed3 halfDir = normalize(viewDir + LightDir);
                
                fixed3 diffuse = _LightColor0.rgb * _Diffuse * (dot(LightDir, i.WorldNormal)*0.5+0.5);

                fixed3 specular = _LightColor0.rgb * _Specular * pow(max(dot(i.WorldNormal, halfDir), 0), _Gloss);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;

                fixed3 color = specular + diffuse + ambient;
                
                return fixed4(tex2D(_MainTex, i.uv) * color, 1);
            }
            ENDCG
        }
    }
}
