Shader "Custom/PlanarTexture"
{
    Properties
    {
        _Color("MainColor", Color) = (0,0,0,1)
        _MainTex("MainTexture", 2D) = "white" {} 
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
            
            float4 _MainTex_ST;
            fixed4 _Color;
            
            
            struct InputData
            {
                float4 vertexPosition : POSITION;
            };
            
            
            struct OutputData
            {
                float4 vertexPosition : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            
            OutputData vert(InputData input)
            {
                OutputData output;
                output.vertexPosition = UnityObjectToClipPos(input.vertexPosition);
                
                float4 worldVertexPosition = mul(unity_ObjectToWorld, input.vertexPosition);
                
                output.uv = TRANSFORM_TEX(worldVertexPosition.xy, _MainTex);
                
                return output;
            }
            
            
            fixed4 frag(OutputData output) : SV_TARGET
            {
                fixed4 color = tex2D(_MainTex, output.uv);
                return color;
            }
            
            ENDCG
        }
    }
    
    FallBack "Diffuse"
}
