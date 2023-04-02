Shader "Custom/Checkerboard"
{
    Properties
    {
        _EvenColor("EvenColor", color) = (0,0,0,1)
        _OddColor("OddColor", color) = (0,0,0,1)
        _Scale ("Pattern Size", Range(0,10)) = 1
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
            
            float _Scale;
            
            fixed4 _EvenColor;
            fixed4 _OddColor;
            
            
            struct InputData
            {
                float4 vertexPosition : POSITION;
            };
            
            
            struct OutputData
            {
                float4 vertexPosition : SV_POSITION;
                float3 worldPosition : TEXCOORD0;
            };
            
            
            OutputData vert(InputData input)
            {
                OutputData output;
                
                output.vertexPosition = UnityObjectToClipPos(input.vertexPosition);
                output.worldPosition = mul(unity_ObjectToWorld, output.vertexPosition);
                
                return output;
            }
            
            
            fixed4 frag(OutputData output) : SV_TARGET
            {
                float3 adjustedWorldPos = floor(output.worldPosition / _Scale);
                float chessboard = floor(adjustedWorldPos.x) + floor(adjustedWorldPos.y) + floor(adjustedWorldPos.z);
                chessboard = frac(chessboard * 0.5);
                chessboard *= 2;
                fixed4 color = lerp(_EvenColor, _OddColor, chessboard);
                return color;
            }
            
            ENDCG
        }
    }
    
    FallBack "Standard"
}
