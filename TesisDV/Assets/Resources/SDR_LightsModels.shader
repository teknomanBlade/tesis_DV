// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SDR_LightsModels"
{
	Properties
	{
		_Levels("Levels", Range( 0 , 100)) = 71
		_Tint("Tint", Color) = (0,0,0,0)
		_LightIntensity("LightIntensity", Range( 0 , 5)) = 0
		_TrimSheetPropsTex("TrimSheetPropsTex", 2D) = "white" {}
		_OpacityMap_TrimSheetProps("OpacityMap_TrimSheetProps", 2D) = "white" {}
		_TrimSheetProps_LivingLightEmission("TrimSheetProps_LivingLightEmission", 2D) = "white" {}
		_EmissionLightBarn("EmissionLightBarn", Range( 0 , 1)) = 0
		_EmissionLightLiving("EmissionLightLiving", Range( 0 , 1)) = 0
		_LerpLightDir("LerpLightDir", Range( 0 , 1)) = 0
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
		#pragma target 4.0
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

		uniform sampler2D _TrimSheetPropsTex;
		uniform float4 _TrimSheetPropsTex_ST;
		uniform sampler2D _OpacityMap_TrimSheetProps;
		uniform float4 _OpacityMap_TrimSheetProps_ST;
		uniform float _EmissionLightBarn;
		uniform sampler2D _TrimSheetProps_LivingLightEmission;
		uniform float4 _TrimSheetProps_LivingLightEmission_ST;
		uniform float _EmissionLightLiving;
		uniform float4 _Tint;
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
			float4 tex2DNode8 = tex2D( _TrimSheetPropsTex, uv_TrimSheetPropsTex );
			float4 Albedo13 = ( _Tint * tex2DNode8 );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult54 = dot( ase_worldNormal , ase_worldlightDir );
			float3 temp_cast_1 = (ase_worldlightDir.z).xxx;
			float dotResult53 = dot( temp_cast_1 , ase_worldlightDir );
			float lerpResult55 = lerp( dotResult54 , dotResult53 , _LerpLightDir);
			float Normal_LightDir9 = lerpResult55;
			float4 temp_cast_3 = (Normal_LightDir9).xxxx;
			float div15=256.0/float((int)(Normal_LightDir9*_Levels + _Levels));
			float4 posterize15 = ( floor( temp_cast_3 * div15 ) / div15 );
			float4 Shadow18 = ( Albedo13 * posterize15 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 LightColor23 = ( Shadow18 * ase_lightColor * _LightIntensity );
			c.rgb = ( LightColor23 * ( 1.0 - step( ase_lightAtten , 0.0 ) ) ).rgb;
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
			float4 tex2DNode8 = tex2D( _TrimSheetPropsTex, uv_TrimSheetPropsTex );
			float2 uv_OpacityMap_TrimSheetProps = i.uv_texcoord * _OpacityMap_TrimSheetProps_ST.xy + _OpacityMap_TrimSheetProps_ST.zw;
			float4 lerpResult33 = lerp( float4( 0,0,0,0 ) , ( tex2DNode8 * tex2D( _OpacityMap_TrimSheetProps, uv_OpacityMap_TrimSheetProps ) ) , _EmissionLightBarn);
			float2 uv_TrimSheetProps_LivingLightEmission = i.uv_texcoord * _TrimSheetProps_LivingLightEmission_ST.xy + _TrimSheetProps_LivingLightEmission_ST.zw;
			float4 lerpResult32 = lerp( float4( 0,0,0,0 ) , ( tex2DNode8 * tex2D( _TrimSheetProps_LivingLightEmission, uv_TrimSheetProps_LivingLightEmission ) ) , _EmissionLightLiving);
			float4 LightEmission35 = ( lerpResult33 + lerpResult32 );
			o.Emission = LightEmission35.rgb;
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
			#pragma target 4.0
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
360;701;1307;593;4077.048;-273.1938;1;True;False
Node;AmplifyShaderEditor.WorldNormalVector;51;-4091.94,117.8887;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;50;-4107.941,277.8887;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;49;-4064.238,635.1558;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;54;-3867.94,165.8887;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;53;-3801.978,427.7508;Inherit;True;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-3810.22,704.7728;Inherit;False;Property;_LerpLightDir;LerpLightDir;8;0;Create;True;0;0;False;0;0;0.542;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1;-4159.296,-6.853073;Inherit;False;1043.67;899.7814;Normal LightDir;1;9;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;4;-3361.926,-1519.306;Inherit;False;2295.056;1208.044;Albedo;14;36;35;34;33;32;30;26;25;13;10;8;7;45;46;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;55;-3502.161,326.3118;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;-0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-3318.399,396.4144;Inherit;False;Normal_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-3281.472,-674.832;Inherit;True;Property;_TrimSheetPropsTex;TrimSheetPropsTex;3;0;Create;True;0;0;False;0;-1;None;881ec4261bc362e479cc15e5bdf8f5c2;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;7;-2083.026,-1431.656;Inherit;False;Property;_Tint;Tint;1;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;6;-2781.056,167.637;Inherit;False;1371.36;494.1964;Shadow;8;17;16;15;14;12;11;48;18;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;11;-2767.412,377.2764;Inherit;False;9;Normal_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-2778.993,511.0515;Inherit;False;Property;_Levels;Levels;0;0;Create;True;0;0;False;0;71;11;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-1772.399,-1279.229;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;14;-2448.936,429.4123;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-1437.783,-1099.118;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;15;-2221.985,374.8156;Inherit;True;30;2;1;COLOR;0,0,0,0;False;0;INT;30;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;-2241.572,235.5129;Inherit;False;13;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;-1931.269,270.358;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;30;-3297.184,-1063.753;Inherit;True;Property;_TrimSheetProps_LivingLightEmission;TrimSheetProps_LivingLightEmission;5;0;Create;True;0;0;False;0;-1;b85bbfc6ffeeab549a8949fddb6f3885;b85bbfc6ffeeab549a8949fddb6f3885;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;18;-1619.06,325.9821;Inherit;False;Shadow;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;26;-3305.924,-1384.422;Inherit;True;Property;_OpacityMap_TrimSheetProps;OpacityMap_TrimSheetProps;4;0;Create;True;0;0;False;0;-1;2a2ea88b54a5fd348ab6b864b3e826b7;2a2ea88b54a5fd348ab6b864b3e826b7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;20;-2495.869,1073.235;Inherit;False;Property;_LightIntensity;LightIntensity;2;0;Create;True;0;0;False;0;0;2.4;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;19;-2379.371,778.094;Inherit;False;18;Shadow;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-2782.13,-958.2161;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;21;-2501.006,901.8159;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;45;-2795.994,-1432.157;Inherit;False;Property;_EmissionLightBarn;EmissionLightBarn;6;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-2782.728,-683.7196;Inherit;False;Property;_EmissionLightLiving;EmissionLightLiving;7;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-2785.779,-1307.819;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-2108.655,887.176;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;39;-717.9777,335.756;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;32;-2396.307,-900.9875;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;33;-2478.894,-1277.31;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;40;-413.3332,185.3817;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-2074.595,-1064.743;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1580.547,865.97;Inherit;False;LightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;42;-218.5415,-141.7016;Inherit;True;23;LightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;41;-131.7863,156.5579;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-1593.216,-742.7561;Inherit;False;LightEmission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;24;-3873.58,987.5839;Inherit;False;787.1289;475.5013;Normal ViewDir;4;37;29;28;27;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;28;-3806.793,1045.006;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;56;-4051.418,459.2547;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;37;-3573.419,1081.334;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-3283.159,1188.997;Inherit;False;Normal_ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;108.5486,49.41398;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-31.72203,-383.2223;Inherit;False;35;LightEmission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;27;-3798.357,1242.085;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;48;-2652.866,261.8296;Inherit;False;29;Normal_ViewDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;381.6267,-61.79113;Float;False;True;-1;4;ASEMaterialInspector;0;0;CustomLighting;SDR_LightsModels;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;54;0;51;0
WireConnection;54;1;50;0
WireConnection;53;0;49;3
WireConnection;53;1;49;0
WireConnection;55;0;54;0
WireConnection;55;1;53;0
WireConnection;55;2;52;0
WireConnection;9;0;55;0
WireConnection;10;0;7;0
WireConnection;10;1;8;0
WireConnection;14;0;11;0
WireConnection;14;1;12;0
WireConnection;14;2;12;0
WireConnection;13;0;10;0
WireConnection;15;1;11;0
WireConnection;15;0;14;0
WireConnection;17;0;16;0
WireConnection;17;1;15;0
WireConnection;18;0;17;0
WireConnection;25;0;8;0
WireConnection;25;1;30;0
WireConnection;36;0;8;0
WireConnection;36;1;26;0
WireConnection;22;0;19;0
WireConnection;22;1;21;0
WireConnection;22;2;20;0
WireConnection;32;1;25;0
WireConnection;32;2;46;0
WireConnection;33;1;36;0
WireConnection;33;2;45;0
WireConnection;40;0;39;0
WireConnection;34;0;33;0
WireConnection;34;1;32;0
WireConnection;23;0;22;0
WireConnection;41;0;40;0
WireConnection;35;0;34;0
WireConnection;37;0;28;0
WireConnection;37;1;27;0
WireConnection;29;0;37;0
WireConnection;43;0;42;0
WireConnection;43;1;41;0
WireConnection;0;2;44;0
WireConnection;0;13;43;0
ASEEND*/
//CHKSM=70BC398A125EE73E0F1E66185BCF69A2E4BBB6D7