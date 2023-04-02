Shader "Custom/TriplanarMapping"
{
    Properties
    {
        _Color("MainColor", Color) = (0,0,0,1)
        _MainTex("MainTexture", 2D) = "white" {} 
        _Sharpness("Blend Sharpness", Range(1, 64)) = 1
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
            
            
            fixed4 _Color;
            
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            float _Sharpness;
            
            
            struct InputData
            {
                float4 vertexPosition : POSITION;
                float3 normal : NORMAL;
            };
            
            
            struct OutputData
            {
                float4 vertexPosition : SV_POSITION;
                float3 normal : NORMAL;
                float3 worldVertexPosition : TEXCOORD1;
                float2 uv : TEXCOORD0;
            };
            
            
            OutputData vert(InputData input)
            {
                OutputData output;
                
                output.vertexPosition = UnityObjectToClipPos(input.vertexPosition);
                output.worldVertexPosition = mul(unity_ObjectToWorld, output.vertexPosition).xyz;
                
                float3 worldNormal = mul(input.normal, (float3x3)unity_WorldToObject);
                output.normal = normalize(worldNormal);
                
                return output;
            }
            
            
            fixed4 frag(OutputData output) : SV_TARGET
            {
                float2 uv_front = TRANSFORM_TEX(output.worldVertexPosition.xy, _MainTex);
                float2 uv_side = TRANSFORM_TEX(output.worldVertexPosition.zy, _MainTex);
                float2 uv_top = TRANSFORM_TEX(output.worldVertexPosition.xz, _MainTex);
                
                float3 weights = abs(output.normal);
                weights = weights / (weights.x + weights.y + weights.z);
                weights = pow(weights, _Sharpness);
                
                fixed4 col_front = tex2D(_MainTex, uv_front) * weights.z;
                fixed4 col_side = tex2D(_MainTex, uv_side) * weights.x;
                fixed4 col_top = tex2D(_MainTex, uv_top) * weights.y;
                
                fixed4 col = col_front + col_side + col_top;
                col *= _Color;
    
                return col;
            }
            
            ENDCG
        }
    }
    
    FallBack "Diffuse"
}
