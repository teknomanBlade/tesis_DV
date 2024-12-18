// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SDR_FERNPaintballMinigun"
{
	Properties
	{
		_Levels1("Levels", Range( 0 , 100)) = 71
		_PrimaryTexture("PrimaryTexture", 2D) = "white" {}
		_PrimaryTexture1("PrimaryTexture", 2D) = "white" {}
		_SecondaryTexture("SecondaryTexture", 2D) = "white" {}
		_TransitionTextureVal("TransitionTextureVal", Range( 0 , 1)) = 0
		_Tint1("Tint", Color) = (0,0,0,0)
		_LightIntensity1("LightIntensity", Range( 0 , 5)) = 0
		_LerpLightDir1("LerpLightDir", Range( 0 , 1)) = 0
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

		uniform sampler2D _PrimaryTexture;
		uniform float4 _PrimaryTexture_ST;
		uniform sampler2D _SecondaryTexture;
		uniform float4 _SecondaryTexture_ST;
		uniform float _TransitionTextureVal;
		uniform float4 _Tint1;
		uniform sampler2D _PrimaryTexture1;
		uniform float4 _PrimaryTexture1_ST;
		uniform float _LerpLightDir1;
		uniform float _Levels1;
		uniform float _LightIntensity1;

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
			float2 uv_PrimaryTexture = i.uv_texcoord * _PrimaryTexture_ST.xy + _PrimaryTexture_ST.zw;
			float2 uv_SecondaryTexture = i.uv_texcoord * _SecondaryTexture_ST.xy + _SecondaryTexture_ST.zw;
			float4 lerpResult31 = lerp( tex2D( _PrimaryTexture, uv_PrimaryTexture ) , tex2D( _SecondaryTexture, uv_SecondaryTexture ) , _TransitionTextureVal);
			float2 uv_PrimaryTexture1 = i.uv_texcoord * _PrimaryTexture1_ST.xy + _PrimaryTexture1_ST.zw;
			float4 Albedo57 = ( _Tint1 * tex2D( _PrimaryTexture1, uv_PrimaryTexture1 ) );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult47 = dot( ase_worldNormal , ase_worldlightDir );
			float3 temp_cast_0 = (ase_worldNormal.x).xxx;
			float dotResult48 = dot( temp_cast_0 , ase_worldlightDir );
			float lerpResult50 = lerp( dotResult47 , dotResult48 , _LerpLightDir1);
			float Normal_LightDir52 = lerpResult50;
			float4 temp_cast_2 = (Normal_LightDir52).xxxx;
			float div60=256.0/float((int)(Normal_LightDir52*_Levels1 + _Levels1));
			float4 posterize60 = ( floor( temp_cast_2 * div60 ) / div60 );
			float4 Shadow62 = ( Albedo57 * posterize60 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 LightColor67 = ( Shadow62 * ase_lightColor * _LightIntensity1 );
			c.rgb = saturate( ( lerpResult31 * ( LightColor67 * ( 1.0 - step( ase_lightAtten , 0.33 ) ) ) ) ).rgb;
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
432;669;1307;605;2650.029;183.2971;3.115942;False;False
Node;AmplifyShaderEditor.CommentaryNode;33;-3326.752,371.6032;Inherit;False;1038.711;763.5355;Normal LightDir;9;52;50;49;48;47;46;45;44;43;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;45;-3218.229,760.476;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;44;-3258.752,419.1101;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;43;-3274.752,579.1103;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;46;-3231.05,936.3774;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;49;-2977.03,1005.995;Inherit;False;Property;_LerpLightDir1;LerpLightDir;7;0;Create;True;0;0;False;0;0;0.338;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;48;-2968.788,728.9716;Inherit;True;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;47;-3034.75,467.1104;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;50;-2677.943,609.5847;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;-0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;34;-2003.026,-52.50288;Inherit;False;983.5848;609.9885;Albedo;4;57;54;53;72;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;72;-1939.138,299.6298;Inherit;True;Property;_PrimaryTexture1;PrimaryTexture;2;0;Create;True;0;0;False;0;-1;8665fcdd21aee2b40bfc4f72715e70b5;63cb144134004754e9a44257cd0ab5b5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;35;-2154.555,694.2227;Inherit;False;1371.36;494.1964;Shadow;7;62;61;60;59;58;56;55;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-2490.604,704.7684;Inherit;False;Normal_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;53;-1868.629,35.1481;Inherit;False;Property;_Tint1;Tint;5;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;56;-2090.555,1046.223;Inherit;False;Property;_Levels1;Levels;0;0;Create;True;0;0;False;0;71;30;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1558.003,187.575;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-2074.555,838.2227;Inherit;False;52;Normal_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;58;-1802.556,982.2226;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-1223.385,367.6855;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;60;-1594.557,934.2227;Inherit;True;30;2;1;COLOR;0,0,0,0;False;0;INT;30;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;59;-1610.557,758.2231;Inherit;False;57;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-1306.556,838.2227;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;36;-2058.555,1382.223;Inherit;False;1202.176;506.8776;Light Color;5;67;66;65;64;63;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;62;-1034.556,902.2225;Inherit;False;Shadow;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;65;-2026.555,1590.223;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;64;-2026.555,1750.223;Inherit;False;Property;_LightIntensity1;LightIntensity;6;0;Create;True;0;0;False;0;0;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;-1898.555,1462.223;Inherit;False;62;Shadow;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;37;-841.0299,531.6958;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-1626.556,1574.223;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;-1098.557,1542.223;Inherit;False;LightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;38;-581.5061,405.9417;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.33;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;30;-524.8892,-571.84;Inherit;True;Property;_SecondaryTexture;SecondaryTexture;3;0;Create;True;0;0;False;0;-1;None;1146807ea4bd03c4fbd978c232f9075a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;39;-386.714,78.85902;Inherit;True;67;LightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;22;-536.1293,-344.2826;Inherit;True;Property;_PrimaryTexture;PrimaryTexture;2;0;Create;True;0;0;False;0;-1;8665fcdd21aee2b40bfc4f72715e70b5;63cb144134004754e9a44257cd0ab5b5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;32;-411.7017,-99.18854;Inherit;False;Property;_TransitionTextureVal;TransitionTextureVal;4;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;40;-338.5719,369.1727;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;31;-90.8805,-484.4619;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-61.74069,213.8728;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;114.127,-119.149;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;41;-3162.558,1238.223;Inherit;False;787.1289;475.5013;Normal ViewDir;4;71;70;69;68;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;69;-3098.558,1302.223;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;70;-3082.557,1494.223;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;68;-2858.556,1334.223;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;28;364.4846,33.86871;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;71;-2570.556,1446.223;Inherit;False;Normal_ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;605.2789,-196.2815;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;SDR_FERNPaintballMinigun;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;48;0;45;1
WireConnection;48;1;46;0
WireConnection;47;0;44;0
WireConnection;47;1;43;0
WireConnection;50;0;47;0
WireConnection;50;1;48;0
WireConnection;50;2;49;0
WireConnection;52;0;50;0
WireConnection;54;0;53;0
WireConnection;54;1;72;0
WireConnection;58;0;55;0
WireConnection;58;1;56;0
WireConnection;58;2;56;0
WireConnection;57;0;54;0
WireConnection;60;1;55;0
WireConnection;60;0;58;0
WireConnection;61;0;59;0
WireConnection;61;1;60;0
WireConnection;62;0;61;0
WireConnection;66;0;63;0
WireConnection;66;1;65;0
WireConnection;66;2;64;0
WireConnection;67;0;66;0
WireConnection;38;0;37;0
WireConnection;40;0;38;0
WireConnection;31;0;22;0
WireConnection;31;1;30;0
WireConnection;31;2;32;0
WireConnection;42;0;39;0
WireConnection;42;1;40;0
WireConnection;27;0;31;0
WireConnection;27;1;42;0
WireConnection;68;0;69;0
WireConnection;68;1;70;0
WireConnection;28;0;27;0
WireConnection;71;0;68;0
WireConnection;0;13;28;0
ASEEND*/
//CHKSM=2B25F21745FA7A46F85C219C7C73457816BE66A8