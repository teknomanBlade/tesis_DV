// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BaseballMachineRadius"
{
	Properties
	{
		_Scale("Scale", Range( 0 , 1)) = 1
		_Power("Power", Float) = 8.39
		_Bias("Bias", Range( 0 , 1)) = 1
		_Speed("Speed", Vector) = (0.4,0,0,0)
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard alpha:fade keepalpha noshadow 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 viewDir;
			float3 worldNormal;
		};

		uniform sampler2D _TextureSample0;
		uniform float2 _Speed;
		uniform float _Bias;
		uniform float _Scale;
		uniform float _Power;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 color5 = IsGammaSpace() ? float4(1,0.9561809,0,0) : float4(1,0.9031989,0,0);
			o.Emission = color5.rgb;
			float2 uv_TexCoord11 = i.uv_texcoord * float2( 25,25 ) + float2( 1,1 );
			float2 panner13 = ( 1.74 * _Time.y * _Speed + uv_TexCoord11);
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV7 = dot( ase_worldNormal, i.viewDir );
			float fresnelNode7 = ( _Bias + _Scale * pow( 1.0 - fresnelNdotV7, _Power ) );
			o.Alpha = saturate( ( tex2D( _TextureSample0, panner13 ) * fresnelNode7 ) ).r;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
112;161;1137;535;2310.464;735.7375;2.212145;True;False
Node;AmplifyShaderEditor.Vector2Node;12;-2183.469,-457.0682;Inherit;False;Property;_Speed;Speed;3;0;Create;True;0;0;False;0;0.4,0;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-2317.719,-716.3986;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;25,25;False;1;FLOAT2;1,1;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1;-1932.707,-45.5976;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;2;-2085.408,128.9297;Inherit;False;Property;_Bias;Bias;2;0;Create;True;0;0;False;0;1;0.234;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-2039.984,248.1919;Inherit;False;Property;_Scale;Scale;0;0;Create;True;0;0;False;0;1;0.161;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1818.07,394.0091;Inherit;False;Property;_Power;Power;1;0;Create;True;0;0;False;0;8.39;5.93;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;13;-1969.523,-609.9042;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1.74;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;7;-1536.468,39.44888;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;2;False;2;FLOAT;2.75;False;3;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;-1706.334,-373.5631;Inherit;True;Property;_TextureSample0;Texture Sample 0;4;0;Create;True;0;0;False;0;-1;None;c40bf1abcabbaae40a245fd48d9a6750;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-953.0433,-168.1033;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;5;-556.2291,-367.3866;Inherit;False;Constant;_Color0;Color 0;4;0;Create;True;0;0;False;0;1,0.9561809,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;8;-627.3653,-156.103;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;16,-148;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;BaseballMachineRadius;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;0;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;13;0;11;0
WireConnection;13;2;12;0
WireConnection;7;4;1;0
WireConnection;7;1;2;0
WireConnection;7;2;3;0
WireConnection;7;3;4;0
WireConnection;14;1;13;0
WireConnection;10;0;14;0
WireConnection;10;1;7;0
WireConnection;8;0;10;0
WireConnection;0;2;5;0
WireConnection;0;9;8;0
ASEEND*/
//CHKSM=26919802B1B082C14A6B8044BAC11A7E5296FFB6