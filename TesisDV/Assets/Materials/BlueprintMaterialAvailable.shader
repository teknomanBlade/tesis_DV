// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BlueprintMaterialAvailable"
{
	Properties
	{
		_Opacity("Opacity", Range( 0 , 1)) = 0
		_TintBlueprintAvailable("TintBlueprintAvailable", Color) = (0,1,0.07144809,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard alpha:fade keepalpha noshadow 
		struct Input
		{
			half filler;
		};

		uniform float4 _TintBlueprintAvailable;
		uniform float _Opacity;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Emission = _TintBlueprintAvailable.rgb;
			o.Alpha = _Opacity;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
455;339;1137;375;2004.415;565.1953;2.960294;True;False
Node;AmplifyShaderEditor.ColorNode;1;-243.5,-87.5;Inherit;False;Property;_TintBlueprintAvailable;TintBlueprintAvailable;1;0;Create;True;0;0;False;0;0,1,0.07144809,0;0,1,0.07144809,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;2;-250.3485,183.2221;Inherit;False;Property;_Opacity;Opacity;0;0;Create;True;0;0;False;0;0;0.294;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;91,-140;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;BlueprintMaterialAvailable;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;0;2;1;0
WireConnection;0;9;2;0
ASEEND*/
//CHKSM=A31A1AC78A1E70D03826609AE1610584FD762E1A