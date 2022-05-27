// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DamagePlayer"
{
	Properties
	{
		_Intensity("Intensity", Range( 0 , 1)) = 0
		_NormalDistortion("NormalDistortion", 2D) = "bump" {}
		_Distortion("Distortion", Float) = 0.88
		_DamageTint("DamageTint", Color) = (1,0.06132078,0.06132078,0)
		_DamageTexture("DamageTexture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Cull Off
		ZWrite Off
		ZTest Always
		
		Pass
		{
			CGPROGRAM

			

			#pragma vertex Vert
			#pragma fragment Frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			#include "UnityStandardUtils.cginc"
			#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED

		
			struct ASEAttributesDefault
			{
				float3 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				
			};

			struct ASEVaryingsDefault
			{
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				float2 texcoordStereo : TEXCOORD1;
			#if STEREO_INSTANCING_ENABLED
				uint stereoTargetEyeIndex : SV_RenderTargetArrayIndex;
			#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float _Distortion;
			uniform sampler2D _NormalDistortion;
			uniform float4 _NormalDistortion_ST;
			uniform float4 _DamageTint;
			uniform sampler2D _DamageTexture;
			uniform float4 _DamageTexture_ST;
			uniform float _Intensity;


			
			float2 TransformTriangleVertexToUV (float2 vertex)
			{
				float2 uv = (vertex + 1.0) * 0.5;
				return uv;
			}

			ASEVaryingsDefault Vert( ASEAttributesDefault v  )
			{
				ASEVaryingsDefault o;
				o.vertex = float4(v.vertex.xy, 0.0, 1.0);
				o.texcoord = TransformTriangleVertexToUV (v.vertex.xy);
#if UNITY_UV_STARTS_AT_TOP
				o.texcoord = o.texcoord * float2(1.0, -1.0) + float2(0.0, 1.0);
#endif
				o.texcoordStereo = TransformStereoScreenSpaceTex (o.texcoord, 1.0);

				v.texcoord = o.texcoordStereo;
				float4 ase_ppsScreenPosVertexNorm = float4(o.texcoordStereo,0,1);

				

				return o;
			}

			float4 Frag (ASEVaryingsDefault i  ) : SV_Target
			{
				float4 ase_ppsScreenPosFragNorm = float4(i.texcoordStereo,0,1);

				float2 uv_NormalDistortion = i.texcoord.xy * _NormalDistortion_ST.xy + _NormalDistortion_ST.zw;
				float4 tex2DNode3 = tex2D( _MainTex, ( ase_ppsScreenPosFragNorm + float4( UnpackScaleNormal( tex2D( _NormalDistortion, uv_NormalDistortion ), _Distortion ) , 0.0 ) ).xy );
				float2 uv_DamageTexture = i.texcoord.xy * _DamageTexture_ST.xy + _DamageTexture_ST.zw;
				float4 lerpResult23 = lerp( tex2DNode3 , ( tex2DNode3 * _DamageTint * tex2D( _DamageTexture, uv_DamageTexture ) ) , _Intensity);
				

				float4 color = lerpResult23;
				
				return color;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17800
94;221;1307;537;1366.287;346.6779;1.597011;True;False
Node;AmplifyShaderEditor.RangedFloatNode;20;-1239.679,230.7406;Inherit;False;Property;_Distortion;Distortion;2;0;Create;True;0;0;False;0;0.88;0.88;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;9;-865.0573,-103.3479;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;15;-946.2449,165.9783;Inherit;True;Property;_NormalDistortion;NormalDistortion;1;0;Create;True;0;0;False;0;-1;9e8d0545d8103314f84f30035a0825c2;9e8d0545d8103314f84f30035a0825c2;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;1;-615.6262,-158.5578;Inherit;False;0;0;_MainTex;Pass;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-613.8806,-35.12013;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;14;-325.4468,87.20759;Inherit;False;Property;_DamageTint;DamageTint;3;0;Create;True;0;0;False;0;1,0.06132078,0.06132078,0;1,0.06132078,0.06132078,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-328.6972,-161.3363;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;-1;39254807ac63ccf408c845b18ba7b08d;39254807ac63ccf408c845b18ba7b08d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;22;-371.1104,318.2715;Inherit;True;Property;_DamageTexture;DamageTexture;4;0;Create;True;0;0;False;0;-1;39254807ac63ccf408c845b18ba7b08d;39254807ac63ccf408c845b18ba7b08d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;13;74.01643,319.4621;Inherit;False;Property;_Intensity;Intensity;0;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;27.18513,-26.5957;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;23;304.1919,-91.80038;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;562.0831,-111.274;Float;False;True;-1;2;ASEMaterialInspector;0;9;DamagePlayer;6ee3f8b6a5b82cb45858d55fcbadce45;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;True;2;False;-1;False;False;True;2;False;-1;True;7;False;-1;False;False;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;0
WireConnection;15;5;20;0
WireConnection;11;0;9;0
WireConnection;11;1;15;0
WireConnection;3;0;1;0
WireConnection;3;1;11;0
WireConnection;16;0;3;0
WireConnection;16;1;14;0
WireConnection;16;2;22;0
WireConnection;23;0;3;0
WireConnection;23;1;16;0
WireConnection;23;2;13;0
WireConnection;0;0;23;0
ASEEND*/
//CHKSM=D3088CF76B4641ACE7911C247C0194154384CBF6