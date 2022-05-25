// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "RacketToon"
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

		uniform sampler2D _MainTexture1;
		uniform float4 _MainTexture1_ST;
		uniform float4 _TintColor1;
		uniform float4 _SpecularColor1;
		uniform float _Glossiness1;
		uniform float4 _RimColor1;
		uniform float _RimAmount1;
		uniform float _Rim1;
		uniform float4 _AmbientColor1;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_MainTexture1 = i.uv_texcoord * _MainTexture1_ST.xy + _MainTexture1_ST.zw;
			float3 ase_worldNormal = i.worldNormal;
			float3 normalizeResult5 = normalize( ase_worldNormal );
			float dotResult11 = dot( _WorldSpaceLightPos0.xyz , normalizeResult5 );
			float smoothstepResult36 = smoothstep( 0.0 , 0.001 , ( 0.0 * dotResult11 ));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 Normal10 = normalizeResult5;
			float3 normalizeResult7 = normalize( i.viewDir );
			float3 normalizeResult14 = normalize( ( normalizeResult7 + _WorldSpaceLightPos0.xyz ) );
			float dotResult18 = dot( Normal10 , normalizeResult14 );
			float smoothstepResult33 = smoothstep( 0.001 , 0.01 , pow( ( ase_lightColor.a * dotResult18 ) , ( _Glossiness1 * _Glossiness1 ) ));
			float dotResult17 = dot( i.viewDir , Normal10 );
			float LdotN16 = dotResult11;
			float smoothstepResult37 = smoothstep( ( _RimAmount1 - 0.01 ) , ( _RimAmount1 + 0.01 ) , ( ( 1.0 - dotResult17 ) * pow( LdotN16 , _Rim1 ) ));
			c.rgb = saturate( ( tex2D( _MainTexture1, uv_MainTexture1 ) * ( _TintColor1 * ( ( smoothstepResult36 * ase_lightColor ) + ( _SpecularColor1 * smoothstepResult33 ) + ( _RimColor1 * float4( 0,0,0,0 ) * smoothstepResult37 ) + _AmbientColor1 ) ) ) ).rgb;
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
360;181;1307;543;2401.421;887.5573;3.0642;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-3512.605,-700.3964;Inherit;False;1670.493;552.806;Más su color;10;38;36;30;21;16;11;10;6;5;3;Dirección de la luz;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;2;-3560.605,-44.39636;Inherit;False;2366.779;547.9448;;13;41;34;33;28;26;25;19;18;14;9;8;7;4;Specular/Reflecciones;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;3;-3464.605,-396.3964;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;4;-3512.605,115.6036;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;5;-3224.605,-396.3964;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;6;-3320.605,-588.3964;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.NormalizeNode;7;-3272.605,131.6036;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;8;-3512.605,307.6036;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-3064.605,275.6036;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-3000.605,-268.3964;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;11;-3000.605,-492.3964;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;12;-3336.605,595.6036;Inherit;False;1969.371;712.1435;;14;39;37;35;32;31;29;27;24;23;22;20;17;15;13;Fresnel Manual;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-2808.605,-380.3964;Inherit;False;LdotN;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;15;-3288.605,931.6036;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;13;-3288.605,1123.604;Inherit;False;10;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;14;-2856.605,275.6036;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;17;-2968.605,931.6036;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;18;-2600.605,259.6036;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2344.605,387.6036;Inherit;False;Property;_Glossiness1;Glossiness;4;0;Create;True;0;0;False;0;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-2872.605,1075.604;Inherit;False;16;LdotN;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;21;-2408.605,-348.3964;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;22;-2936.605,1187.604;Inherit;False;Property;_Rim1;Rim;3;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;23;-2632.605,1091.604;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;24;-2760.605,931.6036;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-2296.605,227.6036;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-2136.605,371.6036;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2440.605,1091.604;Inherit;False;Property;_RimAmount1;Rim Amount;7;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-2440.605,931.6036;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;31;-2040.605,1043.604;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;28;-1912.605,227.6036;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-2024.605,1171.604;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-2760.605,-508.3964;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;33;-1640.605,227.6036;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.001;False;2;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;34;-1784.605,3.603638;Inherit;False;Property;_SpecularColor1;Specular Color;5;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;35;-1864.605,643.6036;Inherit;False;Property;_RimColor1;Rim Color;2;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;36;-2408.605,-508.3964;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;37;-1848.605,931.6036;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-2008.605,-428.3964;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1544.605,899.6036;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;40;-1000.605,259.6036;Inherit;False;Property;_AmbientColor1;Ambient Color;1;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1368.605,195.6036;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;43;-856.6049,-428.3964;Inherit;False;Property;_TintColor1;TintColor;0;0;Create;True;0;0;False;0;0.735849,0.735849,0.735849,0;0.8867924,0.8867924,0.8867924,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-792.6049,-156.3964;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;46;-680.6049,-780.3964;Inherit;True;Property;_MainTexture1;Main Texture;6;0;Create;True;0;0;False;0;-1;2ec3aff22090c1248aa82b65522cb127;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-440.6049,-412.3964;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-120.6049,-444.3964;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;55;-104.6049,147.6036;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-616.6049,307.6036;Inherit;False;Property;_TeleportDeathVal1;TeleportDeathVal;8;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;45;-728.6049,83.60364;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;47;-568.6049,467.6036;Inherit;False;Property;_Transparency1;Transparency;9;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-456.6049,3.603638;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-264.6049,-12.39636;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-312.6049,243.6036;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;53;39.39514,-364.3964;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;54;-72.60486,-76.39636;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;327.8694,-214.494;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;RacketToon;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
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
WireConnection;25;0;21;2
WireConnection;25;1;18;0
WireConnection;26;0;19;0
WireConnection;26;1;19;0
WireConnection;32;0;24;0
WireConnection;32;1;23;0
WireConnection;31;0;27;0
WireConnection;28;0;25;0
WireConnection;28;1;26;0
WireConnection;29;0;27;0
WireConnection;30;1;11;0
WireConnection;33;0;28;0
WireConnection;36;0;30;0
WireConnection;37;0;32;0
WireConnection;37;1;31;0
WireConnection;37;2;29;0
WireConnection;38;0;36;0
WireConnection;38;1;21;0
WireConnection;39;0;35;0
WireConnection;39;2;37;0
WireConnection;41;0;34;0
WireConnection;41;1;33;0
WireConnection;42;0;38;0
WireConnection;42;1;41;0
WireConnection;42;2;39;0
WireConnection;42;3;40;0
WireConnection;49;0;43;0
WireConnection;49;1;42;0
WireConnection;52;0;46;0
WireConnection;52;1;49;0
WireConnection;55;0;51;0
WireConnection;48;0;45;2
WireConnection;48;1;45;3
WireConnection;48;2;44;0
WireConnection;50;0;44;0
WireConnection;50;1;48;0
WireConnection;51;0;44;0
WireConnection;51;1;47;0
WireConnection;53;0;52;0
WireConnection;54;2;50;0
WireConnection;0;13;53;0
ASEEND*/
//CHKSM=39AA3FB98B1388E656981BD076C19D9F25724513