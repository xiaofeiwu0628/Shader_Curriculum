Shader "Unlit/UV_RotationVortexCutOut"
{
	Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _AngleMask ("Angle Mask", 2D) = "white" {}
        _xCenter("Center X",Float) = 0.5
        _yCenter("Center Y",Float) = 0.5
        _speed("Speed", Range(0.0,100.0)) = 1.0
    }
    SubShader
    {
        Tags {
            "RenderType"="Opaque"
        }
        Pass
        {
 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_fog
            #include "UnityCG.cginc"
            struct a2v
            {
                half4 vertex : POSITION;
                fixed2 uv : TEXCOORD0;
            };
 
            struct v2f
            {
                fixed2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
                half4 vertex : SV_POSITION;
            };
 
            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
 
            sampler2D _MainTex;
            sampler2D _AngleMask;
            fixed _xCenter;
            fixed _yCenter;
            half _speed;
 
            fixed4 frag (v2f i) : SV_Target
            {
			    
				fixed time = _Time.y;
 
                fixed4 colAng = tex2D(_AngleMask, i.uv);
                fixed angle = colAng.r; 
                fixed2 uvCenter = float2(_xCenter,_yCenter);
                // 计算旋转矩阵
                half rotateCos = cos(_speed*angle);
                half rotateSin = sin(_speed*angle);
                float2x2 rotateM = float2x2(rotateCos,-rotateSin,rotateSin,rotateCos);
 
                // 移动纹理位置，将旋转中心到(0,0)乘以旋转矩阵，再移回原来的位置   
                fixed2 uvNew =( mul(i.uv-uvCenter,rotateM)+uvCenter);			
                fixed4 col = tex2D(_MainTex, uvNew);
				 UNITY_APPLY_FOG(i.fogCoord, col)
                clip(col.a-0.5);
                return col;
            }
            ENDCG
        }
    }
}