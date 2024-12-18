// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Shed"
{
	Properties
	{
		_Levels("Levels", Range( 0 , 100)) = 71
		_BasementWorkbench("BasementWorkbench", 2D) = "white" {}
		_Tint("Tint", Color) = (0,0,0,0)
		_LerpLightDir1("LerpLightDir", Range( 0 , 1)) = 0
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
		uniform sampler2D _BasementWorkbench;
		uniform float4 _BasementWorkbench_ST;
		uniform float _LerpLightDir1;
		uniform float _Levels;
		uniform float _LightIntensity;

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
			float2 uv_BasementWorkbench = i.uv_texcoord * _BasementWorkbench_ST.xy + _BasementWorkbench_ST.zw;
			float4 Albedo122 = ( _Tint * tex2D( _BasementWorkbench, uv_BasementWorkbench ) );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult126 = dot( ase_worldNormal , ase_worldlightDir );
			float3 temp_cast_0 = (ase_worldlightDir.z).xxx;
			float dotResult127 = dot( temp_cast_0 , ase_worldlightDir );
			float lerpResult129 = lerp( dotResult126 , dotResult127 , _LerpLightDir1);
			float Normal_LightDir101 = lerpResult129;
			float4 temp_cast_2 = (Normal_LightDir101).xxxx;
			float div106=256.0/float((int)(Normal_LightDir101*_Levels + _Levels));
			float4 posterize106 = ( floor( temp_cast_2 * div106 ) / div106 );
			float4 Shadow108 = ( Albedo122 * posterize106 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 LightColor113 = ( Shadow108 * ase_lightColor * _LightIntensity );
			c.rgb = ( LightColor113 * ( 1.0 - step( ase_lightAtten , 0.0 ) ) ).rgb;
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
360;701;1307;593;10096.18;3924.723;3.617826;True;False
Node;AmplifyShaderEditor.CommentaryNode;89;-7809.771,-3134.628;Inherit;False;1154.376;856.8734;Normal LightDir;9;130;129;128;127;126;125;124;123;101;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;125;-7696.306,-2533.991;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;124;-7740.009,-2891.258;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;123;-7724.008,-3051.258;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;128;-7442.286,-2464.374;Inherit;False;Property;_LerpLightDir1;LerpLightDir;9;0;Create;True;0;0;False;0;0;0.636;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;127;-7434.044,-2741.396;Inherit;True;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;126;-7500.006,-3003.258;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;118;-6573.292,-3429.754;Inherit;False;983.5848;609.9885;Albedo;4;122;121;119;79;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;129;-7134.226,-2842.835;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;-0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-6884.791,-2803.255;Inherit;False;Normal_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;90;-6317.383,-2704.439;Inherit;False;1371.36;494.1964;Shadow;7;108;107;106;105;104;103;102;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;79;-6515.241,-3145.215;Inherit;True;Property;_BasementWorkbench;BasementWorkbench;7;0;Create;True;0;0;False;0;-1;None;d3a245ce59faca64586075634311c070;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;119;-6438.894,-3342.104;Inherit;False;Property;_Tint;Tint;8;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;103;-6253.383,-2352.439;Inherit;False;Property;_Levels;Levels;1;0;Create;True;0;0;False;0;71;13.3;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-6237.383,-2560.439;Inherit;False;101;Normal_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;-6128.267,-3189.677;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;104;-5965.383,-2416.439;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;122;-5793.65,-3009.566;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-5773.383,-2640.439;Inherit;False;122;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;106;-5757.383,-2464.439;Inherit;True;30;2;1;COLOR;0,0,0,0;False;0;INT;30;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;-5469.383,-2560.439;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;108;-5197.383,-2496.439;Inherit;False;Shadow;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;91;-6221.383,-2016.439;Inherit;False;1202.176;506.8776;Light Color;5;113;112;111;110;109;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightColorNode;109;-6189.383,-1808.439;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;111;-6189.383,-1648.439;Inherit;False;Property;_LightIntensity;LightIntensity;10;0;Create;True;0;0;False;0;0;1.59;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-6061.383,-1936.439;Inherit;False;108;Shadow;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;92;-4443.52,-321.9379;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;-5769.983,-1916.83;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;93;-4159.211,-298.4628;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;113;-5261.383,-1856.439;Inherit;False;LightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;51;-8144.944,2011.191;Inherit;False;2894.373;778.0368;Main Light;26;77;76;75;74;73;72;71;70;69;68;67;66;65;64;63;62;61;60;59;58;57;56;55;54;53;52;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;-4076.968,-668.869;Inherit;True;113;LightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;96;-3927.348,-329.1566;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;95;-7325.385,-2160.439;Inherit;False;787.1289;475.5013;Normal ViewDir;4;117;116;115;114;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;54;-7791.739,2084.273;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;-5402.572,2356.106;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;55;-7578.668,2241.269;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;71;-6330.651,2474.92;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;53;-8068.865,2188.313;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;116;-7245.385,-1904.439;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;56;-7557.031,2079.921;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-5147.68,2437.974;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;73;-5833.881,2418.728;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;-6733.383,-1952.439;Inherit;False;Normal_ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-5533.977,2449.526;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;117;-7261.385,-2096.439;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;65;-7007.167,2146.002;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;63;-7092.451,2437.287;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;70;-6415.133,2269.584;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;86;-5782.21,2955.219;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;47;-4172.068,1925.02;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;-6117.647,2343.281;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-7684.204,2469.893;Inherit;False;Property;_Max;Max;2;0;Create;True;0;0;False;0;0;-5.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;67;-6871.84,2405.463;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;88;-5272.57,2799.375;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-7412.063,2094.729;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;87;-5569.688,2794.465;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;114;-7021.384,-2064.439;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-7427.585,2674.626;Inherit;False;Property;_SecondPosition;Second Position;4;0;Create;True;0;0;False;0;0;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;64;-7346.204,2373.893;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-3709.551,-409.1375;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-7678.204,2385.893;Inherit;False;Property;_Min;Min;0;0;Create;True;0;0;False;0;0;2.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;83;-6661.423,1793.56;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;130;-7683.486,-2709.892;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;74;-5876.859,2642.526;Inherit;False;Property;_ShadowIntensity;Shadow Intensity;6;0;Create;True;0;0;False;0;0;0.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;52;-8091.144,2049.436;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StepOpNode;82;-7032.311,1816.404;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-7195.18,2210.159;Inherit;False;Property;_FirstPosition;First Position;3;0;Create;True;0;0;False;0;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-6769.208,2657.611;Inherit;False;Property;_SecondPositionIntensity;Second Position Intensity;5;0;Create;True;0;0;False;0;0;0.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;85;-6808.982,2800.586;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;69;-6752.17,2185.648;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;77;-5389.075,2622.346;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMaxOpNode;61;-7347.204,2476.893;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;84;-7179.87,2823.43;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;68;-6496.521,2450.926;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-4581.552,2032.051;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-3343.931,-572.425;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Shed;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;127;0;125;3
WireConnection;127;1;125;0
WireConnection;126;0;123;0
WireConnection;126;1;124;0
WireConnection;129;0;126;0
WireConnection;129;1;127;0
WireConnection;129;2;128;0
WireConnection;101;0;129;0
WireConnection;121;0;119;0
WireConnection;121;1;79;0
WireConnection;104;0;102;0
WireConnection;104;1;103;0
WireConnection;104;2;103;0
WireConnection;122;0;121;0
WireConnection;106;1;102;0
WireConnection;106;0;104;0
WireConnection;107;0;105;0
WireConnection;107;1;106;0
WireConnection;108;0;107;0
WireConnection;112;0;110;0
WireConnection;112;1;109;0
WireConnection;112;2;111;0
WireConnection;93;0;92;0
WireConnection;113;0;112;0
WireConnection;96;0;93;0
WireConnection;54;0;52;0
WireConnection;54;1;53;0
WireConnection;76;0;72;0
WireConnection;76;1;75;0
WireConnection;71;0;68;0
WireConnection;56;0;54;0
WireConnection;78;0;76;0
WireConnection;78;1;77;0
WireConnection;78;2;88;0
WireConnection;73;0;72;0
WireConnection;115;0;114;0
WireConnection;75;0;73;0
WireConnection;75;1;74;0
WireConnection;65;0;59;0
WireConnection;65;1;62;0
WireConnection;63;0;59;0
WireConnection;63;1;57;0
WireConnection;70;0;83;0
WireConnection;47;0;80;0
WireConnection;72;0;70;0
WireConnection;72;1;71;0
WireConnection;67;0;63;0
WireConnection;67;1;64;0
WireConnection;67;2;61;0
WireConnection;88;0;87;0
WireConnection;59;0;56;0
WireConnection;59;1;55;0
WireConnection;87;0;86;0
WireConnection;114;0;117;0
WireConnection;114;1;116;0
WireConnection;64;0;60;0
WireConnection;64;1;58;0
WireConnection;97;0;94;0
WireConnection;97;1;96;0
WireConnection;83;0;82;0
WireConnection;82;0;59;0
WireConnection;82;1;62;0
WireConnection;85;0;84;0
WireConnection;69;0;65;0
WireConnection;69;1;64;0
WireConnection;69;2;61;0
WireConnection;61;0;58;0
WireConnection;61;1;60;0
WireConnection;84;0;59;0
WireConnection;84;1;57;0
WireConnection;68;0;85;0
WireConnection;68;1;66;0
WireConnection;80;1;78;0
WireConnection;0;13;97;0
ASEEND*/
//CHKSM=216D487ECCEAC04722B3DE0B0DA00954F0B81587