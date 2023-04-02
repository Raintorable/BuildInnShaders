Shader "Custom/ColorLerp"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} //the base texture
        _SecondaryTex ("Secondary Texture", 2D) = "black" {} //the texture to blend to
        _BlendTex("BlendTex", 2D) = "white" {}
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
            };
            
            
            OutputData vert(InputData input)
            {
                OutputData output;
                
                output.vertexPosition = UnityObjectToClipPos(input.vertexPosition);
                output.uv = input.uv;
                
                return output;
            }
            
            
            fixed4 frag(OutputData output) : SV_TARGET
            {
                float2 mainTex_uv = TRANSFORM_TEX(output.uv, _MainTex);
                float2 secondTex_uv = TRANSFORM_TEX(output.uv, _SecondaryTex);
                float2 blendTex_uv = TRANSFORM_TEX(output.uv, _BlendTex);
                
                fixed4 mainColor = tex2D(_MainTex, mainTex_uv);
                fixed4 secondColor = tex2D(_SecondaryTex, secondTex_uv); 
                fixed4 blendColor = tex2D(_BlendTex, blendTex_uv); 
                
                return lerp(mainColor, secondColor, blendColor.r);
            }
            
            ENDCG
        }
    }
    
    FallBack "Standard"
}
