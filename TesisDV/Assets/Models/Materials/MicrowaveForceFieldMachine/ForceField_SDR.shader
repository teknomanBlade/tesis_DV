// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ForceField_SDR"
{
	Properties
	{
		_TextureForceField("TextureForceField", 2D) = "white" {}
		_OutlinesRadius("OutlinesRadius", 2D) = "white" {}
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

		uniform sampler2D _TextureForceField;
		uniform float4 _TextureForceField_ST;
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
			float2 uv_TextureForceField = i.uv_texcoord * _TextureForceField_ST.xy + _TextureForceField_ST.zw;
			float4 color27 = IsGammaSpace() ? float4(0,1,1,1) : float4(0,1,1,1);
			float2 uv_OutlinesRadius = i.uv_texcoord * _OutlinesRadius_ST.xy + _OutlinesRadius_ST.zw;
			float4 tex2DNode2 = tex2D( _OutlinesRadius, uv_OutlinesRadius );
			float4 temp_output_52_0 = ( saturate( ( color27 * tex2DNode2 ) ) * tex2DNode2.a );
			float4 temp_output_58_0 = ( 1.0 - temp_output_52_0 );
			float4 lerpResult62 = lerp( ( tex2D( _TextureForceField, uv_TextureForceField ) * temp_output_58_0 ) , temp_output_52_0 , float4( 0.745283,0.745283,0.745283,0 ));
			o.Emission = saturate( ( ( pow( temp_output_93_0 , ( 1.0 - temp_output_93_0 ) ) * temp_output_93_0 ) + lerpResult62 ) ).rgb;
			float4 lerpResult60 = lerp( temp_output_58_0 , temp_output_52_0 , float4( 0.6981132,0.6981132,0.6981132,0 ));
			o.Alpha = lerpResult60.r;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
647;450;1137;548;1748.966;1146.633;2.532266;True;False
Node;AmplifyShaderEditor.ColorNode;27;-1721.892,22.11347;Inherit;False;Constant;_Color0;Color 0;4;0;Create;True;0;0;False;0;0,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-1695.97,263.6237;Inherit;True;Property;_OutlinesRadius;OutlinesRadius;1;0;Create;True;0;0;False;0;-1;None;aa415693c5d48ba49807d8075415e648;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1015.561,67.28967;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;94;-786.7759,-637.4163;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;81;-828.8618,-835.3613;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;1,1;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;9;-761.7774,33.875;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VoronoiNode;89;-515.3203,-774.5241;Inherit;True;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;17.9;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.ColorNode;92;-485.4747,-966.8616;Inherit;False;Constant;_Color1;Color 1;2;0;Create;True;0;0;False;0;0,0.9003706,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-560.2893,145.7026;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-144.5519,-767.5845;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-679.659,-166.6275;Inherit;True;Property;_TextureForceField;TextureForceField;0;0;Create;True;0;0;False;0;-1;None;49360749791a2c840b09505b61d942ee;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;58;-287.2953,325.617;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;100;137.7967,-1020.412;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-218.1338,-179.9232;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;98;414.5862,-949.8503;Inherit;True;False;2;0;COLOR;0,0,0,0;False;1;COLOR;10,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;62;12.39127,-59.53514;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.745283,0.745283,0.745283,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;648.6259,-687.848;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;333.9885,-56.02649;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;60;25.69805,287.073;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0.1886792,0.1886792,0.1886792,0;False;2;COLOR;0.6981132,0.6981132,0.6981132,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;63;561.2076,65.80944;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;896.3992,-30.7326;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;ForceField_SDR;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.53;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;26;0;27;0
WireConnection;26;1;2;0
WireConnection;9;0;26;0
WireConnection;89;0;81;0
WireConnection;89;1;94;0
WireConnection;52;0;9;0
WireConnection;52;1;2;4
WireConnection;93;0;92;0
WireConnection;93;1;89;0
WireConnection;58;0;52;0
WireConnection;100;0;93;0
WireConnection;59;0;1;0
WireConnection;59;1;58;0
WireConnection;98;0;93;0
WireConnection;98;1;100;0
WireConnection;62;0;59;0
WireConnection;62;1;52;0
WireConnection;97;0;98;0
WireConnection;97;1;93;0
WireConnection;90;0;97;0
WireConnection;90;1;62;0
WireConnection;60;0;58;0
WireConnection;60;1;52;0
WireConnection;63;0;90;0
WireConnection;0;2;63;0
WireConnection;0;9;60;0
ASEEND*/
//CHKSM=7E56B6DF06A759839FC789F42FABD7A6245BEB04