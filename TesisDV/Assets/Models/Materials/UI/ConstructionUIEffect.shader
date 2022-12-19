// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ConstructionUIEffect"
{
	Properties
	{
		_Frequency("Frequency", Float) = 0
		_ColorPrimary("ColorPrimary", Color) = (0.06627893,1,0,0)
		_TimeScale("TimeScale", Float) = 0
		_Opacity("Opacity", Range( 0 , 1)) = 0
		_PosterizePower("PosterizePower", Float) = 0
		_ColorTintSecondary("ColorTintSecondary", Color) = (0.5565186,1,0.4575472,0)
		_Tiling("Tiling", Float) = 0
		_Offset("Offset", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float4 screenPosition117;
		};

		uniform float _Tiling;
		uniform float _Offset;
		uniform float _PosterizePower;
		uniform float4 _ColorPrimary;
		uniform float _TimeScale;
		uniform float _Frequency;
		uniform float4 _ColorTintSecondary;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Opacity;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float2 temp_cast_0 = (_Tiling).xx;
			float2 temp_cast_1 = (_Offset).xx;
			float2 uv_TexCoord114 = v.texcoord.xy * temp_cast_0 + temp_cast_1;
			float mulTime108 = _Time.y * 2.47;
			float3 temp_cast_2 = (( uv_TexCoord114.y * sin( mulTime108 ) )).xxx;
			v.vertex.xyz += temp_cast_2;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 vertexPos117 = ase_vertex3Pos;
			float4 ase_screenPos117 = ComputeScreenPos( UnityObjectToClipPos( vertexPos117 ) );
			o.screenPosition117 = ase_screenPos117;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float temp_output_11_0 = distance( ase_worldViewDir.y , ase_worldPos.y );
			float mulTime3 = _Time.y * _TimeScale;
			float temp_output_2_0 = sin( ( ( temp_output_11_0 + mulTime3 ) * _Frequency ) );
			float div51=256.0/float((int)_PosterizePower);
			float4 posterize51 = ( floor( ( ( _ColorPrimary * temp_output_2_0 ) + ( _ColorTintSecondary * ( 1.0 - temp_output_2_0 ) ) ) * div51 ) / div51 );
			float4 ase_screenPos117 = i.screenPosition117;
			float4 ase_screenPosNorm117 = ase_screenPos117 / ase_screenPos117.w;
			ase_screenPosNorm117.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm117.z : ase_screenPosNorm117.z * 0.5 + 0.5;
			float screenDepth117 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm117.xy ));
			float distanceDepth117 = saturate( abs( ( screenDepth117 - LinearEyeDepth( ase_screenPosNorm117.z ) ) / ( temp_output_11_0 ) ) );
			float DepthFade119 = distanceDepth117;
			o.Emission = saturate( ( posterize51 / DepthFade119 ) ).rgb;
			o.Alpha = step( temp_output_2_0 , _Opacity );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
574;567;1137;516;276.9731;235.4597;2.895254;True;False
Node;AmplifyShaderEditor.RangedFloatNode;13;-1175.994,427.9201;Inherit;False;Property;_TimeScale;TimeScale;3;0;Create;True;0;0;False;0;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;7;-1557.315,-47.2957;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;10;-1580.898,249.3072;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;3;-1006.363,334.4019;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;11;-1362.165,47.39341;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-833.8678,20.06526;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-784.2278,328.3129;Inherit;False;Property;_Frequency;Frequency;0;0;Create;True;0;0;False;0;0;15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-587.9975,-35.55131;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;2;-333.0034,-99.66718;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;74;-29.28907,304.7565;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;118;-1555.678,648.7;Inherit;True;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;75;-62.08661,57.83076;Inherit;False;Property;_ColorTintSecondary;ColorTintSecondary;6;0;Create;True;0;0;False;0;0.5565186,1,0.4575472,0;0.1988359,0.9433962,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;1;-803.4227,-304.1979;Inherit;False;Property;_ColorPrimary;ColorPrimary;2;0;Create;True;0;0;False;0;0.06627893,1,0,0;0,0.764151,0.05405111,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-109.0467,-306.5863;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DepthFade;117;-1167.949,764.4572;Inherit;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;181.7373,210.5401;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;48;683.8128,-36.10176;Inherit;False;Property;_PosterizePower;PosterizePower;5;0;Create;True;0;0;False;0;0;90;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;119;-733.4324,817.6337;Inherit;False;DepthFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;395.486,-168.5427;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;51;938.1566,-222.3561;Inherit;True;1;2;1;COLOR;0,0,0,0;False;0;INT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;120;666.061,-431.2268;Inherit;False;119;DepthFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;116;1095.599,735.702;Inherit;False;Property;_Offset;Offset;8;0;Create;True;0;0;False;0;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;1084.23,615.9277;Inherit;False;Property;_Tiling;Tiling;7;0;Create;True;0;0;False;0;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;108;1040.165,980.6871;Inherit;False;1;0;FLOAT;2.47;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;109;1322.694,764.9536;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;114;1282.641,540.8129;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;125;1257.236,-375.8626;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;21;825.6952,214.4381;Inherit;False;Property;_Opacity;Opacity;4;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;78;1193.33,67.94214;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;2000.937,615.7438;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;107;1816.958,-267.0334;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2753.097,-112.575;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;ConstructionUIEffect;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;2;Custom;0.75;True;False;0;True;TransparentCutout;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;150;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;13;0
WireConnection;11;0;7;2
WireConnection;11;1;10;2
WireConnection;12;0;11;0
WireConnection;12;1;3;0
WireConnection;14;0;12;0
WireConnection;14;1;6;0
WireConnection;2;0;14;0
WireConnection;74;0;2;0
WireConnection;15;0;1;0
WireConnection;15;1;2;0
WireConnection;117;1;118;0
WireConnection;117;0;11;0
WireConnection;76;0;75;0
WireConnection;76;1;74;0
WireConnection;119;0;117;0
WireConnection;20;0;15;0
WireConnection;20;1;76;0
WireConnection;51;1;20;0
WireConnection;51;0;48;0
WireConnection;109;0;108;0
WireConnection;114;0;115;0
WireConnection;114;1;116;0
WireConnection;125;0;51;0
WireConnection;125;1;120;0
WireConnection;78;0;2;0
WireConnection;78;1;21;0
WireConnection;110;0;114;2
WireConnection;110;1;109;0
WireConnection;107;0;125;0
WireConnection;0;2;107;0
WireConnection;0;9;78;0
WireConnection;0;11;110;0
ASEEND*/
//CHKSM=FADA07ACAD265F6B64899D194C19C1245A0DFAD6