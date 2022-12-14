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
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit alpha:fade keepalpha noshadow 
		struct Input
		{
			float3 viewDir;
			float3 worldPos;
		};

		uniform float _PosterizePower;
		uniform float4 _ColorPrimary;
		uniform float _TimeScale;
		uniform float _Frequency;
		uniform float4 _ColorTintSecondary;
		uniform float _Opacity;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float mulTime3 = _Time.y * _TimeScale;
			float temp_output_2_0 = sin( ( ( distance( i.viewDir.y , ase_worldPos.y ) + mulTime3 ) * _Frequency ) );
			float div51=256.0/float((int)_PosterizePower);
			float4 posterize51 = ( floor( ( ( _ColorPrimary * temp_output_2_0 ) + ( _ColorTintSecondary * ( 1.0 - temp_output_2_0 ) ) ) * div51 ) / div51 );
			o.Emission = posterize51.rgb;
			o.Alpha = step( temp_output_2_0 , _Opacity );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
634;444;1137;546;-512.1008;209.6711;1.132537;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;10;-1580.898,249.3072;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;7;-1557.315,-47.2957;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;13;-1175.994,427.9201;Inherit;False;Property;_TimeScale;TimeScale;2;0;Create;True;0;0;False;0;0;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;11;-1362.165,47.39341;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;3;-1006.363,334.4019;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-833.8678,20.06526;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-784.2278,328.3129;Inherit;False;Property;_Frequency;Frequency;0;0;Create;True;0;0;False;0;0;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-587.9975,-35.55131;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;2;-333.0034,-99.66718;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;74;-29.28907,304.7565;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;-803.4227,-304.1979;Inherit;False;Property;_ColorPrimary;ColorPrimary;1;0;Create;True;0;0;False;0;0.06627893,1,0,0;0.6371129,0.9150943,0.617257,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;75;-62.08661,57.83076;Inherit;False;Property;_ColorTintSecondary;ColorTintSecondary;6;0;Create;True;0;0;False;0;0.5565186,1,0.4575472,0;0.4009434,1,0.4418727,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;181.7373,210.5401;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-109.0467,-306.5863;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;395.486,-168.5427;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;48;801.8009,-47.90057;Inherit;False;Property;_PosterizePower;PosterizePower;4;0;Create;True;0;0;False;0;0;90;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;825.6952,214.4381;Inherit;False;Property;_Opacity;Opacity;3;0;Create;True;0;0;False;0;0;0.4227533;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;67;-890.5439,-2030.915;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;64;-1125.9,-2108.663;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;70;-841.7716,-1748.006;Inherit;False;Property;_Offset;Offset;5;0;Create;True;0;0;False;0;0,0,0.1;0.1,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;66;-1156.005,-1821.378;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.CosOpNode;72;-282.7402,-2108.114;Inherit;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosterizeNode;51;1044.564,-275.4274;Inherit;True;1;2;1;COLOR;0,0,0,0;False;0;INT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-620.4072,-2070.463;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StepOpNode;78;1193.33,67.94214;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1716.134,-161.1041;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;ConstructionUIEffect;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;100;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;11;0;7;2
WireConnection;11;1;10;2
WireConnection;3;0;13;0
WireConnection;12;0;11;0
WireConnection;12;1;3;0
WireConnection;14;0;12;0
WireConnection;14;1;6;0
WireConnection;2;0;14;0
WireConnection;74;0;2;0
WireConnection;76;0;75;0
WireConnection;76;1;74;0
WireConnection;15;0;1;0
WireConnection;15;1;2;0
WireConnection;20;0;15;0
WireConnection;20;1;76;0
WireConnection;67;0;64;1
WireConnection;67;1;66;0
WireConnection;72;0;68;0
WireConnection;51;1;20;0
WireConnection;51;0;48;0
WireConnection;68;0;67;0
WireConnection;68;1;70;0
WireConnection;78;0;2;0
WireConnection;78;1;21;0
WireConnection;0;2;51;0
WireConnection;0;9;78;0
ASEEND*/
//CHKSM=771EF3F5EC7FB088B7AE6272A020577E027C6C79