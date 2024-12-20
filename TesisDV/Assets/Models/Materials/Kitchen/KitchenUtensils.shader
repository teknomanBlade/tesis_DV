// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PantryAndElements"
{
	Properties
	{
		_Levels("Levels", Range( 0 , 100)) = 71
		_Tint("Tint", Color) = (0,0,0,0)
		_LerpLightDir("LerpLightDir", Range( 0 , 1)) = 0
		_LightIntensity("LightIntensity", Range( 0 , 5)) = 0
		_TrimSheetPropsTex("TrimSheetPropsTex", 2D) = "white" {}
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
		uniform sampler2D _TrimSheetPropsTex;
		uniform float4 _TrimSheetPropsTex_ST;
		uniform float _LerpLightDir;
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
			float2 uv_TrimSheetPropsTex = i.uv_texcoord * _TrimSheetPropsTex_ST.xy + _TrimSheetPropsTex_ST.zw;
			float4 tex2DNode134 = tex2D( _TrimSheetPropsTex, uv_TrimSheetPropsTex );
			float4 Albedo117 = ( _Tint * tex2DNode134 );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult159 = dot( ase_worldNormal , ase_worldlightDir );
			float3 temp_cast_4 = (ase_worldlightDir.z).xxx;
			float dotResult158 = dot( temp_cast_4 , ase_worldlightDir );
			float lerpResult161 = lerp( dotResult159 , dotResult158 , _LerpLightDir);
			float Normal_LightDir112 = lerpResult161;
			float4 temp_cast_6 = (Normal_LightDir112).xxxx;
			float div119=256.0/float((int)(Normal_LightDir112*_Levels + _Levels));
			float4 posterize119 = ( floor( temp_cast_6 * div119 ) / div119 );
			float4 Shadow121 = ( Albedo117 * posterize119 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 LightColor126 = ( Shadow121 * ase_lightColor * _LightIntensity );
			c.rgb = ( LightColor126 * ( 1.0 - step( ase_lightAtten , 0.0 ) ) ).rgb;
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
			float2 uv_TrimSheetPropsTex = i.uv_texcoord * _TrimSheetPropsTex_ST.xy + _TrimSheetPropsTex_ST.zw;
			float4 tex2DNode134 = tex2D( _TrimSheetPropsTex, uv_TrimSheetPropsTex );
			float4 Albedo117 = ( _Tint * tex2DNode134 );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult159 = dot( ase_worldNormal , ase_worldlightDir );
			float3 temp_cast_0 = (ase_worldlightDir.z).xxx;
			float dotResult158 = dot( temp_cast_0 , ase_worldlightDir );
			float lerpResult161 = lerp( dotResult159 , dotResult158 , _LerpLightDir);
			float Normal_LightDir112 = lerpResult161;
			float4 temp_cast_2 = (Normal_LightDir112).xxxx;
			float div119=256.0/float((int)(Normal_LightDir112*_Levels + _Levels));
			float4 posterize119 = ( floor( temp_cast_2 * div119 ) / div119 );
			float4 Shadow121 = ( Albedo117 * posterize119 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 LightColor126 = ( Shadow121 * ase_lightColor * _LightIntensity );
			float4 temp_output_128_0 = LightColor126;
			o.Albedo = temp_output_128_0.rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows noshadow 

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
-1913;32;1920;885;8969.405;4953.929;4.849503;True;True
Node;AmplifyShaderEditor.CommentaryNode;101;-4436.095,-3067.125;Inherit;False;1068.343;934.8422;Normal LightDir;9;112;160;161;158;157;162;156;155;159;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;157;-4356.777,-2375.525;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;156;-4400.479,-2732.792;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;155;-4384.478,-2892.792;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;158;-4094.513,-2582.93;Inherit;True;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;159;-4160.477,-2844.792;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;160;-4102.756,-2305.908;Inherit;False;Property;_LerpLightDir;LerpLightDir;5;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;102;-3636.441,-4485.31;Inherit;False;2295.056;1208.044;Albedo;14;142;141;140;139;136;134;117;115;111;147;153;154;100;88;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;161;-3794.696,-2684.369;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;-0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;112;-3573.439,-2584.127;Inherit;False;Normal_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;134;-3555.987,-3640.836;Inherit;True;Property;_TrimSheetPropsTex;TrimSheetPropsTex;11;0;Create;True;0;0;False;0;-1;None;a8a21c9251b179e4a858b853683d4812;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;110;-3055.571,-2798.367;Inherit;False;1371.36;494.1964;Shadow;7;121;120;119;118;116;114;113;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;111;-2357.541,-4397.66;Inherit;False;Property;_Tint;Tint;4;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;-2046.914,-4245.233;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-2990.336,-2449.576;Inherit;False;Property;_Levels;Levels;0;0;Create;True;0;0;False;0;71;27.1;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-2977.41,-2645.18;Inherit;False;112;Normal_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;116;-2708.666,-2502.989;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;117;-1712.298,-4065.122;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;119;-2499.188,-2560.274;Inherit;True;30;2;1;COLOR;0,0,0,0;False;0;INT;30;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;118;-2516.087,-2730.491;Inherit;False;117;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;-2203.096,-2659.355;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;121;-1935.898,-2591.634;Inherit;False;Shadow;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;123;-2775.521,-2064.188;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;122;-2770.384,-1892.769;Inherit;False;Property;_LightIntensity;LightIntensity;7;0;Create;True;0;0;False;0;0;1.53;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;-2653.886,-2187.91;Inherit;False;121;Shadow;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-2383.17,-2078.828;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;144;730.4473,-148.4187;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;-1855.062,-2100.034;Inherit;False;LightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;145;942.9703,-309.1729;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;2;-4330.708,2130.115;Inherit;False;2366.779;547.9448;;14;44;40;39;35;33;26;24;19;18;14;10;7;5;3;Specular/Reflecciones;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;12;-4110.784,2766.239;Inherit;False;1969.371;712.1435;;15;43;38;36;34;32;31;29;28;27;25;22;21;20;16;13;Fresnel Manual;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1;-4273.453,1471.629;Inherit;False;1670.493;552.806;Más su color;11;41;37;30;23;17;15;11;9;8;6;4;Dirección de la luz;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;50;-2873.491,-741.27;Inherit;False;2894.373;778.0368;Main Light;19;76;75;74;73;72;71;70;69;67;66;61;58;56;55;54;53;52;51;82;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;127;-4148.095,-1978.42;Inherit;False;787.1289;475.5013;Normal ViewDir;4;132;131;130;129;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;128;1137.762,-636.2562;Inherit;True;126;LightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;146;1240.087,-304.2619;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;75;-131.1195,-396.3552;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-605.4064,-109.9349;Inherit;False;Property;_ShadowIntensity;Shadow Intensity;16;0;Create;True;0;0;False;0;0;0.52;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;123.7723,-314.4866;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-3532.358,1657.388;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;164.4904,-1321.652;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;36;-2621.035,3095.808;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;129.3571,-1708.337;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;131;-4072.872,-1723.919;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;88;-3580.439,-4350.426;Inherit;True;Property;_OpacityMap_TrimSheetProps;OpacityMap_TrimSheetProps;17;0;Create;True;0;0;False;0;-1;2a2ea88b54a5fd348ab6b864b3e826b7;2a2ea88b54a5fd348ab6b864b3e826b7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;147;-1867.731,-3708.76;Inherit;False;LightEmission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;96;484.1589,-1333.757;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-3056.645,-3924.22;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;91;449.0255,-1720.442;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-3066.17,2405.016;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;54;-2307.216,-511.1918;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;80;-268.5927,68.32439;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;76;-117.6224,-130.1148;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;19;-3113.218,2553.118;Inherit;False;Property;_Intensity;Intensity;8;0;Create;True;0;0;False;0;0;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;23;-3782.351,1531.473;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;100;-3571.699,-4029.757;Inherit;True;Property;_TrimSheetProps_LivingLightEmission;TrimSheetProps_LivingLightEmission;20;0;Create;True;0;0;False;0;-1;b85bbfc6ffeeab549a8949fddb6f3885;b85bbfc6ffeeab549a8949fddb6f3885;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-3768.802,1909.436;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-2904.868,2545.059;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;414.1208,-366.2724;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;38;-2632.849,2818.025;Inherit;False;Property;_RimColor;Rim Color;3;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0.5,0.5,0.5,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;151;476.2496,-2026.291;Inherit;False;EmissionLightBarn;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;154;-2967.127,-4017.927;Inherit;False;152;EmissionLightLiving;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;140;-2701.231,-3882.196;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;141;-2753.409,-4243.314;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;142;-2362.142,-4058.984;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;17;-3175.595,1822.593;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.WorldNormalVector;162;-4343.957,-2551.426;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-1558.772,2008.554;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;83;-1360.126,-726.8319;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;3;-4274.807,2294.125;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-2796.241,3345.381;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;85;-1552.142,-206.3223;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;130;-3847.934,-1884.67;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-3571.369,1798.473;Inherit;False;LdotN;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-1923.728,-542.3017;Inherit;False;Property;_FirstPosition;First Position;10;0;Create;True;0;0;False;0;0;0.17;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;5;-4037.228,2301.503;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;148;1493.466,-841.6431;Inherit;False;147;LightEmission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-3060.294,-4273.823;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;72;-562.4283,-333.7329;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;132;-4081.308,-1920.998;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LightAttenuation;79;-481.1158,229.0786;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;8;-3990.172,1780.74;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-2310.413,3069.875;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;81;28.52436,73.23541;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;28;-3396.48,3258.962;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;42;-1767.664,2434.818;Inherit;False;Property;_AmbientColor;Ambient Color;2;0;Create;True;0;0;False;0;0.490566,0.490566,0.490566,0;1,0.9198113,0.9198113,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;129;-3557.674,-1777.007;Inherit;False;Normal_ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-1245.966,2039.14;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;32;-2814.241,3209.382;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;46;-1627.616,1749.335;Inherit;False;Property;_MainColor;Main Color;1;0;Create;True;0;0;False;0;0.6698113,0.6698113,0.6698113,0;0.2392157,0.2392157,0.2392157,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;27;-3200.966,3260.968;Inherit;False;Property;_RimAmount;Rim Amount;13;0;Create;True;0;0;False;0;0;0.102;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;848.8156,-1489.238;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;53;-2520.286,-668.1879;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-2771.96,1749.632;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;82;-1714.784,-703.988;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;67;-1225.068,-301.5349;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;69;-1143.68,-482.8772;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;4;-4234.785,1780.888;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StepOpNode;84;-1928.439,-343.06;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;40;-2441.558,2572.288;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;152;500.0573,-1883.73;Inherit;False;EmissionLightLiving;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-1549.145,-411.3083;Inherit;False;Property;_SecondPositionIntensity;Second Position Intensity;15;0;Create;True;0;0;False;0;0;0.08;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;52;-2819.69,-703.0253;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;33;-2676.409,2403.596;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-3707.351,3353.962;Inherit;False;Property;_Rim;Rim;6;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;7;-4280.708,2477.105;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;92;104.2773,-1861.722;Inherit;False;Property;_EmissionLightBarn;EmissionLightBarn;18;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-2257.464,-277.6025;Inherit;False;Property;_SecondPosition;Second Position;14;0;Create;True;0;0;False;0;0;0.26;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;71;-846.1943,-409.1797;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;22;-3742.549,3110.034;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;139.4107,-1475.037;Inherit;False;Property;_EmissionLightLiving;EmissionLightLiving;19;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;70;-1059.198,-277.541;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-2140.61,-657.7319;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;34;-2675.365,3003.622;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;16;-4057.801,3106.648;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;153;-2999.411,-4401.032;Inherit;False;151;EmissionLightBarn;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-3832.47,2453.982;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SmoothstepOpNode;35;-2413.786,2400.384;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.001;False;2;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-2285.578,-672.54;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;9;-3767.696,1682.746;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;18;-3372.856,2428.868;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-262.5234,-302.9348;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;47;-353.5523,-1024.216;Inherit;True;Property;_MainTexture;Main Texture;12;0;Create;True;0;0;False;0;-1;None;881ec4261bc362e479cc15e5bdf8f5c2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-3211.243,3107.55;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;37;-3179.953,1661.682;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;39;-2551.241,2180.115;Inherit;False;Property;_SpecularColor;Specular Color;9;1;[HDR];Create;True;0;0;False;0;0,0,0,0;3.670588,3.670588,3.670588,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightPos;6;-4084.192,1589.547;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;25;-3531.446,3109.999;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;-3647.332,3254.093;Inherit;False;15;LdotN;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-2132.93,2366.887;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalizeNode;14;-3631.527,2453.813;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;51;-2797.412,-564.1479;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;13;-4060.784,3292.339;Inherit;False;11;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;143;1462.735,-501.2421;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1856.113,-841.8466;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;PantryAndElements;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;158;0;157;3
WireConnection;158;1;157;0
WireConnection;159;0;155;0
WireConnection;159;1;156;0
WireConnection;161;0;159;0
WireConnection;161;1;158;0
WireConnection;161;2;160;0
WireConnection;112;0;161;0
WireConnection;115;0;111;0
WireConnection;115;1;134;0
WireConnection;116;0;113;0
WireConnection;116;1;114;0
WireConnection;116;2;114;0
WireConnection;117;0;115;0
WireConnection;119;1;113;0
WireConnection;119;0;116;0
WireConnection;120;0;118;0
WireConnection;120;1;119;0
WireConnection;121;0;120;0
WireConnection;125;0;124;0
WireConnection;125;1;123;0
WireConnection;125;2;122;0
WireConnection;126;0;125;0
WireConnection;145;0;144;0
WireConnection;146;0;145;0
WireConnection;75;0;71;0
WireConnection;75;1;74;0
WireConnection;77;0;75;0
WireConnection;77;1;76;0
WireConnection;77;2;81;0
WireConnection;30;0;23;0
WireConnection;30;1;9;0
WireConnection;94;0;47;0
WireConnection;36;0;29;0
WireConnection;36;1;32;0
WireConnection;36;2;31;0
WireConnection;87;0;47;0
WireConnection;147;0;142;0
WireConnection;96;1;94;0
WireConnection;96;2;95;0
WireConnection;136;0;134;0
WireConnection;136;1;100;0
WireConnection;91;1;87;0
WireConnection;91;2;92;0
WireConnection;24;0;17;2
WireConnection;24;1;18;0
WireConnection;80;0;79;0
WireConnection;11;0;8;0
WireConnection;26;0;19;0
WireConnection;26;1;19;0
WireConnection;49;0;47;0
WireConnection;49;1;77;0
WireConnection;151;0;92;0
WireConnection;140;1;136;0
WireConnection;140;2;154;0
WireConnection;141;0;153;0
WireConnection;141;1;139;0
WireConnection;142;0;141;0
WireConnection;142;1;140;0
WireConnection;45;0;41;0
WireConnection;45;1;44;0
WireConnection;45;2;43;0
WireConnection;45;3;42;0
WireConnection;83;0;82;0
WireConnection;31;0;27;0
WireConnection;85;0;84;0
WireConnection;130;0;132;0
WireConnection;130;1;131;0
WireConnection;15;0;9;0
WireConnection;5;0;3;0
WireConnection;139;0;134;0
WireConnection;139;1;88;0
WireConnection;72;0;71;0
WireConnection;8;0;4;0
WireConnection;43;0;38;0
WireConnection;43;1;34;0
WireConnection;43;2;36;0
WireConnection;81;0;80;0
WireConnection;28;0;21;0
WireConnection;28;1;20;0
WireConnection;129;0;130;0
WireConnection;48;0;46;0
WireConnection;48;1;45;0
WireConnection;32;0;27;0
WireConnection;99;0;91;0
WireConnection;99;1;96;0
WireConnection;53;0;52;0
WireConnection;53;1;51;0
WireConnection;41;0;37;0
WireConnection;41;1;17;0
WireConnection;82;0;58;0
WireConnection;82;1;61;0
WireConnection;67;0;85;0
WireConnection;67;1;66;0
WireConnection;69;0;83;0
WireConnection;84;0;58;0
WireConnection;84;1;56;0
WireConnection;152;0;95;0
WireConnection;33;0;24;0
WireConnection;33;1;26;0
WireConnection;71;0;69;0
WireConnection;71;1;70;0
WireConnection;22;0;16;0
WireConnection;22;1;13;0
WireConnection;70;0;67;0
WireConnection;58;0;55;0
WireConnection;58;1;54;0
WireConnection;10;0;5;0
WireConnection;10;1;7;1
WireConnection;35;0;33;0
WireConnection;55;0;53;0
WireConnection;9;0;6;1
WireConnection;9;1;8;0
WireConnection;18;0;11;0
WireConnection;18;1;14;0
WireConnection;74;0;72;0
WireConnection;74;1;73;0
WireConnection;29;0;25;0
WireConnection;29;1;28;0
WireConnection;37;0;30;0
WireConnection;25;0;22;0
WireConnection;44;0;39;0
WireConnection;44;1;35;0
WireConnection;44;2;40;0
WireConnection;14;0;10;0
WireConnection;143;0;128;0
WireConnection;143;1;146;0
WireConnection;0;0;128;0
WireConnection;0;13;143;0
ASEEND*/
//CHKSM=393E463269AC9636CC84B97A423DF4A731B32483