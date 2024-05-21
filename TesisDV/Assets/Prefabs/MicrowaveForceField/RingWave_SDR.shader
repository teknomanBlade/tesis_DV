// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "RingWave_SDR"
{
	Properties
	{
		_TarStainTexture("TarStainTexture", 2D) = "white" {}
		_OpacityLevel("OpacityLevel", Range( 0 , 1)) = 0
		_PoisonTarTexture("PoisonTarTexture", 2D) = "white" {}
		_TarUpgradeTransition("TarUpgradeTransition", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha noshadow 
		struct Input
		{
			float2 uv_texcoord;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _TarStainTexture;
		uniform float4 _TarStainTexture_ST;
		uniform sampler2D _PoisonTarTexture;
		uniform float4 _PoisonTarTexture_ST;
		uniform float _TarUpgradeTransition;
		uniform float _OpacityLevel;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_TarStainTexture = i.uv_texcoord * _TarStainTexture_ST.xy + _TarStainTexture_ST.zw;
			float4 tex2DNode1 = tex2D( _TarStainTexture, uv_TarStainTexture );
			c.rgb = 0;
			c.a = ( tex2DNode1.a * _OpacityLevel );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float2 uv_TarStainTexture = i.uv_texcoord * _TarStainTexture_ST.xy + _TarStainTexture_ST.zw;
			float4 tex2DNode1 = tex2D( _TarStainTexture, uv_TarStainTexture );
			float2 uv_PoisonTarTexture = i.uv_texcoord * _PoisonTarTexture_ST.xy + _PoisonTarTexture_ST.zw;
			float4 lerpResult13 = lerp( tex2DNode1 , tex2D( _PoisonTarTexture, uv_PoisonTarTexture ) , _TarUpgradeTransition);
			o.Albedo = lerpResult13.rgb;
			o.Emission = lerpResult13.rgb;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
587;500;1195;562;1123.228;442.0629;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;9;-607.2993,-40.63417;Inherit;False;Property;_OpacityLevel;OpacityLevel;1;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;12;-847.7104,-533.7044;Inherit;True;Property;_PoisonTarTexture;PoisonTarTexture;2;0;Create;True;0;0;False;0;-1;None;9f6bc153acfc9ef44837b8f634a4309e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-898.2193,-790.0143;Inherit;True;Property;_TarStainTexture;TarStainTexture;0;0;Create;True;0;0;False;0;-1;f24f3de37ffd16b408fa050bf5383d1b;02817b9829ce2a840a6a96d80ecf2caa;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;14;-717.0685,-197.4503;Inherit;False;Property;_TarUpgradeTransition;TarUpgradeTransition;3;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-262.1692,-177.8544;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;13;-368.6989,-600.2209;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;137.8619,-375.008;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;RingWave_SDR;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;11;0;1;4
WireConnection;11;1;9;0
WireConnection;13;0;1;0
WireConnection;13;1;12;0
WireConnection;13;2;14;0
WireConnection;0;0;13;0
WireConnection;0;2;13;0
WireConnection;0;9;11;0
ASEEND*/
//CHKSM=8566251481A43F35E3A87FF9129BE81DDDA20550