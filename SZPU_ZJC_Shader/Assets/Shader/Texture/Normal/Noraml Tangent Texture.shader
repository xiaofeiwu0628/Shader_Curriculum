Shader "Study/Noraml Tangent Texture"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap("Normal Map",2D) = "bump" {}

        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(2.0, 256.0)) = 20
       
       
       
        _BumpScale("Bump Scale", Float) = 1.0
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

            sampler2D _MainTex;
            sampler2D _BumpMap;

            fixed4 _Color;
            float4 _MainTex_ST;
            float4 _BumpMap_ST;
            fixed4 _Specular;
            float _BumpScale;
            float _Gloss;

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
                float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
 
                // float3 worldNormal : TEXCOORD0;
                // float3 worldPos : TEXCOORD1;
                // float2 uv : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                // float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz))*v.tangent;
                // float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz));
                // float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
                TANGENT_SPACE_ROTATION;

                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                // o.lightDir = ObjSpaceLightDir(v.vertex).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                // o.viewDir = ObjSpaceViewDir(v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDIr = normalize(i.viewDir);

                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));


                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                // 漫反射
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal,tangentLightDir));

                fixed3 halfDir = normalize(tangentLightDir + tangentViewDIr);
                // 镜面反射
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(tangentNormal, halfDir)),_Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
