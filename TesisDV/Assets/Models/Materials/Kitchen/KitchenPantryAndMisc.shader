// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "KitchenPantryAndMisc"
{
	Properties
	{
		_Min1("Min", Float) = 0
		_Max1("Max", Float) = 0
		_FirstPosition1("First Position", Float) = 0
		_SecondPosition1("Second Position", Float) = 0
		_SecondPositionIntensity1("Second Position Intensity", Float) = 0
		_MainTexture("Main Texture", 2D) = "white" {}
		_ShadowIntensity1("Shadow Intensity", Float) = 0
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
			float temp_output_64_0 = min( _Min1 , _Max1 );
			float temp_output_63_0 = max( _Max1 , _Min1 );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldNormal = i.worldNormal;
			float dotResult54 = dot( ase_worldlightDir , ase_worldNormal );
			float temp_output_58_0 = ( ( dotResult54 + 1.0 ) * ase_lightAtten );
			float smoothstepResult68 = smoothstep( temp_output_64_0 , temp_output_63_0 , ( temp_output_58_0 - _FirstPosition1 ));
			float smoothstepResult67 = smoothstep( temp_output_64_0 , temp_output_63_0 , ( temp_output_58_0 - _SecondPosition1 ));
			float temp_output_72_0 = ( saturate( smoothstepResult68 ) + saturate( ( smoothstepResult67 - _SecondPositionIntensity1 ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			c.rgb = ( tex2D( _MainTexture, uv_MainTexture ) * ( ( temp_output_72_0 + ( ( 1.0 - temp_output_72_0 ) * _ShadowIntensity1 ) ) * ase_lightColor * ase_lightAtten ) ).rgb;
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
382;460;1137;592;1227.699;1137.5;1.692412;True;False
Node;AmplifyShaderEditor.CommentaryNode;51;-3100.857,-704.7054;Inherit;False;2894.373;778.0368;Main Light;27;78;77;76;75;74;73;72;71;70;69;68;67;66;65;64;63;62;61;60;59;58;57;56;55;54;53;52;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;52;-3047.057,-666.4611;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;53;-3024.778,-527.5839;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;54;-2747.652,-631.6237;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-2512.945,-635.9754;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;56;-2534.582,-474.6277;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-2049.884,-303.3961;Inherit;False;Property;_SecondPosition1;Second Position;3;0;Create;True;0;0;False;0;0;1.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-2367.977,-621.1676;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-2640.117,-246.0039;Inherit;False;Property;_Max1;Max;1;0;Create;True;0;0;False;0;0;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-2634.117,-330.0035;Inherit;False;Property;_Min1;Min;0;0;Create;True;0;0;False;0;0;0.57;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;63;-2303.117,-239.0039;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;64;-2302.117,-342.0036;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;62;-1852.432,-328.9168;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-2151.094,-505.7376;Inherit;False;Property;_FirstPosition1;First Position;2;0;Create;True;0;0;False;0;0;0.72;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-1725.121,-58.28555;Inherit;False;Property;_SecondPositionIntensity1;Second Position Intensity;4;0;Create;True;0;0;False;0;0;0.33;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;66;-1963.08,-569.8942;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;67;-1714.081,-267.1293;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;68;-1708.084,-530.2491;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;69;-1473.675,-264.9706;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;70;-1253.738,-269.9412;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;71;-1371.046,-446.313;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;-1073.561,-372.6156;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;73;-789.7945,-297.1688;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-832.7725,-73.37057;Inherit;False;Property;_ShadowIntensity1;Shadow Intensity;6;0;Create;True;0;0;False;0;0;1.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-489.8897,-266.3705;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;76;-347.7943,47.62303;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;78;-358.4854,-359.791;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;77;-344.9884,-93.55049;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;46;-268.7432,-963.2685;Inherit;True;Property;_MainTexture;Main Texture;5;0;Create;True;0;0;False;0;-1;2ec3aff22090c1248aa82b65522cb127;8c18c912f77d87d43b8464a027a9f9f5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-103.5933,-277.9224;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;419.7986,-624.8629;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;850.861,-544.8718;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;KitchenPantryAndMisc;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;54;0;52;0
WireConnection;54;1;53;0
WireConnection;55;0;54;0
WireConnection;58;0;55;0
WireConnection;58;1;56;0
WireConnection;63;0;59;0
WireConnection;63;1;60;0
WireConnection;64;0;60;0
WireConnection;64;1;59;0
WireConnection;62;0;58;0
WireConnection;62;1;57;0
WireConnection;66;0;58;0
WireConnection;66;1;61;0
WireConnection;67;0;62;0
WireConnection;67;1;64;0
WireConnection;67;2;63;0
WireConnection;68;0;66;0
WireConnection;68;1;64;0
WireConnection;68;2;63;0
WireConnection;69;0;67;0
WireConnection;69;1;65;0
WireConnection;70;0;69;0
WireConnection;71;0;68;0
WireConnection;72;0;71;0
WireConnection;72;1;70;0
WireConnection;73;0;72;0
WireConnection;75;0;73;0
WireConnection;75;1;74;0
WireConnection;78;0;72;0
WireConnection;78;1;75;0
WireConnection;79;0;78;0
WireConnection;79;1;77;0
WireConnection;79;2;76;0
WireConnection;47;0;46;0
WireConnection;47;1;79;0
WireConnection;0;13;47;0
ASEEND*/
//CHKSM=344EBEC8E35558A3DAAC883B90DFEFCDE38C43C2