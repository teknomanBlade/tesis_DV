// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BlueprintMaterialUnavailable"
{
	Properties
	{
		_Opacity1("Opacity", Range( 0 , 1)) = 0
		_Tint("Tint", Color) = (1,0.0982824,0,0)
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

		uniform float4 _Tint;
		uniform float _Opacity1;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Emission = _Tint.rgb;
			o.Alpha = _Opacity1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
619;108;1137;535;742.95;31.39598;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;2;-424.2293,355.1619;Inherit;False;Property;_Opacity1;Opacity;0;0;Create;True;0;0;False;0;0;0.25;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;-380.5764,40.88261;Inherit;False;Property;_Tint;Tint;1;0;Create;True;0;0;False;0;1,0.0982824,0,0;0,1,0.05506635,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;BlueprintMaterialUnavailable;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;0;2;1;0
WireConnection;0;9;2;0
ASEEND*/
//CHKSM=2D6F17053B1E4EA91E209BB295C3445B4432FB16