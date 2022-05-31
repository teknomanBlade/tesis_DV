// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "HouseFloor"
{
	Properties
	{
		_Albedo("Albedo", 2D) = "white" {}
		_MainColor2("Main Color", Color) = (0.6698113,0.6698113,0.6698113,0)
		_AmbientColor2("Ambient Color", Color) = (0.490566,0.490566,0.490566,0)
		[HDR]_RimColor2("Rim Color", Color) = (0,0,0,0)
		_Rim2("Rim", Range( 0 , 1)) = 0
		_Intensity1("Intensity", Float) = 0
		[HDR]_SpecularColor2("Specular Color", Color) = (0,0,0,0)
		_RimAmount2("Rim Amount", Range( 0 , 1)) = 0
		_Glossiness2("Glossiness", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
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

		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform sampler2D _Glossiness2;
		uniform float4 _Glossiness2_ST;
		uniform float4 _MainColor2;
		uniform float4 _SpecularColor2;
		uniform float _Intensity1;
		uniform float4 _RimColor2;
		uniform float _RimAmount2;
		uniform float _Rim2;
		uniform float4 _AmbientColor2;

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
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode1 = tex2D( _Albedo, uv_Albedo );
			float2 uv_Glossiness2 = i.uv_texcoord * _Glossiness2_ST.xy + _Glossiness2_ST.zw;
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 normalizeResult11 = normalize( ase_normWorldNormal );
			float dotResult13 = dot( _WorldSpaceLightPos0.xyz , normalizeResult11 );
			float smoothstepResult43 = smoothstep( 0.0 , 0.001 , ( ase_lightAtten * dotResult13 ));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 Normal14 = normalizeResult11;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult8 = normalize( ase_worldViewDir );
			float3 normalizeResult18 = normalize( ( normalizeResult8 + _WorldSpaceLightPos0.xyz ) );
			float dotResult24 = dot( Normal14 , normalizeResult18 );
			float smoothstepResult41 = smoothstep( 0.001 , 0.01 , pow( ( ase_lightColor.a * dotResult24 ) , ( _Intensity1 * _Intensity1 ) ));
			float3 temp_cast_1 = (( _RimAmount2 - 0.01 )).xxx;
			float3 temp_cast_2 = (( _RimAmount2 + 0.01 )).xxx;
			float dotResult21 = dot( ase_worldViewDir , Normal14 );
			float3 temp_cast_3 = (_Rim2).xxx;
			float3 smoothstepResult42 = smoothstep( temp_cast_1 , temp_cast_2 , ( ( 1.0 - dotResult21 ) * pow( Normal14 , temp_cast_3 ) ));
			c.rgb = ( tex2DNode1 * tex2D( _Glossiness2, uv_Glossiness2 ) * ( _MainColor2 * ( ( smoothstepResult43 * ase_lightColor ) + ( _SpecularColor2 * smoothstepResult41 * ase_lightAtten ) + ( _RimColor2 * ase_lightAtten * float4( smoothstepResult42 , 0.0 ) ) + _AmbientColor2 ) ) ).rgb;
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
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 tex2DNode1 = tex2D( _Albedo, uv_Albedo );
			o.Albedo = tex2DNode1.rgb;
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
390;232;1307;547;1566.899;1710.584;3.4078;True;False
Node;AmplifyShaderEditor.CommentaryNode;4;-2574.112,-909.886;Inherit;False;1670.493;552.806;Más su color;11;47;43;33;26;23;16;14;13;11;9;7;Dirección de la luz;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;5;-2631.368,-251.4006;Inherit;False;2366.779;547.9448;;14;46;41;40;37;36;30;27;24;22;18;12;10;8;6;Specular/Reflecciones;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;6;-2575.466,-87.38977;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;7;-2535.444,-600.6274;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;8;-2337.887,-80.01154;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;10;-2581.368,95.58984;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.NormalizeNode;11;-2290.831,-600.7755;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-2069.461,-472.0797;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;15;-2411.443,384.7238;Inherit;False;1969.371;712.1435;;15;45;42;39;38;35;34;32;31;29;28;25;21;20;19;17;Fresnel Manual;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-2133.13,72.46686;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;17;-2358.46,725.1327;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;18;-1932.186,72.29816;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;19;-2361.443,910.8247;Inherit;False;14;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;9;-2384.851,-791.968;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;25;-2008.01,972.4478;Inherit;False;Property;_Rim2;Rim;4;0;Create;True;0;0;False;0;0;0.517;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-1947.991,872.5787;Inherit;False;14;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;21;-2043.208,728.5188;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-1413.877,171.6027;Inherit;False;Property;_Intensity1;Intensity;5;0;Create;True;0;0;False;0;0;5.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;23;-1476.254,-558.9222;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.DotProductOpNode;24;-1673.515,47.35315;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;31;-1697.138,877.4478;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1205.527,163.5441;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1501.625,879.4528;Inherit;False;Property;_RimAmount2;Rim Amount;7;0;Create;True;0;0;False;0;0;0.599;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;29;-1832.105,728.4838;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;26;-2052.705,-847.3167;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;13;-2068.355,-698.7697;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-1366.829,23.50073;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-1511.902,726.0348;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-1833.017,-724.1274;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-1096.9,963.8667;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;-1114.9,827.8667;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;36;-977.0681,22.08136;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;43;-1480.612,-719.8337;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;42;-921.6941,714.2927;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;40;-851.9001,-201.4006;Inherit;False;Property;_SpecularColor2;Specular Color;6;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0.5849056,0.5849056,0.5849056,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;41;-714.4451,18.86932;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.001;False;2;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;38;-933.5081,436.5098;Inherit;False;Property;_RimColor2;Rim Color;3;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0.4245283,0.4245283,0.4245283,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;37;-669.394,182.1884;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;39;-926.0391,626.4838;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;44;-68.3241,53.30334;Inherit;False;Property;_AmbientColor2;Ambient Color;2;0;Create;True;0;0;False;0;0.490566,0.490566,0.490566,0;0.8113208,0.8113208,0.8113208,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-611.072,688.3597;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-433.5891,-14.62823;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-1072.619,-631.8832;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;48;71.72498,-632.1797;Inherit;False;Property;_MainColor2;Main Color;1;0;Create;True;0;0;False;0;0.6698113,0.6698113,0.6698113,0;0.735849,0.735849,0.735849,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;49;140.569,-372.9614;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;448.8918,-665.1212;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;52;81.22192,-1023.378;Inherit;True;Property;_Glossiness2;Glossiness;8;0;Create;True;0;0;False;0;-1;ab611d0bba8a0334ca5fac9eaaf7419f;ab611d0bba8a0334ca5fac9eaaf7419f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;133.0124,-1472.959;Inherit;True;Property;_Albedo;Albedo;0;0;Create;True;0;0;False;0;-1;ca91ff5f9642b2d44b991f0ff2884f73;1817af775e167f14fb474364efe7b52f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-1872.028,-583.0425;Inherit;False;LdotN;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;762.8657,-886.0182;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1584.092,-481.2162;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;HouseFloor;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;8;0;6;0
WireConnection;11;0;7;0
WireConnection;14;0;11;0
WireConnection;12;0;8;0
WireConnection;12;1;10;1
WireConnection;18;0;12;0
WireConnection;21;0;17;0
WireConnection;21;1;19;0
WireConnection;24;0;14;0
WireConnection;24;1;18;0
WireConnection;31;0;20;0
WireConnection;31;1;25;0
WireConnection;30;0;22;0
WireConnection;30;1;22;0
WireConnection;29;0;21;0
WireConnection;13;0;9;1
WireConnection;13;1;11;0
WireConnection;27;0;23;2
WireConnection;27;1;24;0
WireConnection;32;0;29;0
WireConnection;32;1;31;0
WireConnection;33;0;26;0
WireConnection;33;1;13;0
WireConnection;34;0;28;0
WireConnection;35;0;28;0
WireConnection;36;0;27;0
WireConnection;36;1;30;0
WireConnection;43;0;33;0
WireConnection;42;0;32;0
WireConnection;42;1;35;0
WireConnection;42;2;34;0
WireConnection;41;0;36;0
WireConnection;45;0;38;0
WireConnection;45;1;39;0
WireConnection;45;2;42;0
WireConnection;46;0;40;0
WireConnection;46;1;41;0
WireConnection;46;2;37;0
WireConnection;47;0;43;0
WireConnection;47;1;23;0
WireConnection;49;0;47;0
WireConnection;49;1;46;0
WireConnection;49;2;45;0
WireConnection;49;3;44;0
WireConnection;50;0;48;0
WireConnection;50;1;49;0
WireConnection;16;0;13;0
WireConnection;53;0;1;0
WireConnection;53;1;52;0
WireConnection;53;2;50;0
WireConnection;0;0;1;0
WireConnection;0;13;53;0
ASEEND*/
//CHKSM=03927540C79E7DCA9E9E332543E5DF1415E97E69