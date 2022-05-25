// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ToonShadowsGrayDeath"
{
	Properties
	{
		_TintColor1("TintColor", Color) = (0.735849,0.735849,0.735849,0)
		_AmbientColor1("Ambient Color", Color) = (0,0,0,0)
		[HDR]_RimColor1("Rim Color", Color) = (0,0,0,0)
		_Rim1("Rim", Range( 0 , 1)) = 0
		_Glossiness1("Glossiness", Float) = 0
		[HDR]_SpecularColor1("Specular Color", Color) = (0,0,0,0)
		_MainTexture1("Main Texture", 2D) = "white" {}
		_RimAmount1("Rim Amount", Range( 0 , 1)) = 0
		_TeleportDeathVal("TeleportDeathVal", Float) = 0
		_Transparency("Transparency", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" }
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

		uniform float _TeleportDeathVal;
		uniform float _Transparency;
		uniform sampler2D _MainTexture1;
		uniform float4 _MainTexture1_ST;
		uniform float4 _TintColor1;
		uniform float4 _SpecularColor1;
		uniform float _Glossiness1;
		uniform float4 _RimColor1;
		uniform float _RimAmount1;
		uniform float _Rim1;
		uniform float4 _AmbientColor1;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertex3Pos = v.vertex.xyz;
			float4 appendResult57 = (float4(( _TeleportDeathVal + ( ase_vertex3Pos.y * ase_vertex3Pos.z * _TeleportDeathVal ) ) , 0.0 , 0.0 , 0.0));
			v.vertex.xyz += appendResult57.xyz;
		}

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
			float2 uv_MainTexture1 = i.uv_texcoord * _MainTexture1_ST.xy + _MainTexture1_ST.zw;
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
			float smoothstepResult35 = smoothstep( 0.001 , 0.01 , pow( ( ase_lightColor.a * dotResult18 ) , ( _Glossiness1 * _Glossiness1 ) ));
			float dotResult17 = dot( i.viewDir , Normal10 );
			float LdotN16 = dotResult11;
			float smoothstepResult40 = smoothstep( ( _RimAmount1 - 0.01 ) , ( _RimAmount1 + 0.01 ) , ( ( 1.0 - dotResult17 ) * pow( LdotN16 , _Rim1 ) ));
			c.rgb = saturate( ( tex2D( _MainTexture1, uv_MainTexture1 ) * ( _TintColor1 * ( ( smoothstepResult38 * ase_lightColor ) + ( _SpecularColor1 * smoothstepResult35 * ase_lightAtten ) + ( _RimColor1 * ase_lightAtten * smoothstepResult40 ) + _AmbientColor1 ) ) ) ).rgb;
			c.a = ( 1.0 - ( _TeleportDeathVal * _Transparency ) );
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
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

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
			sampler3D _DitherMaskLOD;
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
				vertexDataFunc( v, customInputData );
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
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
324;305;1307;537;-777.0272;469.9062;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;2;-1969.617,-233.103;Inherit;False;2366.779;547.9448;;14;44;39;36;35;29;27;26;19;18;14;9;8;7;4;Specular/Reflecciones;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1;-1921.617,-889.103;Inherit;False;1670.493;552.806;Más su color;11;41;38;31;25;21;16;11;10;6;5;3;Dirección de la luz;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;3;-1873.617,-585.103;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;4;-1921.617,-73.10304;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;5;-1633.617,-585.103;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;6;-1729.617,-777.103;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.NormalizeNode;7;-1681.617,-57.10304;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;8;-1921.617,118.897;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-1473.617,86.89696;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-1409.617,-457.103;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;11;-1409.617,-681.103;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;12;-1745.617,406.897;Inherit;False;1969.371;712.1435;;15;42;40;37;34;33;32;30;28;24;23;22;20;17;15;13;Fresnel Manual;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;15;-1697.617,742.897;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-1217.617,-569.103;Inherit;False;LdotN;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;14;-1265.617,86.89696;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;-1697.617,934.897;Inherit;False;10;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;17;-1377.617,742.897;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;18;-1009.617,70.89696;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-753.6166,198.897;Inherit;False;Property;_Glossiness1;Glossiness;5;0;Create;True;0;0;False;0;0;7.78;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-1281.617,886.897;Inherit;False;16;LdotN;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;21;-817.6166,-537.103;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;22;-1345.617,998.897;Inherit;False;Property;_Rim1;Rim;4;0;Create;True;0;0;False;0;0;0.679;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;23;-1041.617,902.897;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;24;-1169.617,742.897;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;25;-1393.617,-809.103;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-705.6166,38.89696;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-545.6166,182.897;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-849.6166,902.897;Inherit;False;Property;_RimAmount1;Rim Amount;8;0;Create;True;0;0;False;0;0;0.53;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-1169.617,-697.103;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;29;-321.6166,38.89696;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;32;-449.6166,854.897;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-849.6166,742.897;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;-433.6166,982.897;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;34;-273.6166,646.897;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;35;-49.61658,38.89696;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.001;False;2;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;36;-193.6166,-185.103;Inherit;False;Property;_SpecularColor1;Specular Color;6;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0.1215686,0.4313726,0.4470588,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;37;-273.6166,454.897;Inherit;False;Property;_RimColor1;Rim Color;3;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;38;-817.6166,-697.103;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;39;-65.61658,198.897;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;40;-257.6166,742.897;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;43;590.3834,70.89696;Inherit;False;Property;_AmbientColor1;Ambient Color;2;0;Create;True;0;0;False;0;0,0,0,0;0,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-417.6166,-617.103;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;222.3834,6.896957;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;46.38342,710.897;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;47;974.3834,117.4721;Inherit;False;Property;_TeleportDeathVal;TeleportDeathVal;9;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;46;734.3834,-617.103;Inherit;False;Property;_TintColor1;TintColor;1;0;Create;True;0;0;False;0;0.735849,0.735849,0.735849,0;0,0.8271301,0.8679245,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;45;798.3834,-345.103;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;48;862.3834,-105.103;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;49;910.3834,-969.103;Inherit;True;Property;_MainTexture1;Main Texture;7;0;Create;True;0;0;False;0;-1;2ec3aff22090c1248aa82b65522cb127;2ec3aff22090c1248aa82b65522cb127;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;1134.383,-185.103;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;1150.383,-601.103;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;50;1022.383,278.897;Inherit;False;Property;_Transparency;Transparency;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;1278.383,54.89696;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;53;1326.383,-201.103;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;1470.383,-633.103;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;58;1504.907,-41.10304;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;56;1630.383,-553.103;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;57;1518.383,-265.103;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1927.567,-399.0755;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;ToonShadowsGrayDeath;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;0;3;0
WireConnection;7;0;4;0
WireConnection;9;0;7;0
WireConnection;9;1;8;1
WireConnection;10;0;5;0
WireConnection;11;0;6;1
WireConnection;11;1;5;0
WireConnection;16;0;11;0
WireConnection;14;0;9;0
WireConnection;17;0;15;0
WireConnection;17;1;13;0
WireConnection;18;0;10;0
WireConnection;18;1;14;0
WireConnection;23;0;20;0
WireConnection;23;1;22;0
WireConnection;24;0;17;0
WireConnection;26;0;21;2
WireConnection;26;1;18;0
WireConnection;27;0;19;0
WireConnection;27;1;19;0
WireConnection;31;0;25;0
WireConnection;31;1;11;0
WireConnection;29;0;26;0
WireConnection;29;1;27;0
WireConnection;32;0;28;0
WireConnection;33;0;24;0
WireConnection;33;1;23;0
WireConnection;30;0;28;0
WireConnection;35;0;29;0
WireConnection;38;0;31;0
WireConnection;40;0;33;0
WireConnection;40;1;32;0
WireConnection;40;2;30;0
WireConnection;41;0;38;0
WireConnection;41;1;21;0
WireConnection;44;0;36;0
WireConnection;44;1;35;0
WireConnection;44;2;39;0
WireConnection;42;0;37;0
WireConnection;42;1;34;0
WireConnection;42;2;40;0
WireConnection;45;0;41;0
WireConnection;45;1;44;0
WireConnection;45;2;42;0
WireConnection;45;3;43;0
WireConnection;51;0;48;2
WireConnection;51;1;48;3
WireConnection;51;2;47;0
WireConnection;52;0;46;0
WireConnection;52;1;45;0
WireConnection;54;0;47;0
WireConnection;54;1;50;0
WireConnection;53;0;47;0
WireConnection;53;1;51;0
WireConnection;55;0;49;0
WireConnection;55;1;52;0
WireConnection;58;0;54;0
WireConnection;56;0;55;0
WireConnection;57;0;53;0
WireConnection;0;9;58;0
WireConnection;0;13;56;0
WireConnection;0;11;57;0
ASEEND*/
//CHKSM=6D99F5ADBF03994C88541E8780DD20E7A138E080