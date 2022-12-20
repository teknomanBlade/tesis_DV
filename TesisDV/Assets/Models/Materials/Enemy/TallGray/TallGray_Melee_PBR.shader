// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TallGray_Melee_PBR"
{
	Properties
	{
		_Texture_Albedo("Texture_Albedo", 2D) = "white" {}
		_Normal_Map("Normal_Map", 2D) = "bump" {}
		_AmbientOcclusion("AmbientOcclusion", 2D) = "white" {}
		_Specular("Specular", 2D) = "white" {}
		_DisplacementMap("DisplacementMap", 2D) = "white" {}
		_EyesEmission("EyesEmission", 2D) = "white" {}
		_PumpingParts("PumpingParts", 2D) = "white" {}
		_PumpingParts1("PumpingParts", 2D) = "white" {}
		_PeriodGlowing("PeriodGlowing", Float) = 0
		_BumpMin("BumpMin", Float) = 0
		_BumpMax("BumpMax", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform sampler2D _PumpingParts1;
		uniform float4 _PumpingParts1_ST;
		uniform float _BumpMin;
		uniform float _BumpMax;
		uniform sampler2D _Normal_Map;
		uniform float4 _Normal_Map_ST;
		uniform sampler2D _Texture_Albedo;
		uniform float4 _Texture_Albedo_ST;
		uniform sampler2D _EyesEmission;
		uniform float4 _EyesEmission_ST;
		uniform float _PeriodGlowing;
		uniform sampler2D _PumpingParts;
		uniform float4 _PumpingParts_ST;
		uniform sampler2D _DisplacementMap;
		uniform float4 _DisplacementMap_ST;
		uniform sampler2D _Specular;
		uniform float4 _Specular_ST;
		uniform sampler2D _AmbientOcclusion;
		uniform float4 _AmbientOcclusion_ST;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float2 uv_PumpingParts1 = v.texcoord * _PumpingParts1_ST.xy + _PumpingParts1_ST.zw;
			float mulTime42 = _Time.y * 5.0;
			float smoothstepResult50 = smoothstep( _BumpMin , _BumpMax , sin( mulTime42 ));
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( ( tex2Dlod( _PumpingParts1, float4( uv_PumpingParts1, 0, 0.0) ) * smoothstepResult50 ) * float4( ase_vertexNormal , 0.0 ) ).rgb;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal_Map = i.uv_texcoord * _Normal_Map_ST.xy + _Normal_Map_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal_Map, uv_Normal_Map ) );
			float2 uv_Texture_Albedo = i.uv_texcoord * _Texture_Albedo_ST.xy + _Texture_Albedo_ST.zw;
			o.Albedo = tex2D( _Texture_Albedo, uv_Texture_Albedo ).rgb;
			float2 uv_EyesEmission = i.uv_texcoord * _EyesEmission_ST.xy + _EyesEmission_ST.zw;
			float mulTime27 = _Time.y * _PeriodGlowing;
			o.Emission = ( tex2D( _EyesEmission, uv_EyesEmission ) * saturate( sin( mulTime27 ) ) ).rgb;
			float2 uv_PumpingParts = i.uv_texcoord * _PumpingParts_ST.xy + _PumpingParts_ST.zw;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float mulTime23 = _Time.y * 2.0;
			float2 uv_DisplacementMap = i.uv_texcoord * _DisplacementMap_ST.xy + _DisplacementMap_ST.zw;
			o.Metallic = ( ( tex2D( _PumpingParts, uv_PumpingParts ) + float4( ase_vertex3Pos , 0.0 ) + sin( mulTime23 ) ) * tex2D( _DisplacementMap, uv_DisplacementMap ) ).r;
			float2 uv_Specular = i.uv_texcoord * _Specular_ST.xy + _Specular_ST.zw;
			o.Smoothness = tex2D( _Specular, uv_Specular ).r;
			float2 uv_AmbientOcclusion = i.uv_texcoord * _AmbientOcclusion_ST.xy + _AmbientOcclusion_ST.zw;
			o.Occlusion = tex2D( _AmbientOcclusion, uv_AmbientOcclusion ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
345;334;1137;465;2641.236;31.60547;1.896934;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;42;-3221.474,1160.157;Inherit;False;1;0;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-2459.984,-281.9929;Inherit;False;Property;_PeriodGlowing;PeriodGlowing;9;0;Create;True;0;0;False;0;0;2.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;27;-2257.196,-336.9195;Inherit;False;1;0;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;43;-2897.527,1142.061;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;23;-1975.745,542.2982;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-2732.983,1237.567;Inherit;False;Property;_BumpMin;BumpMin;10;0;Create;True;0;0;False;0;0;0.78;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-2726.037,1344.533;Inherit;False;Property;_BumpMax;BumpMax;11;0;Create;True;0;0;False;0;0;3.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-1882.779,-19.3955;Inherit;True;Property;_PumpingParts;PumpingParts;7;0;Create;True;0;0;False;0;-1;None;b3f262f2ea0a1b946aaf412596ccceed;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;50;-2555.328,1110.378;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;24;-1801.864,459.5434;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;20;-1826.525,214.5218;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;36;-2726.036,825.6968;Inherit;True;Property;_PumpingParts1;PumpingParts;8;0;Create;True;0;0;False;0;-1;None;b3f262f2ea0a1b946aaf412596ccceed;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;26;-2067.842,-362.0428;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;33;-1804.004,-307.7488;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-1474.811,148.2195;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;7;-1971.55,-595.2419;Inherit;True;Property;_EyesEmission;EyesEmission;6;0;Create;True;0;0;False;0;-1;None;892b9e4b3c0a8ac4e8e956d838fb2e3d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;39;-2182.78,1097.405;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;6;-1514.081,395.4782;Inherit;True;Property;_DisplacementMap;DisplacementMap;5;0;Create;True;0;0;False;0;-1;None;5d86ad3f68d19664f99caa1fcda32df8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-2247.05,850.2419;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1486.204,-549.9792;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-1158.185,-856.8327;Inherit;True;Property;_Normal_Map;Normal_Map;2;0;Create;True;0;0;False;0;-1;None;273ecc34bf0df054e8bfcc48d04e49ee;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-1056.382,-41.70725;Inherit;True;Property;_AmbientOcclusion;AmbientOcclusion;3;0;Create;True;0;0;False;0;-1;None;cd9b5ceb0044b3d45b5843654c351e19;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-1045.929,-271.1246;Inherit;True;Property;_Specular;Specular;4;0;Create;True;0;0;False;0;-1;None;b6f9c35186fa35644a797ff1ec8c2699;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-1111.954,264.0094;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-1939.238,992.0697;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-1111.821,-1124.461;Inherit;True;Property;_Texture_Albedo;Texture_Albedo;0;0;Create;True;0;0;False;0;-1;None;3bae34aab64e7a849b871eb540c85cbf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1,-221;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;TallGray_Melee_PBR;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;27;0;32;0
WireConnection;43;0;42;0
WireConnection;50;0;43;0
WireConnection;50;1;41;0
WireConnection;50;2;38;0
WireConnection;24;0;23;0
WireConnection;26;0;27;0
WireConnection;33;0;26;0
WireConnection;16;0;8;0
WireConnection;16;1;20;0
WireConnection;16;2;24;0
WireConnection;37;0;36;0
WireConnection;37;1;50;0
WireConnection;28;0;7;0
WireConnection;28;1;33;0
WireConnection;35;0;16;0
WireConnection;35;1;6;0
WireConnection;40;0;37;0
WireConnection;40;1;39;0
WireConnection;0;0;1;0
WireConnection;0;1;2;0
WireConnection;0;2;28;0
WireConnection;0;3;35;0
WireConnection;0;4;5;0
WireConnection;0;5;3;0
WireConnection;0;11;40;0
ASEEND*/
//CHKSM=8CE29422F13FB76C53FE85CE1CF40E73DF783873