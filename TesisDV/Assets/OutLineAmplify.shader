// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "OutLineAmplify"
{
	Properties
	{
		_OutLineColor("OutLineColor", Color) = (0,0,0,0)
		_OutlineWidth("OutlineWidth", Range( 0 , 1)) = 0
		_OutLineAlpha("OutLineAlpha", Range( 0 , 1)) = 0
		_Normal("Normal", 2D) = "bump" {}
		_AO("AO", 2D) = "white" {}
		_Albedo("Albedo", 2D) = "white" {}
		_Metallic("Metallic", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0"}
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog alpha:fade  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		
		
		
		struct Input
		{
			half filler;
		};
		uniform float _OutlineWidth;
		uniform float4 _OutLineColor;
		uniform float _OutLineAlpha;
		
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float outlineVar = _OutlineWidth;
			v.vertex.xyz *= ( 1 + outlineVar);
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = _OutLineColor.rgb;
			o.Alpha = _OutLineAlpha;
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Off
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _Albedo;
		uniform sampler2D _Metallic;
		uniform float4 _Metallic_ST;
		uniform sampler2D _AO;
		uniform float4 _AO_ST;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += 0;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			o.Albedo = tex2D( _Albedo, i.uv_texcoord ).rgb;
			float2 uv_Metallic = i.uv_texcoord * _Metallic_ST.xy + _Metallic_ST.zw;
			float4 tex2DNode17 = tex2D( _Metallic, uv_Metallic );
			o.Metallic = tex2DNode17.r;
			o.Smoothness = tex2DNode17.a;
			float2 uv_AO = i.uv_texcoord * _AO_ST.xy + _AO_ST.zw;
			o.Occlusion = tex2D( _AO, uv_AO ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
6.4;22.4;1523.2;780.6;1704.29;523.0239;1.706861;True;False
Node;AmplifyShaderEditor.ColorNode;4;-1078.62,200.117;Inherit;False;Property;_OutLineColor;OutLineColor;0;0;Create;True;0;0;False;0;0,0,0,0;0.1346613,1,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;3;-1193.19,470.4474;Inherit;False;Property;_OutlineWidth;OutlineWidth;1;0;Create;True;0;0;False;0;0;0.06;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1167.87,379.9536;Inherit;False;Property;_OutLineAlpha;OutLineAlpha;2;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;19;-1008.705,-444.1042;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OutlineNode;2;-842.5167,339.0163;Inherit;False;1;True;Transparent;0;0;Back;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;15;-627.8043,-466.5499;Inherit;True;Property;_Albedo;Albedo;5;0;Create;True;0;0;False;0;-1;None;ebeac4cd8014dde46b1cfc168856e167;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;17;-618.9435,-60.20795;Inherit;True;Property;_Metallic;Metallic;6;0;Create;True;0;0;False;0;-1;None;2f52606546a792c448b17f7ec8474add;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;18;-618.0272,164.3749;Inherit;True;Property;_AO;AO;4;0;Create;True;0;0;False;0;-1;None;fe5383489dbea364c8087bc19964ee4d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;6;-975.4545,-273.3717;Inherit;True;Property;_Normal;Normal;3;0;Create;True;0;0;False;0;-1;None;c7f3aaf35aa476c45b4a091021a91ef9;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;OutLineAmplify;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;1;True;False;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;2;0;4;0
WireConnection;2;2;11;0
WireConnection;2;1;3;0
WireConnection;15;1;19;0
WireConnection;0;0;15;0
WireConnection;0;1;6;0
WireConnection;0;3;17;0
WireConnection;0;4;17;4
WireConnection;0;5;18;0
WireConnection;0;11;2;0
ASEEND*/
//CHKSM=1953A809CCB15D528F8142D4E2F2A27AB83CBFE4