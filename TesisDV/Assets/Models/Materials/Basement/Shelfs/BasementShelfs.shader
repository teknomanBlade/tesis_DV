// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BasementShelfs"
{
	Properties
	{
		_MainTexture("Main Texture", 2D) = "white" {}
		_FirstPosition1("FirstPosition", Float) = 0
		_Min1("Min", Float) = 0
		_Max1("Max", Float) = 0
		_SecondPosition1("SecondPosition", Float) = 0
		_SecondPositionIntensity1("SecondPositionIntensity", Float) = 0
		_ShadowIntensity1("ShadowIntensity", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
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

		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform float _Min1;
		uniform float _Max1;
		uniform float _FirstPosition1;
		uniform float _SecondPosition1;
		uniform float _SecondPositionIntensity1;
		uniform float _ShadowIntensity1;

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
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float temp_output_60_0 = min( _Min1 , _Max1 );
			float temp_output_57_0 = max( _Max1 , _Min1 );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldNormal = i.worldNormal;
			float dotResult51 = dot( ase_worldlightDir , ase_worldNormal );
			float temp_output_55_0 = ( ( dotResult51 + 1.0 ) * 0.5 );
			float smoothstepResult65 = smoothstep( temp_output_60_0 , temp_output_57_0 , ( temp_output_55_0 - _FirstPosition1 ));
			float smoothstepResult62 = smoothstep( temp_output_60_0 , temp_output_57_0 , ( temp_output_55_0 - _SecondPosition1 ));
			float temp_output_68_0 = ( saturate( smoothstepResult65 ) + saturate( ( smoothstepResult62 - _SecondPositionIntensity1 ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			c.rgb = ( tex2D( _MainTexture, uv_MainTexture ) * ( ( temp_output_68_0 + ( ( 1.0 - temp_output_68_0 ) * _ShadowIntensity1 ) ) * ase_lightColor * ase_lightAtten ) ).rgb;
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
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
270;448;1137;604;912.8431;796.8081;2.069299;True;False
Node;AmplifyShaderEditor.WorldNormalVector;49;-3142.355,-156.5931;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;50;-3142.355,-332.5932;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;51;-2854.355,-252.5931;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-2646.355,-220.5931;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-2454.355,-268.5931;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-2550.355,67.40701;Inherit;False;Property;_Min1;Min;2;0;Create;True;0;0;False;0;0;0.38;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-2550.355,195.407;Inherit;False;Property;_Max1;Max;3;0;Create;True;0;0;False;0;0;0.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-2086.355,67.40701;Inherit;False;Property;_SecondPosition1;SecondPosition;4;0;Create;True;0;0;False;0;0;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;60;-2278.355,67.40701;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-2390.355,-92.59301;Inherit;False;Property;_FirstPosition1;FirstPosition;1;0;Create;True;0;0;False;0;0;0.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;57;-2278.355,195.407;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;59;-1878.355,3.407001;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;62;-1718.355,19.407;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-1702.355,275.407;Inherit;False;Property;_SecondPositionIntensity1;SecondPositionIntensity;5;0;Create;True;0;0;False;0;0;0.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;61;-2230.355,-220.5931;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;64;-1430.355,19.407;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;65;-1734.355,-284.5931;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;66;-1222.355,-188.5931;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;67;-1222.355,67.40701;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;68;-1030.355,-108.593;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-758.355,323.407;Inherit;False;Property;_ShadowIntensity1;ShadowIntensity;6;0;Create;True;0;0;False;0;0;2.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;70;-726.355,67.40701;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-470.3549,163.407;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;72;-422.129,433.6418;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;74;-278.3551,-76.59301;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;73;-86.34922,347.0858;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;74.02424,-180.8353;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;44;16.17907,-866.5247;Inherit;True;Property;_MainTexture;Main Texture;0;0;Create;True;0;0;False;0;-1;None;d428c3e5ad359704294d63ec63b6503d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;583.9685,-525.4525;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;968.2441,-428.9689;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;BasementShelfs;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;51;0;50;0
WireConnection;51;1;49;0
WireConnection;52;0;51;0
WireConnection;55;0;52;0
WireConnection;60;0;56;0
WireConnection;60;1;53;0
WireConnection;57;0;53;0
WireConnection;57;1;56;0
WireConnection;59;0;55;0
WireConnection;59;1;54;0
WireConnection;62;0;59;0
WireConnection;62;1;60;0
WireConnection;62;2;57;0
WireConnection;61;0;55;0
WireConnection;61;1;58;0
WireConnection;64;0;62;0
WireConnection;64;1;63;0
WireConnection;65;0;61;0
WireConnection;65;1;60;0
WireConnection;65;2;57;0
WireConnection;66;0;65;0
WireConnection;67;0;64;0
WireConnection;68;0;66;0
WireConnection;68;1;67;0
WireConnection;70;0;68;0
WireConnection;71;0;70;0
WireConnection;71;1;69;0
WireConnection;74;0;68;0
WireConnection;74;1;71;0
WireConnection;48;0;74;0
WireConnection;48;1;72;0
WireConnection;48;2;73;0
WireConnection;47;0;44;0
WireConnection;47;1;48;0
WireConnection;0;13;47;0
ASEEND*/
//CHKSM=C432C72464E9FF1CB61A473B49434F99333A5C27