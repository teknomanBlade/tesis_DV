// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SmokeConstructionCloud"
{
	Properties
	{
		_DistortShadow("DistortShadow", Range( 0 , 5)) = 2.47
		_StepShadow("StepShadow", Range( 0 , 1)) = 0
		_OutlineWidth("OutlineWidth", Range( 0 , 1)) = 0.1414499
		_ShadowTint1("ShadowTint1", Color) = (0,0,0,0)
		_OutlineColor("OutlineColor", Color) = (0,0,0,0)
		_ColorTint("ColorTint", Color) = (0,0,0,0)
		_SmokeTint("SmokeTint", Color) = (0,0,0,0)
		_Alpha("Alpha", Range( 0 , 1)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog alpha:premul  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		
		
		
		struct Input
		{
			half filler;
		};
		uniform float _OutlineWidth;
		uniform float4 _OutlineColor;
		uniform float _Alpha;
		
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float outlineVar = _OutlineWidth;
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = _OutlineColor.rgb;
			o.Alpha = _Alpha;
		}
		ENDCG
		

		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit alpha:fade keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float3 viewDir;
			float3 worldNormal;
			float3 worldPos;
		};

		uniform float4 _SmokeTint;
		uniform float4 _ShadowTint1;
		uniform float _DistortShadow;
		uniform float _StepShadow;
		uniform float4 _ColorTint;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += 0;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult13 = dot( i.viewDir , ( ( ase_worldNormal * _DistortShadow ) + ase_worldlightDir ) );
			float4 temp_output_31_0 = ( saturate( ( _ShadowTint1 * ( 1.0 - step( dotResult13 , _StepShadow ) ) ) ) * _ColorTint );
			float4 temp_output_34_0 = ( _SmokeTint * temp_output_31_0 );
			o.Emission = temp_output_34_0.rgb;
			o.Alpha = temp_output_34_0.r;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
320;158;1195;433;5250.104;1510.559;6.175963;True;False
Node;AmplifyShaderEditor.WorldNormalVector;3;-2995.437,-659.2946;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;4;-3124.023,-406.5584;Inherit;False;Property;_DistortShadow;DistortShadow;0;0;Create;True;0;0;False;0;2.47;2.86;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;7;-3002.088,-178.2088;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-2753.786,-548.4457;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;10;-2304.891,-484.1631;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-2459.89,-284.6242;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;13;-2160.445,-257.6594;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-2240.966,72.66426;Inherit;False;Property;_StepShadow;StepShadow;1;0;Create;True;0;0;False;0;0;0.948;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;18;-1845.798,-160.2212;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;19;-1619.448,-139.3409;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;21;-1697.386,-341.9827;Inherit;False;Property;_ShadowTint1;ShadowTint1;3;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1424.6,-144.5368;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;26;-525.9564,209.8976;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;30;-690.4396,-75.74615;Inherit;False;Property;_ColorTint;ColorTint;5;0;Create;True;0;0;False;0;0,0,0,0;0.9056604,0.9056604,0.9056604,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;35;-1152.604,-351.876;Inherit;False;Property;_Alpha;Alpha;7;0;Create;True;0;0;False;0;0;0.15;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;33;-61.53178,-317.8379;Inherit;False;Property;_SmokeTint;SmokeTint;6;0;Create;True;0;0;False;0;0,0,0,0;0.8018868,0.8018868,0.8018868,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;28;-1091.774,-168.2121;Inherit;False;Property;_OutlineWidth;OutlineWidth;2;0;Create;True;0;0;False;0;0.1414499;0.015;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;27;-1066.013,-572.261;Inherit;False;Property;_OutlineColor;OutlineColor;4;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-290.5466,260.981;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;205.1405,414.6948;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OutlineNode;29;-730.9476,-293.0874;Inherit;False;0;True;AlphaPremultiplied;0;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;271.3294,-225.0706;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;858.3499,-60.80958;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;SmokeConstructionCloud;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;8;0;3;0
WireConnection;8;1;4;0
WireConnection;9;0;8;0
WireConnection;9;1;7;0
WireConnection;13;0;10;0
WireConnection;13;1;9;0
WireConnection;18;0;13;0
WireConnection;18;1;16;0
WireConnection;19;0;18;0
WireConnection;23;0;21;0
WireConnection;23;1;19;0
WireConnection;26;0;23;0
WireConnection;31;0;26;0
WireConnection;31;1;30;0
WireConnection;32;0;31;0
WireConnection;29;0;27;0
WireConnection;29;2;35;0
WireConnection;29;1;28;0
WireConnection;34;0;33;0
WireConnection;34;1;31;0
WireConnection;0;2;34;0
WireConnection;0;9;34;0
WireConnection;0;11;29;0
ASEEND*/
//CHKSM=6CAC8843497F8EFBB5B0BF5D7D57DC04CB672D50