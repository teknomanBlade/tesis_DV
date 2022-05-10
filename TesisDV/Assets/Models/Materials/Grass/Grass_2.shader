// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Grass_2"
{
	Properties
	{
		_MainTex("_MainTex", 2D) = "white" {}
		_TextureGrass2_Albedo_AO("TextureGrass2_Albedo_AO", 2D) = "white" {}
		_TextureGrass2_Albedo_NORM("TextureGrass2_Albedo_NORM", 2D) = "bump" {}
		_TextureGrass2_Albedo_SPEC("TextureGrass2_Albedo_SPEC", 2D) = "white" {}
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

		uniform sampler2D _TextureGrass2_Albedo_NORM;
		uniform float4 _TextureGrass2_Albedo_NORM_ST;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _SaturateValue;
		uniform sampler2D _TextureGrass2_Albedo_SPEC;
		uniform float4 _TextureGrass2_Albedo_SPEC_ST;
		uniform sampler2D _TextureGrass2_Albedo_AO;
		uniform float4 _TextureGrass2_Albedo_AO_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_TextureGrass2_Albedo_NORM = i.uv_texcoord * _TextureGrass2_Albedo_NORM_ST.xy + _TextureGrass2_Albedo_NORM_ST.zw;
			o.Normal = UnpackNormal( tex2D( _TextureGrass2_Albedo_NORM, uv_TextureGrass2_Albedo_NORM ) );
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode4 = tex2D( _MainTex, uv_MainTex );
			o.Albedo = ( tex2DNode4 * saturate( tex2DNode4 ) * _SaturateValue ).rgb;
			float2 uv_TextureGrass2_Albedo_SPEC = i.uv_texcoord * _TextureGrass2_Albedo_SPEC_ST.xy + _TextureGrass2_Albedo_SPEC_ST.zw;
			o.Smoothness = tex2D( _TextureGrass2_Albedo_SPEC, uv_TextureGrass2_Albedo_SPEC ).r;
			float2 uv_TextureGrass2_Albedo_AO = i.uv_texcoord * _TextureGrass2_Albedo_AO_ST.xy + _TextureGrass2_Albedo_AO_ST.zw;
			o.Occlusion = tex2D( _TextureGrass2_Albedo_AO, uv_TextureGrass2_Albedo_AO ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
468;230;1307;573;1533.754;560.3963;2.35782;True;False
Node;AmplifyShaderEditor.SamplerNode;4;-693.4671,-234.0331;Inherit;True;Property;_MainTex;_MainTex;0;0;Create;True;0;0;False;0;-1;d7daa549577361e45847a77d9d2e0999;d7daa549577361e45847a77d9d2e0999;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;8;-359.5594,-147.7777;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-343.0547,-32.2448;Inherit;False;Property;_SaturateValue;SaturateValue;4;0;Create;True;0;0;False;0;0.32;0.32;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-516.7132,73.33414;Inherit;True;Property;_TextureGrass2_Albedo_AO;TextureGrass2_Albedo_AO;1;0;Create;True;0;0;False;0;-1;627b9493270b88e4f8d56549aa9c19ec;627b9493270b88e4f8d56549aa9c19ec;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;6;-529.008,355.8216;Inherit;True;Property;_TextureGrass2_Albedo_NORM;TextureGrass2_Albedo_NORM;2;0;Create;True;0;0;False;0;-1;7a8ed473fb3dff042aa9718d016a737e;7a8ed473fb3dff042aa9718d016a737e;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-501.4424,578.9063;Inherit;True;Property;_TextureGrass2_Albedo_SPEC;TextureGrass2_Albedo_SPEC;3;0;Create;True;0;0;False;0;-1;bf5fd7d3ffcb92f48af6be4e6208c804;bf5fd7d3ffcb92f48af6be4e6208c804;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-185.0808,-286.8891;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;3;282.8554,-39.18248;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Grass_2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;8;0;4;0
WireConnection;9;0;4;0
WireConnection;9;1;8;0
WireConnection;9;2;10;0
WireConnection;3;0;9;0
WireConnection;3;1;6;0
WireConnection;3;4;7;0
WireConnection;3;5;5;0
ASEEND*/
//CHKSM=85A20A9958B08EEB9DE20BC4FE52B1E92B6721BE