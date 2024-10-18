// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ForceField_SDR"
{
	Properties
	{
		_OutlinesRadius1("OutlinesRadius", 2D) = "white" {}
		_Min1("Min", Float) = 0
		_Progress1("Progress", Range( -1 , 1)) = 1
		_Max1("Max", Float) = 0
		_OutlinesRadius("OutlinesRadius", 2D) = "white" {}
		_Intensity("Intensity", Float) = 0
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
		};

		uniform float _Min1;
		uniform float _Max1;
		uniform sampler2D _OutlinesRadius1;
		uniform float4 _OutlinesRadius1_ST;
		uniform float _Progress1;
		uniform float _Intensity;
		uniform sampler2D _OutlinesRadius;
		uniform float4 _OutlinesRadius_ST;


		float2 voronoihash89( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi89( float2 v, float time, inout float2 id, float smoothness )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mr = 0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash89( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = g - f + o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			 		}
			 	}
			}
			return F1;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 color92 = IsGammaSpace() ? float4(0,0.9003706,1,0) : float4(0,0.788146,1,0);
			float time89 = _Time.y;
			float2 uv_TexCoord81 = i.uv_texcoord + float2( 1,1 );
			float2 coords89 = uv_TexCoord81 * 17.9;
			float2 id89 = 0;
			float voroi89 = voronoi89( coords89, time89,id89, 0 );
			float4 temp_output_93_0 = ( color92 * voroi89 );
			float4 color15_g4 = IsGammaSpace() ? float4(0,0.8078431,0.9817286,1) : float4(0,0.6172065,0.9589376,1);
			float temp_output_8_0_g4 = min( _Min1 , _Max1 );
			float temp_output_9_0_g4 = max( _Max1 , _Min1 );
			float2 uv_OutlinesRadius1 = i.uv_texcoord * _OutlinesRadius1_ST.xy + _OutlinesRadius1_ST.zw;
			float4 tex2DNode2_g4 = tex2D( _OutlinesRadius1, uv_OutlinesRadius1 );
			float temp_output_4_0_g4 = saturate( ( tex2DNode2_g4.r - _Progress1 ) );
			float smoothstepResult11_g4 = smoothstep( temp_output_8_0_g4 , temp_output_9_0_g4 , temp_output_4_0_g4);
			float smoothstepResult10_g4 = smoothstep( temp_output_8_0_g4 , temp_output_9_0_g4 , ( 1.0 - temp_output_4_0_g4 ));
			float4 temp_cast_0 = (_Intensity).xxxx;
			o.Emission = saturate( ( ( temp_output_93_0 + ( color15_g4 * ( ( smoothstepResult11_g4 * smoothstepResult10_g4 ) * ( 1.0 - tex2DNode2_g4.g ) ) ) ) * ( color92 * pow( ( 1.0 - temp_output_93_0 ) , temp_cast_0 ) ) ) ).rgb;
			float4 color27 = IsGammaSpace() ? float4(0,1,1,1) : float4(0,1,1,1);
			float2 uv_OutlinesRadius = i.uv_texcoord * _OutlinesRadius_ST.xy + _OutlinesRadius_ST.zw;
			float4 tex2DNode2 = tex2D( _OutlinesRadius, uv_OutlinesRadius );
			float4 temp_output_52_0 = ( saturate( ( color27 * tex2DNode2 ) ) * tex2DNode2.a );
			float4 lerpResult60 = lerp( ( 1.0 - temp_output_52_0 ) , temp_output_52_0 , float4( 0.6981132,0.6981132,0.6981132,0 ));
			o.Alpha = lerpResult60.r;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
407;531;1137;375;12065.38;5071.804;17.0007;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;94;-980.5001,-335.4248;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;81;-1022.586,-533.3699;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;1,1;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VoronoiNode;89;-709.0445,-472.5327;Inherit;True;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;17.9;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.ColorNode;92;-679.1989,-664.8702;Inherit;False;Constant;_Color1;Color 1;2;0;Create;True;0;0;False;0;0,0.9003706,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-1695.97,263.6237;Inherit;True;Property;_OutlinesRadius;OutlinesRadius;5;0;Create;True;0;0;False;0;-1;None;7f680ee7a44fd7b479abd4993f61f836;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;27;-1721.892,22.11347;Inherit;False;Constant;_Color0;Color 0;4;0;Create;True;0;0;False;0;0,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-406.4749,-443.3237;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-232.128,-900.812;Inherit;False;Property;_Intensity;Intensity;6;0;Create;True;0;0;False;0;0;-4.17;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;143;-222.9355,-746.1877;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1015.561,67.28967;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;98;-574.6851,-146.149;Inherit;False;ForceFieldLines;0;;4;dd5d8b9899e15b346b5a083be6686ceb;0;0;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;9;-761.7774,33.875;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;146;-18.07255,-797.6884;Inherit;True;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;93.45169,-285.8258;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;144;195.6365,-597.3564;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-560.2893,145.7026;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;58;-287.2953,325.617;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;387.3074,-280.0711;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;60;980.525,245.5223;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0.1886792,0.1886792,0.1886792,0;False;2;COLOR;0.6981132,0.6981132,0.6981132,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;63;605.2906,-239.9618;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1862.265,-186.7563;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;ForceField_SDR;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.75;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;89;0;81;0
WireConnection;89;1;94;0
WireConnection;93;0;92;0
WireConnection;93;1;89;0
WireConnection;143;0;93;0
WireConnection;26;0;27;0
WireConnection;26;1;2;0
WireConnection;9;0;26;0
WireConnection;146;0;143;0
WireConnection;146;1;147;0
WireConnection;90;0;93;0
WireConnection;90;1;98;0
WireConnection;144;0;92;0
WireConnection;144;1;146;0
WireConnection;52;0;9;0
WireConnection;52;1;2;4
WireConnection;58;0;52;0
WireConnection;145;0;90;0
WireConnection;145;1;144;0
WireConnection;60;0;58;0
WireConnection;60;1;52;0
WireConnection;63;0;145;0
WireConnection;0;2;63;0
WireConnection;0;9;60;0
ASEEND*/
//CHKSM=97B5D334242D1809CE4B89D0C3962605384E8808