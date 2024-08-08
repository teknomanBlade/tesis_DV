// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WitGainNValue"
{
	Properties
	{
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Unlit alpha:fade keepalpha addshadow fullforwardshadows 
		struct Input
		{
			half filler;
		};

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
155;216;1195;518;2150.278;826.6331;2.145222;True;False
Node;AmplifyShaderEditor.Vector2Node;20;-1837.936,650.4655;Inherit;False;Property;_OffsetWitPlus100;OffsetWitPlus100;12;0;Create;True;0;0;False;0;-1,-1.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ConditionalIfNode;27;-347.2732,-64.70959;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;10;-1775.167,-692.5027;Inherit;False;Property;_Tiling;Tiling;5;0;Create;True;0;0;False;0;2,2;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;14;-1821.916,-473.7233;Inherit;False;Property;_Vector0;Vector 0;14;0;Create;True;0;0;False;0;0,-0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;18;-1608.118,528.2766;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,22;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;21;-1593.051,898.3035;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,22;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;16;-1607.321,134.0896;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,22;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;13;-1828.322,-148.2831;Inherit;False;Property;_OffsetWitPlus60;OffsetWitPlus60;10;0;Create;True;0;0;False;0;-1,-1.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1598.504,-270.4719;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,22;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;12;-1820.109,-312.3712;Inherit;False;Property;_TilingWitPlus60;TilingWitPlus60;6;0;Create;True;0;0;False;0;2,4;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-863.5986,-401.8533;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;6;-1256.283,-454.1589;Inherit;True;Property;_WitIcon;WitIcon;4;0;Create;True;0;0;False;0;-1;e687e06e4c247fe4f8ee3c5077da37d8;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-862.252,796.8135;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-842.2432,40.80434;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;15;-1828.926,92.19025;Inherit;False;Property;_TilingWitPlus80;TilingWitPlus80;7;0;Create;True;0;0;False;0;2,4;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;17;-1837.139,253.6075;Inherit;False;Property;_OffsetWitPlus80;OffsetWitPlus80;11;0;Create;True;0;0;False;0;-1,-1.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;19;-1829.723,486.3771;Inherit;False;Property;_TilingWitPlus100;TilingWitPlus100;8;0;Create;True;0;0;False;0;2,4;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;22;-1814.656,856.4041;Inherit;False;Property;_TilingWitPlus200;TilingWitPlus200;9;0;Create;True;0;0;False;0;2,4;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;23;-1822.869,1020.492;Inherit;False;Property;_OffsetWitPlus200;OffsetWitPlus200;13;0;Create;True;0;0;False;0;-1,-1.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;2;-1322.582,144.1485;Inherit;True;Property;_WitPlus80;WitPlus80;1;0;Create;True;0;0;False;0;-1;8ee9dc398b05f2c47a6f3dd9d6f256f8;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-1297.747,471.8849;Inherit;True;Property;_WitPlus100;WitPlus100;2;0;Create;True;0;0;False;0;-1;c801dc4118c866847b02d4ca5d9e3016;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-844.614,432.1939;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;4;-1307.965,813.6188;Inherit;True;Property;_WitPlus200;WitPlus200;3;0;Create;True;0;0;False;0;-1;52e893442e51d8a429fca7e61cf10029;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-1272.572,-214.2237;Inherit;True;Property;_WitPlus60;WitPlus60;0;0;Create;True;0;0;False;0;-1;f91b4cd8d655b7446b1098bd77851288;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;9;-1536.501,-505.6222;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,22;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;28;-753.7388,-537.0281;Inherit;False;Property;_Float0;Float 0;15;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;107,-177;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;WitGainNValue;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;18;0;19;0
WireConnection;18;1;20;0
WireConnection;21;0;22;0
WireConnection;21;1;23;0
WireConnection;16;0;15;0
WireConnection;16;1;17;0
WireConnection;11;0;12;0
WireConnection;11;1;13;0
WireConnection;8;0;6;0
WireConnection;8;1;1;0
WireConnection;6;1;9;0
WireConnection;26;0;6;0
WireConnection;26;1;4;0
WireConnection;24;0;6;0
WireConnection;24;1;2;0
WireConnection;2;1;16;0
WireConnection;3;1;18;0
WireConnection;25;0;6;0
WireConnection;25;1;3;0
WireConnection;4;1;21;0
WireConnection;1;1;11;0
WireConnection;9;0;10;0
WireConnection;9;1;14;0
ASEEND*/
//CHKSM=1333FDFE0AB4CA0234EBCF6ACDC0D8DA52ED4158