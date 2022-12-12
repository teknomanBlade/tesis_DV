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
266;555;1137;375;3771.943;696.0879;1.674687;True;False
Node;AmplifyShaderEditor.WorldNormalVector;3;-3114.278,-564.4746;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;4;-3242.864,-311.7384;Inherit;False;Property;_DistortShadow;DistortShadow;0;0;Create;True;0;0;False;0;2.47;2.86;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;7;-3120.929,-83.38891;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-2872.627,-453.6257;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;10;-2423.732,-389.3431;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-2578.731,-189.8043;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;13;-2279.286,-162.8395;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-2359.807,167.4842;Inherit;False;Property;_StepShadow;StepShadow;1;0;Create;True;0;0;False;0;0;0.929;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;18;-1964.639,-65.40125;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;19;-1738.289,-44.52096;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;21;-1816.227,-247.1627;Inherit;False;Property;_ShadowTint1;ShadowTint1;3;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1543.441,-49.71691;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;26;-644.7974,304.7176;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;30;-809.2806,19.07379;Inherit;False;Property;_ColorTint;ColorTint;5;0;Create;True;0;0;False;0;0,0,0,0;0.9056604,0.9056604,0.9056604,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;35;-1271.445,-257.056;Inherit;False;Property;_Alpha;Alpha;7;0;Create;True;0;0;False;0;0;0.15;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;33;-180.3728,-223.0179;Inherit;False;Property;_SmokeTint;SmokeTint;6;0;Create;True;0;0;False;0;0,0,0,0;0.8018868,0.8018868,0.8018868,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;28;-1210.615,-73.39212;Inherit;False;Property;_OutlineWidth;OutlineWidth;2;0;Create;True;0;0;False;0;0.1414499;0.015;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;27;-1184.854,-477.4411;Inherit;False;Property;_OutlineColor;OutlineColor;4;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-409.3876,355.801;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;32;86.29945,509.5148;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;91.80367,-46.80903;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OutlineNode;29;-849.7886,-198.2675;Inherit;False;0;True;AlphaPremultiplied;0;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
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
WireConnection;34;0;33;0
WireConnection;34;1;31;0
WireConnection;29;0;27;0
WireConnection;29;2;35;0
WireConnection;29;1;28;0
WireConnection;0;2;34;0
WireConnection;0;9;34;0
WireConnection;0;11;29;0
ASEEND*/
//CHKSM=4DEF6A9C6B4219762CD643EAB2DC5AF753DD8065