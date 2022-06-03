// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AttentionPlayer"
{
	Properties
	{
		_AttentionTexture("AttentionTexture", 2D) = "white" {}
		_Interpolator("Interpolator", Range( 0 , 1)) = 0
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
			
			uniform sampler2D _AttentionTexture;
			uniform float4 _AttentionTexture_ST;
			uniform float _Interpolator;


			
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

				float2 uv_MainTex = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode2 = tex2D( _MainTex, uv_MainTex );
				float2 uv_AttentionTexture = i.texcoord.xy * _AttentionTexture_ST.xy + _AttentionTexture_ST.zw;
				float4 lerpResult14 = lerp( tex2DNode2 , ( tex2DNode2 + tex2D( _AttentionTexture, uv_AttentionTexture ) ) , _Interpolator);
				

				float4 color = lerpResult14;
				
				return color;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17800
94;221;1307;537;1776.088;257.9872;1.446281;True;False
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;1;-1296.654,-10.90797;Inherit;False;0;0;_MainTex;Pass;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-1188.266,244.4927;Inherit;True;Property;_AttentionTexture;AttentionTexture;0;0;Create;True;0;0;False;0;-1;cba425400b863044aa9f32b5dfdd600c;39254807ac63ccf408c845b18ba7b08d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-1128.04,-65.85216;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;-1;39254807ac63ccf408c845b18ba7b08d;39254807ac63ccf408c845b18ba7b08d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-734.7654,113.707;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-743.1583,384.985;Inherit;False;Property;_Interpolator;Interpolator;1;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;14;-403.5671,5.235984;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-108.2694,-50.64215;Float;False;True;-1;2;ASEMaterialInspector;0;9;AttentionPlayer;6ee3f8b6a5b82cb45858d55fcbadce45;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;True;2;False;-1;False;False;True;2;False;-1;True;7;False;-1;False;False;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;0
WireConnection;2;0;1;0
WireConnection;13;0;2;0
WireConnection;13;1;4;0
WireConnection;14;0;2;0
WireConnection;14;1;13;0
WireConnection;14;2;10;0
WireConnection;0;0;14;0
ASEEND*/
//CHKSM=FFC292DCF1AA86852F636B7E7D8FE86E6E87C099