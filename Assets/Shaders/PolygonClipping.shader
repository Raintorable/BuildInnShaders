Shader "Custom/PolygonClipping"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        Pass
        {
            CGPROGRAM
            
            #include "UnityCG.cginc"
    
            #pragma vertex vert
            #pragma fragment frag
            
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            
            sampler2D _SecondaryTex;
            fixed4 _SecondaryTex_ST;
            
            sampler2D _BlendTex;
            fixed4 _BlendTex_ST;
            
            
            struct InputData
            {
                float4 vertexPosition : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            
            struct OutputData
            {
                float4 vertexPosition : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
            };


            float4 GetGlobalVertexPosition(float4 vertexPosition)
            {
                return mul(unity_ObjectToWorld, vertexPosition);
            }
            
            
            OutputData vert(InputData input)
            {
                OutputData output;
                
                output.vertexPosition = UnityObjectToClipPos(input.vertexPosition);
                output.uv = input.uv;
                output.worldPosition = GetGlobalVertexPosition(input.vertexPosition);
                
                return output;
            }
            
            
            fixed4 frag(OutputData output) : SV_TARGET
            {
                float2 mainTex_uv = TRANSFORM_TEX(output.uv, _MainTex);
                fixed4 mainColor = tex2D(_MainTex, mainTex_uv);
                return mainColor;
            }
            
            ENDCG
        }
    }
    
    FallBack "Standard"
}
