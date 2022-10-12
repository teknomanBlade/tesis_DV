// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "HouseDoorRgb"
{
	Properties
	{
		_TintColor("TintColor", Color) = (0.735849,0.735849,0.735849,0)
		_AmbientColor("Ambient Color", Color) = (0,0,0,0)
		[HDR]_RimColor("Rim Color", Color) = (0,0,0,0)
		_Door_Base_Color("Door_Base_Color", Color) = (0.9779412,0.9248784,0.2085316,0)
		_Rim("Rim", Range( 0 , 1)) = 0
		_Door_Border_Color("Door_Border_Color", Color) = (0.9632353,0.3477807,0.07082614,0)
		_Glossiness("Glossiness", Float) = 0
		_Door_Center_Color("Door_Center_Color", Color) = (0.07082614,0.1877624,0.9632353,0)
		[HDR]_SpecularColor("Specular Color", Color) = (0,0,0,0)
		_MainTexture("Main Texture", 2D) = "white" {}
		_RimAmount("Rim Amount", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float3 viewDir;
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

		uniform float4 _Door_Base_Color;
		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform float4 _Door_Border_Color;
		uniform float4 _Door_Center_Color;
		uniform float4 _TintColor;
		uniform float4 _SpecularColor;
		uniform float _Glossiness;
		uniform float4 _RimColor;
		uniform float _RimAmount;
		uniform float _Rim;
		uniform float4 _AmbientColor;

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
			float4 tex2DNode49 = tex2D( _MainTexture, uv_MainTexture );
			float3 ase_worldNormal = i.worldNormal;
			float3 normalizeResult5 = normalize( ase_worldNormal );
			float dotResult11 = dot( _WorldSpaceLightPos0.xyz , normalizeResult5 );
			float smoothstepResult38 = smoothstep( 0.0 , 0.001 , ( ase_lightAtten * dotResult11 ));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 Normal10 = normalizeResult5;
			float3 normalizeResult7 = normalize( i.viewDir );
			float3 normalizeResult14 = normalize( ( normalizeResult7 + _WorldSpaceLightPos0.xyz ) );
			float dotResult18 = dot( Normal10 , normalizeResult14 );
			float smoothstepResult35 = smoothstep( 0.001 , 0.01 , pow( ( ase_lightColor.a * dotResult18 ) , ( _Glossiness * _Glossiness ) ));
			float dotResult17 = dot( i.viewDir , Normal10 );
			float LdotN16 = dotResult11;
			float smoothstepResult40 = smoothstep( ( _RimAmount - 0.01 ) , ( _RimAmount + 0.01 ) , ( ( 1.0 - dotResult17 ) * pow( LdotN16 , _Rim ) ));
			c.rgb = saturate( ( ( ( _Door_Base_Color * tex2DNode49.r ) + ( _Door_Border_Color * tex2DNode49.g ) + ( tex2DNode49.b * _Door_Center_Color ) ) * ( _TintColor * ( ( smoothstepResult38 * ase_lightColor ) + ( _SpecularColor * smoothstepResult35 * ase_lightAtten ) + ( _RimColor * ase_lightAtten * smoothstepResult40 ) + _AmbientColor ) ) ) ).rgb;
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
				surfIN.viewDir = worldViewDir;
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
1927;51;1906;1001;2098.89;1845.388;1.6;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-3695.801,-641.7002;Inherit;False;1670.493;552.806;Más su color;11;41;38;31;25;21;16;11;10;6;5;3;Dirección de la luz;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;2;-3743.801,14.29961;Inherit;False;2366.779;547.9448;;14;44;39;36;35;29;27;26;19;18;14;9;8;7;4;Specular/Reflecciones;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;3;-3647.801,-337.7003;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;4;-3695.801,174.2996;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;5;-3407.801,-337.7003;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;6;-3503.801,-529.7002;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.NormalizeNode;7;-3455.801,190.2996;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;8;-3695.801,366.2996;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;12;-3519.801,654.2998;Inherit;False;1969.371;712.1435;;15;42;40;37;34;33;32;30;28;24;23;22;20;17;15;13;Fresnel Manual;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-3183.801,-209.7003;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;11;-3183.801,-433.7003;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-3247.801,334.2996;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;14;-3039.801,334.2996;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;-3471.801,1182.3;Inherit;False;10;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-2991.801,-321.7003;Inherit;False;LdotN;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;15;-3471.801,990.2998;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LightColorNode;21;-2591.801,-289.7003;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.DotProductOpNode;17;-3151.801,990.2998;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;18;-2783.801,318.2996;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2527.801,446.2997;Inherit;False;Property;_Glossiness;Glossiness;6;0;Create;True;0;0;False;0;0;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-3055.801,1134.3;Inherit;False;16;LdotN;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-3119.801,1246.3;Inherit;False;Property;_Rim;Rim;4;0;Create;True;0;0;False;0;0;0.328;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-2623.801,1150.3;Inherit;False;Property;_RimAmount;Rim Amount;10;0;Create;True;0;0;False;0;0;0.366;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;25;-3167.801,-561.7002;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-2319.801,430.2997;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-2479.801,286.2996;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;24;-2943.801,990.2998;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;23;-2815.801,1150.3;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;29;-2095.801,286.2996;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-2207.801,1230.3;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-2943.801,-449.7003;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;32;-2223.801,1102.3;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-2623.801,990.2998;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;37;-2047.801,702.2998;Inherit;False;Property;_RimColor;Rim Color;2;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0.4433962,0.4433962,0.4433962,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;40;-2031.801,990.2998;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;39;-1839.801,446.2997;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;38;-2591.801,-449.7003;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;36;-1967.801,62.29961;Inherit;False;Property;_SpecularColor;Specular Color;8;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0.4433962,0.4433962,0.4433962,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;35;-1823.801,286.2996;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.001;False;2;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;34;-2047.801,894.2998;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;64;-1141.87,-659.2891;Float;False;Property;_Door_Center_Color;Door_Center_Color;7;0;Create;True;0;0;False;0;0.07082614,0.1877624,0.9632353,0;0.1981132,0.1981132,0.1981132,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;43;-1183.801,318.2996;Inherit;False;Property;_AmbientColor;Ambient Color;1;0;Create;True;0;0;False;0;0,0,0,0;0.6320754,0.6320754,0.6320754,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;61;-1164.947,-1009.859;Float;False;Property;_Door_Border_Color;Door_Border_Color;5;0;Create;True;0;0;False;0;0.9632353,0.3477807,0.07082614,0;1,0.1462264,0.1462264,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-1551.801,254.2996;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-2191.801,-369.7003;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-1727.801,958.2998;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;63;-1141.724,-1322.817;Float;False;Property;_Door_Base_Color;Door_Base_Color;3;0;Create;True;0;0;False;0;0.9779412,0.9248784,0.2085316,0;1,0,0,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;49;-1756.501,-906.6935;Inherit;True;Property;_MainTexture;Main Texture;9;0;Create;True;0;0;False;0;-1;2ec3aff22090c1248aa82b65522cb127;c7882111acf7cd740af5593bba17abdd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-975.8013,-97.7004;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-867.6214,-920.6875;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-874.9557,-1174.209;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-856.2104,-668.4178;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;46;-1039.801,-369.7003;Inherit;False;Property;_TintColor;TintColor;0;0;Create;True;0;0;False;0;0.735849,0.735849,0.735849,0;0.2392157,0.2392157,0.2392157,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-623.8011,-353.7003;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;68;-646.6548,-666.5328;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-303.8011,-385.7003;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;56;-143.8013,-305.7003;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;278.2,-812.7;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;HouseDoorRgb;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;0;3;0
WireConnection;7;0;4;0
WireConnection;10;0;5;0
WireConnection;11;0;6;1
WireConnection;11;1;5;0
WireConnection;9;0;7;0
WireConnection;9;1;8;1
WireConnection;14;0;9;0
WireConnection;16;0;11;0
WireConnection;17;0;15;0
WireConnection;17;1;13;0
WireConnection;18;0;10;0
WireConnection;18;1;14;0
WireConnection;27;0;19;0
WireConnection;27;1;19;0
WireConnection;26;0;21;2
WireConnection;26;1;18;0
WireConnection;24;0;17;0
WireConnection;23;0;20;0
WireConnection;23;1;22;0
WireConnection;29;0;26;0
WireConnection;29;1;27;0
WireConnection;30;0;28;0
WireConnection;31;0;25;0
WireConnection;31;1;11;0
WireConnection;32;0;28;0
WireConnection;33;0;24;0
WireConnection;33;1;23;0
WireConnection;40;0;33;0
WireConnection;40;1;32;0
WireConnection;40;2;30;0
WireConnection;38;0;31;0
WireConnection;35;0;29;0
WireConnection;44;0;36;0
WireConnection;44;1;35;0
WireConnection;44;2;39;0
WireConnection;41;0;38;0
WireConnection;41;1;21;0
WireConnection;42;0;37;0
WireConnection;42;1;34;0
WireConnection;42;2;40;0
WireConnection;45;0;41;0
WireConnection;45;1;44;0
WireConnection;45;2;42;0
WireConnection;45;3;43;0
WireConnection;66;0;61;0
WireConnection;66;1;49;2
WireConnection;65;0;63;0
WireConnection;65;1;49;1
WireConnection;67;0;49;3
WireConnection;67;1;64;0
WireConnection;52;0;46;0
WireConnection;52;1;45;0
WireConnection;68;0;65;0
WireConnection;68;1;66;0
WireConnection;68;2;67;0
WireConnection;55;0;68;0
WireConnection;55;1;52;0
WireConnection;56;0;55;0
WireConnection;0;13;56;0
ASEEND*/
//CHKSM=6C47DDCF294038146D2D31B391A71A701D16330B