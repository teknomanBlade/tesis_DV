// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Grass_3"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_TextureGrass3_Albedo_AO("TextureGrass3_Albedo_AO", 2D) = "white" {}
		_TextureGrass3_Albedo_NORM("TextureGrass3_Albedo_NORM", 2D) = "bump" {}
		_TextureGrass3_Albedo_SPEC("TextureGrass3_Albedo_SPEC", 2D) = "white" {}
		_SaturateValue("SaturateValue", Float) = 0.32
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

		uniform sampler2D _TextureGrass3_Albedo_NORM;
		uniform float4 _TextureGrass3_Albedo_NORM_ST;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _SaturateValue;
		uniform sampler2D _TextureGrass3_Albedo_SPEC;
		uniform float4 _TextureGrass3_Albedo_SPEC_ST;
		uniform sampler2D _TextureGrass3_Albedo_AO;
		uniform float4 _TextureGrass3_Albedo_AO_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_TextureGrass3_Albedo_NORM = i.uv_texcoord * _TextureGrass3_Albedo_NORM_ST.xy + _TextureGrass3_Albedo_NORM_ST.zw;
			o.Normal = UnpackNormal( tex2D( _TextureGrass3_Albedo_NORM, uv_TextureGrass3_Albedo_NORM ) );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			o.Albedo = ( tex2DNode1 * saturate( tex2DNode1 ) * _SaturateValue ).rgb;
			float2 uv_TextureGrass3_Albedo_SPEC = i.uv_texcoord * _TextureGrass3_Albedo_SPEC_ST.xy + _TextureGrass3_Albedo_SPEC_ST.zw;
			o.Smoothness = tex2D( _TextureGrass3_Albedo_SPEC, uv_TextureGrass3_Albedo_SPEC ).r;
			float2 uv_TextureGrass3_Albedo_AO = i.uv_texcoord * _TextureGrass3_Albedo_AO_ST.xy + _TextureGrass3_Albedo_AO_ST.zw;
			o.Occlusion = tex2D( _TextureGrass3_Albedo_AO, uv_TextureGrass3_Albedo_AO ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
468;230;1307;573;825.318;510.229;1.259697;True;False
Node;AmplifyShaderEditor.SamplerNode;1;-562.8318,-291.8385;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;False;0;-1;02efa2c86bd7a99418a4148f7183bca9;02efa2c86bd7a99418a4148f7183bca9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;6;-206.2085,-223.7511;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-166.2159,-66.26701;Inherit;False;Property;_SaturateValue;SaturateValue;4;0;Create;True;0;0;False;0;0.32;0.32;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-314.2195,339.0314;Inherit;True;Property;_TextureGrass3_Albedo_NORM;TextureGrass3_Albedo_NORM;2;0;Create;True;0;0;False;0;-1;a38300f72d336b94a8d525758e442653;a38300f72d336b94a8d525758e442653;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-262.9573,574.7989;Inherit;True;Property;_TextureGrass3_Albedo_SPEC;TextureGrass3_Albedo_SPEC;3;0;Create;True;0;0;False;0;-1;07bece4689e33a044910183fe28ac1b9;07bece4689e33a044910183fe28ac1b9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-8.479864,-370.0073;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-345.4778,73.80628;Inherit;True;Property;_TextureGrass3_Albedo_AO;TextureGrass3_Albedo_AO;1;0;Create;True;0;0;False;0;-1;3bb91f11717a9ca47a21789f9bd306a5;3bb91f11717a9ca47a21789f9bd306a5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;370.059,-207.2177;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Grass_3;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;1;0
WireConnection;5;0;1;0
WireConnection;5;1;6;0
WireConnection;5;2;7;0
WireConnection;0;0;5;0
WireConnection;0;1;3;0
WireConnection;0;4;4;0
WireConnection;0;5;2;0
ASEEND*/
//CHKSM=78124CCBA4D6C4EFE4A1F04495950FE7D05F10DC