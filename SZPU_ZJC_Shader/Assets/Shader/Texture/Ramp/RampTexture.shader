Shader "Study/RampTexture"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _RampTex ("Ramp Tex", 2D) = "white" {}
        _MainTex ("Main Tex", 2D) = "white" {}
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(2.0, 256)) = 20   
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

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _RampTex;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _RampTex_ST;
            fixed4 _Specular;
            float _Gloss;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 bumpUv : TEXCOORD2;
                float2 uv : TEXCOORD3;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                o.bumpUv = TRANSFORM_TEX(v.texcoord, _RampTex);
                o.uv = v.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
                // 漫反射的颜色乘上这个渐变颜色的贴图即可完成光照渐变的效果
                fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * _Color.rgb;

                fixed3 diffuse = _LightColor0.rgb * diffuseColor;

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal,halfDir)), _Gloss);

                fixed4 col = tex2D(_MainTex,i.uv);
                return col * fixed4(ambient + diffuse + specular, 1.0);

            }
            ENDCG
        }
        
    }
    FallBack "Specular"
}
