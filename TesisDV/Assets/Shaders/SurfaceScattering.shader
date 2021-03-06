// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Unlit/SurfaceScattering"
{
	Properties
	{
		_Distortion("Distortion", Range( 0 , 5)) = 0.5
		_TintColor("TintColor", Color) = (0.735849,0.735849,0.735849,0)
		_Color0("Color 0", Color) = (0,0.7393618,0.8490566,0)
		_Width("Width", Range( 0 , 1)) = 0.1414499
		_OutLineColor("OutLineColor", Color) = (0,0,0,0)
		_Albedo("Albedo", 2D) = "white" {}
		_ShadowStrength1("Shadow Strength", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		
		
		
		struct Input
		{
			half filler;
		};
		uniform float _Width;
		uniform float4 _OutLineColor;
		
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float outlineVar = _Width;
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = _OutLineColor.rgb;
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting keepalpha noshadow vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float3 viewDir;
			float3 worldNormal;
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float4 _TintColor;
		uniform float _Distortion;
		uniform float _ShadowStrength1;
		uniform float4 _Color0;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 temp_output_21_0 = 0;
			v.vertex.xyz += temp_output_21_0;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult3 = dot( i.viewDir , ( ( ase_worldNormal * _Distortion ) + ase_worldlightDir ) );
			c.rgb = saturate( ( tex2D( _Albedo, uv_Albedo ) * ( _TintColor * ( float4( half3(0,0,0) , 0.0 ) + ( ( saturate( dotResult3 ) * saturate( ( ase_lightAtten + ( 1.0 - _ShadowStrength1 ) ) ) * ( 1.0 - _WorldSpaceLightPos0.w ) ) * _Color0 ) ) ) ) ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
7;6;1906;1013;2091.586;892.6397;1.787242;True;False
Node;AmplifyShaderEditor.WorldNormalVector;16;-1733.443,-122.6803;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;17;-1710.709,60.68819;Inherit;False;Property;_Distortion;Distortion;0;0;Create;True;0;0;False;0;0.5;0.5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;31;-1248.608,487.0062;Inherit;False;875.6224;413.5689;Adjustable Light Attenuation (directional light shadow tweaking);8;41;40;38;37;36;34;33;32;SSS Directional Lights (shadow control);1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-1231.811,703.9819;Float;False;Property;_ShadowStrength1;Shadow Strength;6;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-1413.421,-33.49357;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;2;-1757.124,219.6129;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LightAttenuation;33;-1217.325,628.4459;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;34;-965.2949,707.7339;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;42;-1354.092,790.807;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;19;-1203.768,190.1709;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1;-1082.801,-11.7268;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;3;-846.0217,206.8587;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;36;-1001.25,812.509;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-820.739,616.9929;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;40;-705.0959,611.8289;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;38;-611.6071,758.587;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;6;-644.2726,235.7345;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-500.7892,536.3972;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;14;-803.9255,-56.38346;Inherit;False;Property;_Color0;Color 0;2;0;Create;True;0;0;False;0;0,0.7393618,0.8490566,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;23;-855.452,-334.6521;Inherit;False;Property;_OutLineColor;OutLineColor;4;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;22;-853.6266,-144.0335;Inherit;False;Property;_Width;Width;3;0;Create;True;0;0;False;0;0.1414499;0.001;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-264.8859,83.5529;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OutlineNode;21;-481.1854,-155.6601;Inherit;False;0;True;None;0;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-84.54831,9.447765;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;26;-554.8031,-527.1258;Inherit;False;Property;_TintColor;TintColor;1;0;Create;True;0;0;False;0;0.735849,0.735849,0.735849,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-139.704,-520.4112;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;25;-408.1655,-768.7562;Inherit;True;Property;_Albedo;Albedo;5;0;Create;True;0;0;False;0;-1;None;1796b4d7493e7614cb99781ad1f67daf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;188.5931,-544.9695;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.NegateNode;20;-1041.52,238.3105;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;30;351.5499,-462.2518;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1057.373,-552.9571;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Unlit/SurfaceScattering;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;False;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;18;0;16;0
WireConnection;18;1;17;0
WireConnection;34;0;32;0
WireConnection;19;0;18;0
WireConnection;19;1;2;0
WireConnection;3;0;1;0
WireConnection;3;1;19;0
WireConnection;36;0;42;2
WireConnection;37;0;33;0
WireConnection;37;1;34;0
WireConnection;40;0;37;0
WireConnection;38;0;36;0
WireConnection;6;0;3;0
WireConnection;41;0;6;0
WireConnection;41;1;40;0
WireConnection;41;2;38;0
WireConnection;13;0;41;0
WireConnection;13;1;14;0
WireConnection;21;0;23;0
WireConnection;21;1;22;0
WireConnection;24;0;21;0
WireConnection;24;1;13;0
WireConnection;27;0;26;0
WireConnection;27;1;24;0
WireConnection;29;0;25;0
WireConnection;29;1;27;0
WireConnection;30;0;29;0
WireConnection;0;13;30;0
WireConnection;0;11;21;0
ASEEND*/
//CHKSM=0E2D9F5B20307531639B466C97D8E8543FB30E9B