// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Grass_1"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_AO("AO", 2D) = "white" {}
		_TextureGrass1_Albedo_DISP("TextureGrass1_Albedo_DISP", 2D) = "white" {}
		_SaturationValue("Saturation Value", Float) = 0.32
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _SaturationValue;
		uniform sampler2D _TextureGrass1_Albedo_DISP;
		uniform float4 _TextureGrass1_Albedo_DISP_ST;
		uniform sampler2D _AO;
		uniform float4 _AO_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			o.Albedo = ( tex2DNode1 * saturate( tex2DNode1 ) * _SaturationValue ).rgb;
			float2 uv_TextureGrass1_Albedo_DISP = i.uv_texcoord * _TextureGrass1_Albedo_DISP_ST.xy + _TextureGrass1_Albedo_DISP_ST.zw;
			o.Metallic = ( tex2D( _TextureGrass1_Albedo_DISP, uv_TextureGrass1_Albedo_DISP ) * _SaturationValue ).r;
			float2 uv_AO = i.uv_texcoord * _AO_ST.xy + _AO_ST.zw;
			o.Occlusion = tex2D( _AO, uv_AO ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
468;230;1307;573;1362.092;533.3529;1.282606;True;False
Node;AmplifyShaderEditor.SamplerNode;1;-894.697,-455.0531;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;False;0;-1;fba7886fe65ee4842a4036db6755936f;fba7886fe65ee4842a4036db6755936f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;11;-553.7571,-185.1665;Inherit;False;Property;_SaturationValue;Saturation Value;4;0;Create;True;0;0;False;0;0.32;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-630.5969,427.7712;Inherit;True;Property;_TextureGrass1_Albedo_DISP;TextureGrass1_Albedo_DISP;3;0;Create;True;0;0;False;0;-1;e1dbb13618a05634d97d44661c5cc53d;e1dbb13618a05634d97d44661c5cc53d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;5;-542.6048,-406.1126;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-270.2137,-528.5528;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-236.3713,130.7815;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;3;-811.0494,195.3893;Inherit;True;Property;_AO;AO;2;0;Create;True;0;0;False;0;-1;a8bb10caabaaab74fae11eca1d3a6d37;a8bb10caabaaab74fae11eca1d3a6d37;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-813.7291,-63.07745;Inherit;True;Property;_Normal;Normal;1;0;Create;True;0;0;False;0;-1;b5e4f94b9ddcaeb4ab87484b8fa1018d;b5e4f94b9ddcaeb4ab87484b8fa1018d;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;98.14526,-207;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Grass_1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;0;1;0
WireConnection;7;0;1;0
WireConnection;7;1;5;0
WireConnection;7;2;11;0
WireConnection;12;0;4;0
WireConnection;12;1;11;0
WireConnection;0;0;7;0
WireConnection;0;1;2;0
WireConnection;0;3;12;0
WireConnection;0;5;3;0
ASEEND*/
//CHKSM=C2E69B4063ABA204ABD56DF5BCB1325E2644F1CF