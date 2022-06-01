// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "HouseFloor"
{
	Properties
	{
		_TintColor("TintColor", Color) = (0.735849,0.735849,0.735849,0)
		_AmbientColor("Ambient Color", Color) = (0,0,0,0)
		[HDR]_RimColor("Rim Color", Color) = (0,0,0,0)
		_Rim("Rim", Range( 0 , 1)) = 0
		_Glossiness("Glossiness", Float) = 0
		[HDR]_SpecularColor("Specular Color", Color) = (0,0,0,0)
		_MainTexture("Main Texture", 2D) = "white" {}
		_RimAmount("Rim Amount", Range( 0 , 1)) = 0
		_Specular("Specular", 2D) = "white" {}
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

		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform sampler2D _Specular;
		uniform float4 _Specular_ST;
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
			float2 uv_Specular = i.uv_texcoord * _Specular_ST.xy + _Specular_ST.zw;
			float3 ase_worldNormal = i.worldNormal;
			float3 normalizeResult59 = normalize( ase_worldNormal );
			float dotResult66 = dot( _WorldSpaceLightPos0.xyz , normalizeResult59 );
			float smoothstepResult88 = smoothstep( 0.0 , 0.001 , ( ase_lightAtten * dotResult66 ));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 Normal65 = normalizeResult59;
			float3 normalizeResult61 = normalize( i.viewDir );
			float3 normalizeResult67 = normalize( ( normalizeResult61 + _WorldSpaceLightPos0.xyz ) );
			float dotResult72 = dot( Normal65 , normalizeResult67 );
			float smoothstepResult93 = smoothstep( 0.001 , 0.01 , pow( ( ase_lightColor.a * dotResult72 ) , ( _Glossiness * _Glossiness ) ));
			float dotResult71 = dot( i.viewDir , Normal65 );
			float LdotN68 = dotResult66;
			float smoothstepResult89 = smoothstep( ( _RimAmount - 0.01 ) , ( _RimAmount + 0.01 ) , ( ( 1.0 - dotResult71 ) * pow( LdotN68 , _Rim ) ));
			c.rgb = saturate( ( tex2D( _MainTexture, uv_MainTexture ) * tex2D( _Specular, uv_Specular ) * ( _TintColor * ( ( smoothstepResult88 * ase_lightColor ) + ( _SpecularColor * smoothstepResult93 * ase_lightAtten ) + ( _RimColor * ase_lightAtten * smoothstepResult89 ) + _AmbientColor ) ) ) ).rgb;
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
118;221;1307;547;3088.833;-299.8023;1.872728;True;False
Node;AmplifyShaderEditor.CommentaryNode;55;-2610.762,-959.2921;Inherit;False;1670.493;552.806;Más su color;11;95;88;83;78;75;68;66;65;60;59;57;Dirección de la luz;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;56;-2658.762,-303.2922;Inherit;False;2366.779;547.9448;;14;98;93;92;90;85;82;81;73;72;67;64;62;61;58;Specular/Reflecciones;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;57;-2562.762,-655.2922;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;58;-2610.762,-143.2922;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;61;-2370.762,-127.2922;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;59;-2322.762,-655.2922;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;62;-2610.762,48.70796;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.WorldSpaceLightPos;60;-2418.762,-847.2921;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-2162.762,16.70786;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-2098.762,-527.2923;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;63;-2434.762,336.7083;Inherit;False;1969.371;712.1435;;15;97;94;91;89;87;86;84;80;79;77;76;74;71;70;69;Fresnel Manual;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;66;-2098.762,-751.2922;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;70;-2386.762,672.7081;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;67;-1954.762,16.70786;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;-1906.762,-639.2922;Inherit;False;LdotN;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-2386.762,864.7079;Inherit;False;65;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;71;-2066.762,672.7081;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-2034.762,928.7079;Inherit;False;Property;_Rim;Rim;3;0;Create;True;0;0;False;0;0;0.722;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;-1947.762,798.7079;Inherit;False;68;LdotN;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-1442.762,128.708;Inherit;False;Property;_Glossiness;Glossiness;4;0;Create;True;0;0;False;0;0;3.88;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;75;-1506.762,-607.2923;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.DotProductOpNode;72;-1698.762,0.7078571;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;77;-1858.763,672.7081;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;79;-1730.762,832.7079;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;78;-2082.762,-879.2921;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-1538.762,832.7079;Inherit;False;Property;_RimAmount;Rim Amount;7;0;Create;True;0;0;False;0;0;0.636;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-1234.762,112.708;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-1394.762,-31.29213;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;86;-1122.762,912.7079;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-1538.762,672.7081;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;84;-1138.762,784.7079;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;85;-1010.762,-31.29213;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-1858.763,-767.2922;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;94;-962.7623,384.7084;Inherit;False;Property;_RimColor;Rim Color;2;1;[HDR];Create;True;0;0;False;0;0,0,0,0;16,16,16,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;88;-1506.762,-767.2922;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;92;-754.7623,128.708;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;89;-946.7623,672.7081;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;90;-882.7622,-255.2921;Inherit;False;Property;_SpecularColor;Specular Color;5;1;[HDR];Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;93;-738.7623,-31.29213;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.001;False;2;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;91;-962.7623,576.7081;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;96;-98.76218,-0.2921276;Inherit;False;Property;_AmbientColor;Ambient Color;1;0;Create;True;0;0;False;0;0,0,0,0;0.6981132,0.6981132,0.6981132,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-642.7623,640.7081;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-1106.762,-687.2922;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;98;-466.7623,-63.29213;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;99;45.23799,-687.2922;Inherit;False;Property;_TintColor;TintColor;0;0;Create;True;0;0;False;0;0.735849,0.735849,0.735849,0;0.754717,0.754717,0.754717,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;100;109.238,-415.2922;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;461.2379,-671.2922;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;105;230.3218,-976.5573;Inherit;True;Property;_Specular;Specular;8;0;Create;True;0;0;False;0;-1;None;ef03d3080a916604cb5d2116ab22e07d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;101;206.0383,-1242.754;Inherit;True;Property;_MainTexture;Main Texture;6;0;Create;True;0;0;False;0;-1;2ec3aff22090c1248aa82b65522cb127;1817af775e167f14fb474364efe7b52f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;739.2697,-721.9447;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;104;1028.622,-519.6592;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1584.092,-481.2162;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;HouseFloor;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;61;0;58;0
WireConnection;59;0;57;0
WireConnection;64;0;61;0
WireConnection;64;1;62;1
WireConnection;65;0;59;0
WireConnection;66;0;60;1
WireConnection;66;1;59;0
WireConnection;67;0;64;0
WireConnection;68;0;66;0
WireConnection;71;0;70;0
WireConnection;71;1;69;0
WireConnection;72;0;65;0
WireConnection;72;1;67;0
WireConnection;77;0;71;0
WireConnection;79;0;74;0
WireConnection;79;1;76;0
WireConnection;82;0;73;0
WireConnection;82;1;73;0
WireConnection;81;0;75;2
WireConnection;81;1;72;0
WireConnection;86;0;80;0
WireConnection;87;0;77;0
WireConnection;87;1;79;0
WireConnection;84;0;80;0
WireConnection;85;0;81;0
WireConnection;85;1;82;0
WireConnection;83;0;78;0
WireConnection;83;1;66;0
WireConnection;88;0;83;0
WireConnection;89;0;87;0
WireConnection;89;1;84;0
WireConnection;89;2;86;0
WireConnection;93;0;85;0
WireConnection;97;0;94;0
WireConnection;97;1;91;0
WireConnection;97;2;89;0
WireConnection;95;0;88;0
WireConnection;95;1;75;0
WireConnection;98;0;90;0
WireConnection;98;1;93;0
WireConnection;98;2;92;0
WireConnection;100;0;95;0
WireConnection;100;1;98;0
WireConnection;100;2;97;0
WireConnection;100;3;96;0
WireConnection;102;0;99;0
WireConnection;102;1;100;0
WireConnection;103;0;101;0
WireConnection;103;1;105;0
WireConnection;103;2;102;0
WireConnection;104;0;103;0
WireConnection;0;13;104;0
ASEEND*/
//CHKSM=447FDB2E6CD12C8E244064669AE373C4B7779F65