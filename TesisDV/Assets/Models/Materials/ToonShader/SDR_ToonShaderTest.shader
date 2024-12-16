// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SDR_ToonShaderTest"
{
	Properties
	{
		_Levels("Levels", Range( 0 , 100)) = 71
		_Gray_Albedo("Gray_Albedo", 2D) = "white" {}
		_SpaceSuit_Albedo("SpaceSuit_Albedo", 2D) = "white" {}
		_Tint("Tint", Color) = (0,0,0,0)
		_LightIntensity("LightIntensity", Range( 0 , 5)) = 0
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

		uniform float4 _Tint;
		uniform sampler2D _Gray_Albedo;
		uniform float4 _Gray_Albedo_ST;
		uniform sampler2D _SpaceSuit_Albedo;
		uniform float4 _SpaceSuit_Albedo_ST;
		uniform float _Levels;
		uniform float _LightIntensity;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_Gray_Albedo = i.uv_texcoord * _Gray_Albedo_ST.xy + _Gray_Albedo_ST.zw;
			float2 uv_SpaceSuit_Albedo = i.uv_texcoord * _SpaceSuit_Albedo_ST.xy + _SpaceSuit_Albedo_ST.zw;
			float4 Albedo24 = ( _Tint * ( tex2D( _Gray_Albedo, uv_Gray_Albedo ) + ( 1.0 - tex2D( _SpaceSuit_Albedo, uv_SpaceSuit_Albedo ) ) ) );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult3 = dot( ase_normWorldNormal , ase_worldlightDir );
			float Normal_LightDir8 = dotResult3;
			float4 temp_cast_1 = (Normal_LightDir8).xxxx;
			float div13=256.0/float((int)(Normal_LightDir8*_Levels + _Levels));
			float4 posterize13 = ( floor( temp_cast_1 * div13 ) / div13 );
			float4 Shadow15 = ( Albedo24 * posterize13 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 LightColor36 = ( Shadow15 * ase_lightColor * _LightIntensity );
			c.rgb = LightColor36.rgb;
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
257;572;1195;494;4042.881;1209.912;6.396462;True;False
Node;AmplifyShaderEditor.CommentaryNode;10;-1447.349,-343.8056;Inherit;False;787.1289;475.5013;Normal LightDir;4;8;1;2;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;25;-378.3351,-1429.624;Inherit;False;1400.183;739.3015;Albedo;7;24;21;17;16;23;31;32;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;1;-1386.619,-202.3186;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;2;-1413.023,-47.19492;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;17;-312.2338,-919.8035;Inherit;True;Property;_SpaceSuit_Albedo;SpaceSuit_Albedo;2;0;Create;True;0;0;False;0;-1;e065f6f3d761b3b45940dc52835e50e8;e065f6f3d761b3b45940dc52835e50e8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;16;-283.3342,-1151.896;Inherit;True;Property;_Gray_Albedo;Gray_Albedo;1;0;Create;True;0;0;False;0;-1;55d559a5c7bebba4ab7715b8e9276180;55d559a5c7bebba4ab7715b8e9276180;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;32;-4.546021,-921.4745;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;3;-1171.854,-164.6996;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;27;-389.7861,-603.4632;Inherit;False;1371.36;494.1964;Shadow;7;28;13;19;14;15;12;29;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-853.1281,-177.3461;Inherit;False;Normal_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;203.9762,-1106.681;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;23;167.6219,-1329.19;Inherit;False;Property;_Tint;Tint;3;0;Create;True;0;0;False;0;0,0,0,0;0.5471698,0.5471698,0.5471698,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;491.0319,-1129.889;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;12;-311.6253,-450.276;Inherit;False;8;Normal_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-324.5506,-254.6717;Inherit;False;Property;_Levels;Levels;0;0;Create;True;0;0;False;0;71;26.58824;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;19;-42.88071,-308.0845;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;821.3867,-1043.525;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;149.6986,-535.5872;Inherit;False;24;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;13;166.597,-365.3702;Inherit;True;30;2;1;COLOR;0,0,0,0;False;0;INT;30;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;462.6894,-464.451;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;729.8868,-396.7293;Inherit;False;Shadow;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-104.5991,302.1357;Inherit;False;Property;_LightIntensity;LightIntensity;4;0;Create;True;0;0;False;0;0;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;33;-109.7358,130.7161;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;35;11.89868,6.99472;Inherit;False;15;Shadow;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;282.615,116.0765;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;11;-1482.31,216.4842;Inherit;False;787.1289;475.5013;Normal ViewDir;4;9;4;5;6;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;810.723,94.87068;Inherit;False;LightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;6;-1182.149,310.2344;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-891.889,417.8969;Inherit;False;Normal_ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;26;1422.737,-303.6062;Inherit;False;305;497;Comment;1;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;4;-1407.087,470.9855;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;37;1123.645,-12.34238;Inherit;True;36;LightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldNormalVector;5;-1415.523,273.9059;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1472.737,-253.6062;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;SDR_ToonShaderTest;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;32;0;17;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;8;0;3;0
WireConnection;31;0;16;0
WireConnection;31;1;32;0
WireConnection;21;0;23;0
WireConnection;21;1;31;0
WireConnection;19;0;12;0
WireConnection;19;1;14;0
WireConnection;19;2;14;0
WireConnection;24;0;21;0
WireConnection;13;1;12;0
WireConnection;13;0;19;0
WireConnection;28;0;29;0
WireConnection;28;1;13;0
WireConnection;15;0;28;0
WireConnection;34;0;35;0
WireConnection;34;1;33;0
WireConnection;34;2;40;0
WireConnection;36;0;34;0
WireConnection;6;0;5;0
WireConnection;6;1;4;0
WireConnection;9;0;6;0
WireConnection;0;13;37;0
ASEEND*/
//CHKSM=BB262635E67BED4B396C05DE8FEC6621CFC74F48