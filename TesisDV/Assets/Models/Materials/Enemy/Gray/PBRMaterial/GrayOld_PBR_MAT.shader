// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "GrayOld_PBR_MAT"
{
	Properties
	{
		_Gray_Albedo("Gray_Albedo", 2D) = "white" {}
		_SpaceSuit_Albedo("SpaceSuit_Albedo", 2D) = "white" {}
		_AO_SpaceSuit("AO_SpaceSuit", 2D) = "white" {}
		_AO_Gray_Old("AO_Gray_Old", 2D) = "white" {}
		_AO_Amount("AO_Amount", Float) = 0
		_SpaceSuit_Normal("SpaceSuit_Normal", 2D) = "bump" {}
		_GrayOld_Normal("GrayOld_Normal", 2D) = "bump" {}
		_SpaceSuit_NormalAmount("SpaceSuit_NormalAmount", Float) = 0
		_SpaceSuit_Albedo_DISP("SpaceSuit_Albedo_DISP", 2D) = "white" {}
		_SpaceSuit_Albedo_SPEC("SpaceSuit_Albedo_SPEC", 2D) = "white" {}
		_SpaceSuit_Metallic_Amount("SpaceSuit_Metallic_Amount", Float) = 0
		_GrayOldEyes_NORM("GrayOldEyes_NORM", 2D) = "bump" {}
		_GrayOldEyes_DISP("GrayOldEyes_DISP", 2D) = "white" {}
		_EyesMetallic_Amount("EyesMetallic_Amount", Float) = 0
		_EyesNormal_Amount("EyesNormal_Amount", Float) = 0
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

		uniform sampler2D _GrayOld_Normal;
		uniform float4 _GrayOld_Normal_ST;
		uniform sampler2D _SpaceSuit_Normal;
		uniform float4 _SpaceSuit_Normal_ST;
		uniform float _SpaceSuit_NormalAmount;
		uniform sampler2D _Gray_Albedo;
		uniform float4 _Gray_Albedo_ST;
		uniform sampler2D _SpaceSuit_Albedo;
		uniform float4 _SpaceSuit_Albedo_ST;
		uniform sampler2D _SpaceSuit_Albedo_SPEC;
		uniform float4 _SpaceSuit_Albedo_SPEC_ST;
		uniform sampler2D _SpaceSuit_Albedo_DISP;
		uniform float4 _SpaceSuit_Albedo_DISP_ST;
		uniform sampler2D _GrayOldEyes_DISP;
		uniform float4 _GrayOldEyes_DISP_ST;
		uniform float _EyesMetallic_Amount;
		uniform sampler2D _GrayOldEyes_NORM;
		uniform float4 _GrayOldEyes_NORM_ST;
		uniform float _EyesNormal_Amount;
		uniform float _SpaceSuit_Metallic_Amount;
		uniform sampler2D _AO_Gray_Old;
		uniform float4 _AO_Gray_Old_ST;
		uniform sampler2D _AO_SpaceSuit;
		uniform float4 _AO_SpaceSuit_ST;
		uniform float _AO_Amount;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_GrayOld_Normal = i.uv_texcoord * _GrayOld_Normal_ST.xy + _GrayOld_Normal_ST.zw;
			float2 uv_SpaceSuit_Normal = i.uv_texcoord * _SpaceSuit_Normal_ST.xy + _SpaceSuit_Normal_ST.zw;
			o.Normal = ( UnpackNormal( tex2D( _GrayOld_Normal, uv_GrayOld_Normal ) ) + ( UnpackNormal( tex2D( _SpaceSuit_Normal, uv_SpaceSuit_Normal ) ) * _SpaceSuit_NormalAmount ) );
			float2 uv_Gray_Albedo = i.uv_texcoord * _Gray_Albedo_ST.xy + _Gray_Albedo_ST.zw;
			float2 uv_SpaceSuit_Albedo = i.uv_texcoord * _SpaceSuit_Albedo_ST.xy + _SpaceSuit_Albedo_ST.zw;
			o.Albedo = ( tex2D( _Gray_Albedo, uv_Gray_Albedo ) + tex2D( _SpaceSuit_Albedo, uv_SpaceSuit_Albedo ) ).rgb;
			float2 uv_SpaceSuit_Albedo_SPEC = i.uv_texcoord * _SpaceSuit_Albedo_SPEC_ST.xy + _SpaceSuit_Albedo_SPEC_ST.zw;
			float2 uv_SpaceSuit_Albedo_DISP = i.uv_texcoord * _SpaceSuit_Albedo_DISP_ST.xy + _SpaceSuit_Albedo_DISP_ST.zw;
			float2 uv_GrayOldEyes_DISP = i.uv_texcoord * _GrayOldEyes_DISP_ST.xy + _GrayOldEyes_DISP_ST.zw;
			float2 uv_GrayOldEyes_NORM = i.uv_texcoord * _GrayOldEyes_NORM_ST.xy + _GrayOldEyes_NORM_ST.zw;
			float4 temp_output_20_0 = ( ( ( tex2D( _SpaceSuit_Albedo_SPEC, uv_SpaceSuit_Albedo_SPEC ) * tex2D( _SpaceSuit_Albedo_DISP, uv_SpaceSuit_Albedo_DISP ) ) + ( ( tex2D( _GrayOldEyes_DISP, uv_GrayOldEyes_DISP ) * _EyesMetallic_Amount ) * float4( ( UnpackNormal( tex2D( _GrayOldEyes_NORM, uv_GrayOldEyes_NORM ) ) * _EyesNormal_Amount ) , 0.0 ) ) ) * _SpaceSuit_Metallic_Amount );
			o.Metallic = temp_output_20_0.r;
			o.Smoothness = temp_output_20_0.r;
			float2 uv_AO_Gray_Old = i.uv_texcoord * _AO_Gray_Old_ST.xy + _AO_Gray_Old_ST.zw;
			float2 uv_AO_SpaceSuit = i.uv_texcoord * _AO_SpaceSuit_ST.xy + _AO_SpaceSuit_ST.zw;
			o.Occlusion = ( ( tex2D( _AO_Gray_Old, uv_AO_Gray_Old ) + tex2D( _AO_SpaceSuit, uv_AO_SpaceSuit ) ) * _AO_Amount ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
362;488;1195;494;1586.29;979.3828;1.635579;True;False
Node;AmplifyShaderEditor.RangedFloatNode;35;-1981.844,1147.515;Inherit;False;Property;_EyesNormal_Amount;EyesNormal_Amount;14;0;Create;True;0;0;False;0;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-2064,752;Inherit;False;Property;_EyesMetallic_Amount;EyesMetallic_Amount;13;0;Create;True;0;0;False;0;0;0.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;28;-2208,480;Inherit;True;Property;_GrayOldEyes_DISP;GrayOldEyes_DISP;12;0;Create;True;0;0;False;0;-1;222b6bd1d454f22479d5ddbff405664a;222b6bd1d454f22479d5ddbff405664a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;22;-2072.498,882.3725;Inherit;True;Property;_GrayOldEyes_NORM;GrayOldEyes_NORM;11;0;Create;True;0;0;False;0;-1;d74555a0eff2ee940bd55d3c424daaf0;d74555a0eff2ee940bd55d3c424daaf0;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;16;-2064,0;Inherit;True;Property;_SpaceSuit_Albedo_SPEC;SpaceSuit_Albedo_SPEC;9;0;Create;True;0;0;False;0;-1;3ee7e0378c7744545986aef34f9fc98a;3ee7e0378c7744545986aef34f9fc98a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;15;-2048,208;Inherit;True;Property;_SpaceSuit_Albedo_DISP;SpaceSuit_Albedo_DISP;8;0;Create;True;0;0;False;0;-1;c4890cea4e662484bae8ec77deb86682;c4890cea4e662484bae8ec77deb86682;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-1676.219,871.5635;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-1824,464;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;5;-1301.059,1315.219;Inherit;True;Property;_AO_SpaceSuit;AO_SpaceSuit;2;0;Create;True;0;0;False;0;-1;None;349672fb5d8d85a4796c21582c2e0fee;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;6;-1262.042,1078.644;Inherit;True;Property;_AO_Gray_Old;AO_Gray_Old;3;0;Create;True;0;0;False;0;-1;None;2ff5724d7732d3642ade6cbe019c8fd3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-1680,80;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-2002.674,-181.572;Inherit;False;Property;_SpaceSuit_NormalAmount;SpaceSuit_NormalAmount;7;0;Create;True;0;0;False;0;0;-0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;10;-2088.374,-415.6765;Inherit;True;Property;_SpaceSuit_Normal;SpaceSuit_Normal;5;0;Create;True;0;0;False;0;-1;None;befada114f952fb4ca37ea3cd0efbee7;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-1488,528;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-1008.466,-591.1769;Inherit;True;Property;_SpaceSuit_Albedo;SpaceSuit_Albedo;1;0;Create;True;0;0;False;0;-1;None;e065f6f3d761b3b45940dc52835e50e8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;11;-1880.839,-630.6343;Inherit;True;Property;_GrayOld_Normal;GrayOld_Normal;6;0;Create;True;0;0;False;0;-1;None;66a2bf118f5d418429061f0faeb0fae0;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-906.3726,1182.218;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-929.8231,1401.091;Inherit;False;Property;_AO_Amount;AO_Amount;4;0;Create;True;0;0;False;0;0;0.74;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-1736.914,-369.5863;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1008,368;Inherit;False;Property;_SpaceSuit_Metallic_Amount;SpaceSuit_Metallic_Amount;10;0;Create;True;0;0;False;0;0;2.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-1072,112;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-979.5664,-823.2692;Inherit;True;Property;_Gray_Albedo;Gray_Albedo;0;0;Create;True;0;0;False;0;-1;None;55d559a5c7bebba4ab7715b8e9276180;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-1487.796,-511.4266;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-726.5836,1145.088;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-704,128;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;4;-447.6023,-811.4877;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;GrayOld_PBR_MAT;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;34;0;22;0
WireConnection;34;1;35;0
WireConnection;32;0;28;0
WireConnection;32;1;33;0
WireConnection;17;0;16;0
WireConnection;17;1;15;0
WireConnection;36;0;32;0
WireConnection;36;1;34;0
WireConnection;7;0;6;0
WireConnection;7;1;5;0
WireConnection;13;0;10;0
WireConnection;13;1;14;0
WireConnection;29;0;17;0
WireConnection;29;1;36;0
WireConnection;12;0;11;0
WireConnection;12;1;13;0
WireConnection;8;0;7;0
WireConnection;8;1;9;0
WireConnection;20;0;29;0
WireConnection;20;1;19;0
WireConnection;4;0;1;0
WireConnection;4;1;2;0
WireConnection;0;0;4;0
WireConnection;0;1;12;0
WireConnection;0;3;20;0
WireConnection;0;4;20;0
WireConnection;0;5;8;0
ASEEND*/
//CHKSM=522FA2F74A04BF87C6905A691F7597DF7E92622D