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
373;607;1137;375;561.6259;525.8098;2.903636;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;94;-980.5001,-335.4248;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;81;-1022.586,-533.3699;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;1,1;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VoronoiNode;89;-709.0445,-472.5327;Inherit;True;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;17.9;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.ColorNode;92;-679.1989,-664.8702;Inherit;False;Constant;_Color1;Color 1;2;0;Create;True;0;0;False;0;0,0.9003706,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-1695.97,263.6237;Inherit;True;Property;_OutlinesRadius;OutlinesRadius;6;0;Create;True;0;0;False;0;-1;None;7f680ee7a44fd7b479abd4993f61f836;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;27;-1721.892,22.11347;Inherit;False;Constant;_Color0;Color 0;4;0;Create;True;0;0;False;0;0,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-406.4749,-443.3237;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;147;-232.128,-900.812;Inherit;False;Property;_Intensity;Intensity;13;0;Create;True;0;0;False;0;0;-4.17;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;143;-222.9355,-746.1877;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1015.561,67.28967;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;9;-761.7774,33.875;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;146;-18.07255,-797.6884;Inherit;True;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;98;-574.6851,-146.149;Inherit;False;ForceFieldLines;0;;4;dd5d8b9899e15b346b5a083be6686ceb;0;0;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;93.45169,-285.8258;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;144;195.6365,-597.3564;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-560.2893,145.7026;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;58;-287.2953,325.617;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;387.3074,-280.0711;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;100;-1903.309,-3428.671;Inherit;False;1987.844;732.4697;Comment;11;127;124;123;122;120;117;115;113;106;105;101;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;129;738.0909,-1790.101;Inherit;False;820.2998;637.5504;GLow;5;138;137;135;133;131;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;99;-1807.309,-2260.671;Inherit;False;1738.878;722.5874;Comment;14;125;121;119;118;114;112;111;110;109;108;107;104;103;102;Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.TFHCRemapNode;118;-959.3094,-1652.671;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;123;-1231.309,-3236.671;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;121;-639.3094,-1892.671;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;122;-1039.309,-2980.671;Inherit;False;Property;_NoiseScale1;NoiseScale;8;0;Create;True;0;0;False;0;2,2;5,5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;-1407.309,-2964.671;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;114;-1599.309,-1828.671;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;124;-815.3094,-3252.671;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;125;-351.3094,-1892.671;Inherit;True;Fade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;135;978.0909,-1502.101;Inherit;True;2;2;0;FLOAT;0.01;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;119;-943.3094,-1924.671;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;126;399.9738,-2606.101;Inherit;True;125;Fade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;110;-1167.309,-2148.671;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;-1471.309,-3076.671;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;112;-1199.309,-1924.671;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;128;676.5118,-2670.078;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;130;434.0909,-2414.101;Inherit;True;127;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;111;-1599.309,-1732.671;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;127;-143.3094,-3124.671;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;116;-1551.309,-1364.671;Inherit;False;Property;_ScaleDissolveGray1;ScaleDissolveGray;16;0;Create;True;0;0;False;0;0.4301261;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;104;-1423.309,-1940.671;Inherit;False;Property;_DissolveDirection1;DissolveDirection;12;0;Create;True;0;0;False;0;0,1,0;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;106;-1663.309,-3092.671;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;120;-1807.309,-3348.671;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;107;-1791.309,-1732.671;Inherit;False;Property;_LowerLimit1;LowerLimit;15;0;Create;True;0;0;False;0;5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-1791.309,-2948.671;Inherit;False;Property;_NoiseScrollspeed1;NoiseScrollspeed;7;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;131;786.0908,-1486.101;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;133;738.0909,-1614.101;Inherit;False;Property;_EdgeThickness1;EdgeThickness;9;0;Create;True;0;0;False;0;0;0.3;0;0.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;134;925.6415,-2598.971;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-1775.309,-1844.671;Inherit;False;Property;_UpperLimit1;UpperLimit;14;0;Create;True;0;0;False;0;-5;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;136;1148.567,-2396.622;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TimeNode;113;-1791.309,-2852.671;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;108;-1455.309,-2180.671;Inherit;False;Property;_VertexPosition1;VertexPosition;11;0;Create;True;0;0;False;0;1;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;101;-1855.309,-3156.671;Inherit;False;Property;_NoiseDirection1;NoiseDirection;5;0;Create;True;0;0;False;0;0,1,0;0,0,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StepOpNode;138;1218.091,-1662.101;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;137;1218.091,-1358.101;Inherit;False;Property;_EdgeColor1;EdgeColor;10;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0.7125139,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldPosInputsNode;103;-1727.309,-2164.671;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;63;605.2906,-239.9618;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;1668.71,-1528.002;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;132;450.0909,-2174.101;Inherit;True;125;Fade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;102;-1727.309,-2020.671;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;60;980.525,245.5223;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0.1886792,0.1886792,0.1886792,0;False;2;COLOR;0.6981132,0.6981132,0.6981132,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1862.265,-186.7563;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;ForceField_SDR;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.75;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;6;0;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
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
WireConnection;118;0;116;0
WireConnection;118;3;114;0
WireConnection;118;4;111;0
WireConnection;123;0;120;0
WireConnection;123;1;117;0
WireConnection;121;0;119;0
WireConnection;121;1;118;0
WireConnection;117;0;115;0
WireConnection;117;1;113;2
WireConnection;114;0;109;0
WireConnection;124;0;123;0
WireConnection;124;1;122;0
WireConnection;125;0;121;0
WireConnection;135;0;133;0
WireConnection;135;1;131;0
WireConnection;119;0;110;0
WireConnection;119;1;112;0
WireConnection;110;0;108;0
WireConnection;115;0;106;0
WireConnection;115;1;105;0
WireConnection;112;0;104;0
WireConnection;128;0;126;0
WireConnection;111;0;107;0
WireConnection;127;0;124;0
WireConnection;106;0;101;0
WireConnection;134;0;128;0
WireConnection;134;1;130;0
WireConnection;136;0;134;0
WireConnection;136;1;132;0
WireConnection;108;0;103;0
WireConnection;108;1;102;0
WireConnection;138;0;136;0
WireConnection;138;1;135;0
WireConnection;63;0;145;0
WireConnection;139;0;137;0
WireConnection;139;1;138;0
WireConnection;60;0;58;0
WireConnection;60;1;52;0
WireConnection;0;2;63;0
WireConnection;0;9;60;0
ASEEND*/
//CHKSM=757256781D67AFC5F49041377BBA71B39D70899E