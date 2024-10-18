// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TarLiquidMovement_SDR"
{
	Properties
	{
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 15
		_RingWidth("RingWidth", Float) = -0.01
		_TimeScale("TimeScale", Float) = 6
		_NormalWidth("NormalWidth", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf Standard alpha:fade keepalpha addshadow fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float _RingWidth;
		uniform float _TimeScale;
		uniform float _NormalWidth;
		uniform float _EdgeLength;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float mulTime10 = _Time.y * -18.0;
			float temp_output_11_0 = sin( ( ( ( distance( float2( 0.5,0.5 ) , v.texcoord.xy ) / _RingWidth ) * _TimeScale ) + mulTime10 ) );
			float3 temp_cast_0 = (saturate( ( temp_output_11_0 * 0.1 ) )).xxx;
			v.vertex.xyz += temp_cast_0;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float mulTime10 = _Time.y * -18.0;
			float temp_output_11_0 = sin( ( ( ( distance( float2( 0.5,0.5 ) , i.uv_texcoord ) / _RingWidth ) * _TimeScale ) + mulTime10 ) );
			float3 temp_cast_0 = (temp_output_11_0).xxx;
			float3 temp_output_3_0_g2 = temp_cast_0;
			float3 temp_output_4_0_g2 = ddx( temp_output_3_0_g2 );
			float dotResult8_g2 = dot( temp_output_4_0_g2 , temp_output_4_0_g2 );
			float3 temp_output_5_0_g2 = ddy( temp_output_3_0_g2 );
			float dotResult9_g2 = dot( temp_output_5_0_g2 , temp_output_5_0_g2 );
			float ifLocalVar10_g2 = 0;
			if( dotResult8_g2 > dotResult9_g2 )
				ifLocalVar10_g2 = dotResult8_g2;
			else if( dotResult8_g2 < dotResult9_g2 )
				ifLocalVar10_g2 = dotResult9_g2;
			float3 temp_cast_1 = (sqrt( ifLocalVar10_g2 )).xxx;
			float3 lerpResult21 = lerp( ase_worldlightDir , temp_cast_1 , _NormalWidth);
			float3 temp_output_4_0_g8 = lerpResult21;
			float3 temp_output_14_0_g8 = cross( ddy( ase_worldPos ) , temp_output_4_0_g8 );
			float3 temp_output_9_0_g8 = ddx( ase_worldPos );
			float dotResult21_g8 = dot( temp_output_14_0_g8 , temp_output_9_0_g8 );
			float temp_output_2_0_g8 = temp_output_3_0_g2.x;
			float ifLocalVar17_g8 = 0;
			if( dotResult21_g8 > 0.0 )
				ifLocalVar17_g8 = 1.0;
			else if( dotResult21_g8 == 0.0 )
				ifLocalVar17_g8 = 0.0;
			else if( dotResult21_g8 < 0.0 )
				ifLocalVar17_g8 = -1.0;
			float3 normalizeResult23_g8 = normalize( ( ( abs( dotResult21_g8 ) * temp_output_4_0_g8 ) - ( ( ( ( ( temp_output_3_0_g2 + temp_output_4_0_g2 ).x - temp_output_2_0_g8 ) * temp_output_14_0_g8 ) + ( ( ( temp_output_3_0_g2 + temp_output_5_0_g2 ).x - temp_output_2_0_g8 ) * cross( temp_output_4_0_g8 , temp_output_9_0_g8 ) ) ) * ifLocalVar17_g8 ) ) );
			o.Normal = normalizeResult23_g8;
			float4 color25 = IsGammaSpace() ? float4(0,0.01631975,0.6981132,0) : float4(0,0.001263139,0.4453062,0);
			o.Albedo = color25.rgb;
			o.Smoothness = 0.2;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
402;211;1195;518;4815.001;362.9602;2.316372;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-6249.183,-276.3069;Inherit;False;886.677;758.8679;;6;7;6;5;4;3;2;Efecto de radio;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;2;-6189.35,-226.3069;Float;False;Constant;_Vector0;Vector 0;0;0;Create;True;0;0;False;0;0.5,0.5;0.5,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-6210.494,-61.76859;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DistanceOpNode;4;-5880.794,-115.1011;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-5862.054,160.179;Float;False;Property;_RingWidth;RingWidth;5;0;Create;True;0;0;False;0;-0.01;0.34;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;7;-5580.439,16.15906;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.04;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-5575.474,274.3665;Float;False;Property;_TimeScale;TimeScale;6;0;Create;True;0;0;False;0;6;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;10;-5289.142,331.2988;Inherit;False;1;0;FLOAT;-18;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-5237.176,68.73566;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-5060.767,141.2141;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;11;-4752.513,137.3061;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;20;-3868.84,402.1116;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;19;-3832.84,308.1116;Inherit;False;Property;_NormalWidth;NormalWidth;7;0;Create;True;0;0;False;0;0;0.57;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;16;-3932.576,78.15681;Inherit;False;PreparePerturbNormalHQ;-1;;2;ac1afb3cd18c2244dbd9c5bf5acb9399;0;1;3;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT3;12;FLOAT3;13;FLOAT;14
Node;AmplifyShaderEditor.RangedFloatNode;14;-4718.583,466.4409;Inherit;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;21;-3610.84,251.1116;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-4482.469,141.965;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;13;-4192.759,128.928;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;17;-3457.881,64.18083;Inherit;False;PerturbNormalHQ;-1;;8;45dff16e78a0685469fed8b5b46e4d96;0;4;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-3245.241,307.2915;Inherit;False;Constant;_Const02;Const02;3;0;Create;True;0;0;False;0;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;25;-3263.754,-153.2547;Inherit;False;Constant;_Color0;Color 0;3;0;Create;True;0;0;False;0;0,0.01631975,0.6981132,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-2734.195,-78.74914;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;TarLiquidMovement_SDR;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;2;0
WireConnection;4;1;3;0
WireConnection;7;0;4;0
WireConnection;7;1;5;0
WireConnection;8;0;7;0
WireConnection;8;1;6;0
WireConnection;9;0;8;0
WireConnection;9;1;10;0
WireConnection;11;0;9;0
WireConnection;16;3;11;0
WireConnection;21;0;20;0
WireConnection;21;1;16;14
WireConnection;21;2;19;0
WireConnection;12;0;11;0
WireConnection;12;1;14;0
WireConnection;13;0;12;0
WireConnection;17;1;16;0
WireConnection;17;2;16;12
WireConnection;17;3;16;13
WireConnection;17;4;21;0
WireConnection;0;0;25;0
WireConnection;0;1;17;0
WireConnection;0;4;23;0
WireConnection;0;11;13;0
ASEEND*/
//CHKSM=3B7FCC541C4DBD38F7CDFCE03E1DD6811000AB23