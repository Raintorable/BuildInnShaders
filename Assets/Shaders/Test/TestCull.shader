Shader "Custom/Test/TestCull"
{
    Properties
    {
        _FrontTex ("Texture", 2D) = "white" {}
        _BackTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _FrontTex;
            sampler2D _BackTex;
            float4 _FrontTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _FrontTex);
                return o;
            }

            fixed4 frag (v2f i, bool face : SV_IsFrontFace) : SV_Target
            {
                fixed4 frontCol = tex2D(_FrontTex, i.uv);
                fixed4 backCol = tex2D(_BackTex, i.uv);
                return face ? frontCol : backCol;
            }
            ENDCG
        }
    }
}
