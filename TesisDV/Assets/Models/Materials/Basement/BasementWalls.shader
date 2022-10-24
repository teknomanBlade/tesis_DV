// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BasementWalls"
{
	Properties
	{
		_MainTexture("Main Texture", 2D) = "white" {}
		_Glossiness("Glossiness", 2D) = "white" {}
		_FirstPosition("FirstPosition", Float) = 0
		_Min("Min", Float) = 0
		_Max("Max", Float) = 0
		_SecondPosition("SecondPosition", Float) = 0
		_SecondPositionIntensity("SecondPositionIntensity", Float) = 0
		_ShadowIntensity("ShadowIntensity", Float) = 0
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
		uniform sampler2D _Glossiness;
		uniform float4 _Glossiness_ST;
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
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float2 uv_Glossiness = i.uv_texcoord * _Glossiness_ST.xy + _Glossiness_ST.zw;
			float temp_output_58_0 = min( _Min , _Max );
			float temp_output_60_0 = max( _Max , _Min );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldNormal = i.worldNormal;
			float dotResult51 = dot( ase_worldlightDir , ase_worldNormal );
			float temp_output_55_0 = ( ( dotResult51 + 1.0 ) * 0.5 );
			float smoothstepResult65 = smoothstep( temp_output_58_0 , temp_output_60_0 , ( temp_output_55_0 - _FirstPosition ));
			float smoothstepResult62 = smoothstep( temp_output_58_0 , temp_output_60_0 , ( temp_output_55_0 - _SecondPosition ));
			float temp_output_68_0 = ( saturate( smoothstepResult65 ) + saturate( ( smoothstepResult62 - _SecondPositionIntensity ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			c.rgb = ( tex2D( _MainTexture, uv_MainTexture ) * tex2D( _Glossiness, uv_Glossiness ) * ( ( temp_output_68_0 + ( ( 1.0 - temp_output_68_0 ) * _ShadowIntensity ) ) * ase_lightColor ) ).rgb;
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
410;415;1137;547;2738.531;1246.636;2.311784;True;False
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;49;-4104.57,-787.4055;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;50;-4104.57,-611.4055;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;51;-3816.571,-707.4055;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-3608.571,-675.4055;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-3416.571,-723.4055;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-3512.571,-387.4055;Inherit;False;Property;_Min;Min;3;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-3512.571,-259.4055;Inherit;False;Property;_Max;Max;4;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-3065.037,-395.6387;Inherit;False;Property;_SecondPosition;SecondPosition;5;0;Create;True;0;0;False;0;0;1.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;60;-3240.571,-259.4055;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-3352.571,-547.4055;Inherit;False;Property;_FirstPosition;FirstPosition;2;0;Create;True;0;0;False;0;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;57;-2840.571,-451.4055;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;58;-3240.571,-387.4055;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-2664.571,-179.4055;Inherit;False;Property;_SecondPositionIntensity;SecondPositionIntensity;6;0;Create;True;0;0;False;0;0;1.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;62;-2680.571,-435.4055;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;63;-3192.571,-675.4055;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;64;-2392.571,-435.4055;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;65;-2696.571,-739.4055;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;67;-2184.571,-387.4055;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;66;-2184.571,-643.4055;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;68;-1992.571,-563.4055;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-1720.571,-131.4055;Inherit;False;Property;_ShadowIntensity;ShadowIntensity;7;0;Create;True;0;0;False;0;0;1.23;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;70;-1688.571,-387.4055;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-1432.57,-291.4055;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;72;-1352.57,-19.4055;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;73;-1240.57,-531.4055;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-888.1911,-635.6476;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;46;-899.9358,-1089.232;Inherit;True;Property;_Glossiness;Glossiness;1;0;Create;True;0;0;False;0;-1;ab611d0bba8a0334ca5fac9eaaf7419f;41b8bc1b3a5de58489a0e572ced59958;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;44;-908.4177,-1288.162;Inherit;True;Property;_MainTexture;Main Texture;0;0;Create;True;0;0;False;0;-1;2ec3aff22090c1248aa82b65522cb127;a23f3ad6b2f77414e95c9e1d09ca52d0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-338.2412,-947.0895;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;131.942,-935.3594;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;BasementWalls;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;51;0;49;0
WireConnection;51;1;50;0
WireConnection;52;0;51;0
WireConnection;55;0;52;0
WireConnection;60;0;53;0
WireConnection;60;1;56;0
WireConnection;57;0;55;0
WireConnection;57;1;54;0
WireConnection;58;0;56;0
WireConnection;58;1;53;0
WireConnection;62;0;57;0
WireConnection;62;1;58;0
WireConnection;62;2;60;0
WireConnection;63;0;55;0
WireConnection;63;1;59;0
WireConnection;64;0;62;0
WireConnection;64;1;61;0
WireConnection;65;0;63;0
WireConnection;65;1;58;0
WireConnection;65;2;60;0
WireConnection;67;0;64;0
WireConnection;66;0;65;0
WireConnection;68;0;66;0
WireConnection;68;1;67;0
WireConnection;70;0;68;0
WireConnection;71;0;70;0
WireConnection;71;1;69;0
WireConnection;73;0;68;0
WireConnection;73;1;71;0
WireConnection;48;0;73;0
WireConnection;48;1;72;0
WireConnection;47;0;44;0
WireConnection;47;1;46;0
WireConnection;47;2;48;0
WireConnection;0;13;47;0
ASEEND*/
//CHKSM=1A680B6424F22E9317043CC0E5A664702EEC3371