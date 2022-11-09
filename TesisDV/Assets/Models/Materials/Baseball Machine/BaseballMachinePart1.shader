// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BaseballMachine1"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_FirstPosition("FirstPosition", Float) = 0
		_Min("Min", Float) = 0
		_Max("Max", Float) = 0
		_SecondPosition("SecondPosition", Float) = 0
		_SecondPositionIntensity("SecondPositionIntensity", Float) = 0
		_ShadowIntensity("ShadowIntensity", Float) = 0
		_TintActive("TintActive", Color) = (1,0.9813726,0,0)
		_ColorInterpolatorBase("ColorInterpolatorBase", Range( 0 , 0.8)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
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

		uniform sampler2D _TextureSample0;
		uniform float4 _TextureSample0_ST;
		uniform float4 _TintActive;
		uniform float _ColorInterpolatorBase;
		uniform float _Min;
		uniform float _Max;
		uniform float _FirstPosition;
		uniform float _SecondPosition;
		uniform float _SecondPositionIntensity;
		uniform float _ShadowIntensity;

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
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			float4 tex2DNode2 = tex2D( _TextureSample0, uv_TextureSample0 );
			float temp_output_66_0 = min( _Min , _Max );
			float temp_output_68_0 = max( _Max , _Min );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldNormal = i.worldNormal;
			float dotResult60 = dot( ase_worldlightDir , ase_worldNormal );
			float temp_output_62_0 = ( ( dotResult60 + 1.0 ) * 0.5 );
			float smoothstepResult74 = smoothstep( temp_output_66_0 , temp_output_68_0 , ( temp_output_62_0 - _FirstPosition ));
			float smoothstepResult70 = smoothstep( temp_output_66_0 , temp_output_68_0 , ( temp_output_62_0 - _SecondPosition ));
			float temp_output_77_0 = ( saturate( smoothstepResult74 ) + saturate( ( smoothstepResult70 - _SecondPositionIntensity ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			c.rgb = saturate( ( tex2DNode2 * ( ( temp_output_77_0 + ( ( 1.0 - temp_output_77_0 ) * _ShadowIntensity ) ) * ase_lightColor * ase_lightAtten ) ) ).rgb;
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
			float2 uv_TextureSample0 = i.uv_texcoord * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
			float4 tex2DNode2 = tex2D( _TextureSample0, uv_TextureSample0 );
			o.Emission = saturate( ( tex2DNode2.a * _TintActive * _ColorInterpolatorBase ) ).rgb;
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
307;577;1137;586;2453.129;1051.226;2.594554;True;False
Node;AmplifyShaderEditor.WorldNormalVector;58;-4021.775,-154.6091;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;59;-4021.775,-330.6092;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;60;-3733.775,-250.6091;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-3525.775,-218.6091;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-3429.775,69.39101;Inherit;False;Property;_Min;Min;2;0;Create;True;0;0;False;0;0;0.38;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-2965.775,69.39101;Inherit;False;Property;_SecondPosition;SecondPosition;4;0;Create;True;0;0;False;0;0;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-3429.775,197.391;Inherit;False;Property;_Max;Max;3;0;Create;True;0;0;False;0;0;0.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-3333.775,-266.6091;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;69;-2757.775,5.391002;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-3269.775,-90.60901;Inherit;False;Property;_FirstPosition;FirstPosition;1;0;Create;True;0;0;False;0;0;0.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;66;-3157.775,69.39101;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;68;-3157.775,197.391;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;70;-2597.775,21.391;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-2581.775,277.391;Inherit;False;Property;_SecondPositionIntensity;SecondPositionIntensity;5;0;Create;True;0;0;False;0;0;0.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;72;-3109.775,-218.6091;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;73;-2309.775,21.391;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;74;-2613.775,-282.6091;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;75;-2101.775,-186.6091;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;76;-2101.775,69.39101;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-1909.775,-106.609;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;79;-1605.775,69.39101;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-1637.775,325.391;Inherit;False;Property;_ShadowIntensity;ShadowIntensity;6;0;Create;True;0;0;False;0;0;2.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-1349.775,165.391;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;81;-1301.549,435.6258;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;82;-1157.775,-74.60901;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;83;-965.7692,349.0698;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;53;-544.1868,-1032.888;Inherit;False;Property;_TintActive;TintActive;7;0;Create;True;0;0;False;0;1,0.9813726,0,0;1,0.9813726,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-1064.407,-832.2814;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;-1;6177c61f772737d489d191df38a53c47;074d54a083b900f4e9a83cf97c553603;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;56;-539.8544,-773.3776;Inherit;False;Property;_ColorInterpolatorBase;ColorInterpolatorBase;8;0;Create;True;0;0;False;0;0;0;0;0.8;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-805.3957,-178.8513;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-231.5856,-987.548;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-164.9499,-433.8051;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;52;29.72499,-362.4153;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;57;110.0488,-873.3668;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;321.807,-575.687;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;BaseballMachine1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;60;0;59;0
WireConnection;60;1;58;0
WireConnection;61;0;60;0
WireConnection;62;0;61;0
WireConnection;69;0;62;0
WireConnection;69;1;65;0
WireConnection;66;0;63;0
WireConnection;66;1;64;0
WireConnection;68;0;64;0
WireConnection;68;1;63;0
WireConnection;70;0;69;0
WireConnection;70;1;66;0
WireConnection;70;2;68;0
WireConnection;72;0;62;0
WireConnection;72;1;67;0
WireConnection;73;0;70;0
WireConnection;73;1;71;0
WireConnection;74;0;72;0
WireConnection;74;1;66;0
WireConnection;74;2;68;0
WireConnection;75;0;74;0
WireConnection;76;0;73;0
WireConnection;77;0;75;0
WireConnection;77;1;76;0
WireConnection;79;0;77;0
WireConnection;80;0;79;0
WireConnection;80;1;78;0
WireConnection;82;0;77;0
WireConnection;82;1;80;0
WireConnection;84;0;82;0
WireConnection;84;1;81;0
WireConnection;84;2;83;0
WireConnection;55;0;2;4
WireConnection;55;1;53;0
WireConnection;55;2;56;0
WireConnection;51;0;2;0
WireConnection;51;1;84;0
WireConnection;52;0;51;0
WireConnection;57;0;55;0
WireConnection;0;2;57;0
WireConnection;0;13;52;0
ASEEND*/
//CHKSM=AAAB6655F31F0EB7EE510FE409F7E471A47DC43B