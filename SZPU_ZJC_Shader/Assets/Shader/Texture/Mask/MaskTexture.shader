Shader "Study/MaskTexture"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap("Normal Map",2D) = "bump" {}
        _BumpScale("Bump Scale", Float) = 1.0
        _SpcularMask("Spcular Mask",2D) = "white" {}
        _SpcularScale("Spcular Scale", Float) = 1.0
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(2.0, 256.0)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        
        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
     
            sampler2D _MainTex;
            sampler2D _BumpMap;
            sampler2D _SpcularMask;

            fixed4 _Color;
            float4 _MainTex_ST;
            float _BumpScale;
            float _SpcularScale;
            fixed4 _Specular;
            float _Gloss;

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                TANGENT_SPACE_ROTATION;
                o.lightDir = mul (rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul (rotation, ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);

                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed specularMask = tex2D(_SpcularMask, i.uv).r * _SpcularScale;
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal,halfDir)), _Gloss) * specularMask;

                return fixed4(ambient + diffuse + specular,1.0);
            }
            ENDCG
        }
        
    }
    FallBack "Specular"
}
