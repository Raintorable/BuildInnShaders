// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Monkey" 
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_SplashTex("Splash", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		_SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
		
	}

	SubShader
	{
		Pass
		{
			Lighting On
			Tags {

				"Queue" = "Geometry"
				"RenderMode" = "Opaque"
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"

			#define M_PI 3.14159 // 3.1415926535897932384626433832795

			// user uniforms
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _SplashTex;

			uniform int _Points_Length;
			uniform half3 _Points[20]; 
			uniform fixed4 _Colors[20];
			uniform half _Radiuses[20];
			uniform half _RadiusesSplash[20];

			UNITY_INSTANCING_BUFFER_START(Props)
				UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)
			UNITY_INSTANCING_BUFFER_END(Props)

			uniform fixed4 _SpecularColor;

			// structs
			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				half2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct vertexOutput {
				float4 pos : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				float3 normalWorld : TEXCOORD1;
				float3 posWorld : TEXCOORD2;
				float3 objectOrigin : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID // necessary only if you want to access instanced properties in fragment Shader.
			};

			vertexOutput vert(vertexInput i)
			{
				vertexOutput o;

				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_TRANSFER_INSTANCE_ID(i, o); // necessary only if you want to access instanced properties in the fragment Shader.

				o.pos = UnityObjectToClipPos(i.vertex);
				o.texcoord = i.texcoord;
				o.normalWorld = normalize(mul(float4(i.normal, 0), unity_WorldToObject).xyz);
				o.posWorld = mul(unity_ObjectToWorld, i.vertex);
				o.objectOrigin = mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0)).xyz;

				return o;
			}

			fixed4 frag(vertexOutput o) : COLOR
			{
				UNITY_SETUP_INSTANCE_ID(o); // necessary only if any instanced properties are going to be accessed in the fragment Shader.

				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - o.posWorld);

				fixed4 texColor = tex2D(_MainTex, o.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);

				fixed4 color = _Color;

				fixed splashAngleCoeff = 1.0 / 90.0;

				[unroll(20)]
				for (int i = _Points_Length - 1; i >= 0; i--)
				{
					half di = distance(o.posWorld, _Points[i]);

					//if (dot(o.normalWorld, _Points[i] - o.posWorld) > 0)
					//{
					if (di < _Radiuses[i])
					{
						color = _Colors[i];
						break;
					}
					else if (di < _RadiusesSplash[i])
					{
						// matrix "world to local for painter"
						fixed3 toObjectOriginNormalize = normalize(o.objectOrigin - _Points[i]);
						fixed3 toRightNormalize = fixed3(toObjectOriginNormalize.z, 0, -toObjectOriginNormalize.x);
						fixed3 toUpNormalize = normalize(cross(toObjectOriginNormalize, toRightNormalize));
						fixed3x3 worldToPainterLocalMatrix = fixed3x3(
							toRightNormalize,
							toUpNormalize,
							toObjectOriginNormalize
						);

						half3 pointToPainterLocalVector = mul(worldToPainterLocalMatrix, _Points[i] - o.posWorld);

						float angle = degrees(atan(pointToPainterLocalVector.y / pointToPainterLocalVector.x)) + 180.0;

						fixed2 uv = float2(
							angle / 360.0,
							(distance(o.posWorld, _Points[i]) - _Radiuses[i]) / (_RadiusesSplash[i] - _Radiuses[i])
						);
						fixed4 texSplashColor = tex2D(
							_SplashTex, 
							uv
						);

						if (texSplashColor.r > 0)
						{
							color = _Colors[i];
							break;
						}
					}
					//}
				}

				fixed3 diffuseColor = UNITY_ACCESS_INSTANCED_PROP(Props, color).rgb * texColor.rgb * unity_LightColor[0].rgb * max(0.2, dot(o.normalWorld, lightDirection));
				fixed4 finalColor = fixed4(diffuseColor + UNITY_LIGHTMODEL_AMBIENT, 1);


				return finalColor;
			}

			ENDCG
		}
	}
}