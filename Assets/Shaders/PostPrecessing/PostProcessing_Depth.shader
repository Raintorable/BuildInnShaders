Shader "Custom/PostProcessing_Depth"
{
    //show values to edit in inspector
    Properties
    {
        [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
        
        [Header(Wave)]
        _WaveTrail ("Length of the trail", Range(0,5)) = 1
        _WaveColor ("Color", Color) = (1,0,0,1)
        _WaveNormalizedDistance ("_Wave Normalized Distance", Range(0, 1)) = 0.5
    }

    SubShader
        {
        Cull Off
        ZWrite Off
        ZTest Always

        Pass
            {
            CGPROGRAM
            #include "UnityCG.cginc"
            
            #pragma vertex vert
            #pragma fragment frag
            
            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;

            float _WaveDistance;
            float _WaveTrail;
            float _WaveNormalizedDistance;
            float4 _WaveColor;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            v2f vert(appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed4 sourceColor = tex2D(_MainTex, i.uv);
                
                float depthValue = tex2D(_CameraDepthTexture, i.uv).r;
                depthValue = Linear01Depth(depthValue);
                depthValue = depthValue * _ProjectionParams.z;

                float waveDistance = lerp(_ProjectionParams.y, _ProjectionParams.z - 1, _WaveNormalizedDistance);
                float waveFront = step(depthValue, waveDistance);
                float waveTrail = smoothstep(waveDistance - _WaveTrail, waveDistance + _WaveTrail, depthValue);
                float wave = waveFront * waveTrail;

                fixed4 col = lerp(sourceColor, _WaveColor, wave);

                return col;
            }

            ENDCG
        }
    }
}
