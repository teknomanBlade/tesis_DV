// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BathroomElements"
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
			float3 normalizeResult6 = normalize( ase_worldNormal );
			float dotResult11 = dot( _WorldSpaceLightPos0.xyz , normalizeResult6 );
			float smoothstepResult38 = smoothstep( 0.0 , 0.001 , ( ase_lightAtten * dotResult11 ));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 Normal9 = normalizeResult6;
			float3 normalizeResult5 = normalize( i.viewDir );
			float3 normalizeResult14 = normalize( ( normalizeResult5 + _WorldSpaceLightPos0.xyz ) );
			float dotResult22 = dot( Normal9 , normalizeResult14 );
			float smoothstepResult35 = smoothstep( 0.001 , 0.01 , pow( ( ase_lightColor.a * dotResult22 ) , ( _Glossiness * _Glossiness ) ));
			float dotResult17 = dot( i.viewDir , Normal9 );
			float LdotN15 = dotResult11;
			float smoothstepResult36 = smoothstep( ( _RimAmount - 0.01 ) , ( _RimAmount + 0.01 ) , ( ( 1.0 - dotResult17 ) * pow( LdotN15 , _Rim ) ));
			c.rgb = saturate( ( tex2D( _MainTexture, uv_MainTexture ) * tex2D( _Specular, uv_Specular ) * ( _TintColor * ( ( smoothstepResult38 * ase_lightColor ) + ( _SpecularColor * smoothstepResult35 * ase_lightAtten ) + ( _RimColor * ase_lightAtten * smoothstepResult36 ) + _AmbientColor ) ) ) ).rgb;
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
473;354;1307;480;3372.109;1612.467;5.316332;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-3064.637,-826.2234;Inherit;False;1670.493;552.806;Más su color;11;43;38;33;26;21;15;11;9;8;6;3;Dirección de la luz;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;2;-3112.637,-170.2234;Inherit;False;2366.779;547.9448;;14;44;40;37;35;32;24;23;22;20;14;10;7;5;4;Specular/Reflecciones;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;4;-3064.637,-10.22345;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;3;-3016.637,-522.2234;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;5;-2824.637,5.776558;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;6;-2776.637,-522.2234;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;7;-3064.637,181.7767;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.WorldSpaceLightPos;8;-2872.637,-714.2234;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;12;-2888.637,469.7771;Inherit;False;1969.371;712.1435;;15;42;39;36;34;31;30;29;28;27;25;19;18;17;16;13;Fresnel Manual;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-2552.637,-394.2235;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-2616.637,149.7766;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;11;-2552.637,-618.2234;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;-2840.637,997.7766;Inherit;False;9;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;13;-2840.637,805.7769;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;14;-2408.637,149.7766;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-2360.637,-506.2234;Inherit;False;LdotN;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;17;-2520.637,805.7769;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-2488.637,1061.777;Inherit;False;Property;_Rim;Rim;3;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;19;-2401.637,931.7766;Inherit;False;15;LdotN;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-1896.637,261.7767;Inherit;False;Property;_Glossiness;Glossiness;4;0;Create;True;0;0;False;0;0;-0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;21;-1960.637,-474.2235;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.DotProductOpNode;22;-2152.637,133.7766;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;28;-2312.638,805.7769;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;26;-2536.637,-746.2234;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;27;-2184.637,965.7766;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-1688.637,245.7768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-1848.637,101.7766;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1992.637,965.7766;Inherit;False;Property;_RimAmount;Rim Amount;7;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-1576.637,1045.777;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1992.637,805.7769;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;31;-1592.637,917.7766;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;32;-1464.637,101.7766;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-2312.638,-634.2234;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;40;-1208.638,261.7767;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;37;-1336.637,-122.2233;Inherit;False;Property;_SpecularColor;Specular Color;5;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0.4056604,0.4056604,0.4056604,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;35;-1192.638,101.7766;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.001;False;2;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;38;-1960.637,-634.2234;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;39;-1416.638,517.7772;Inherit;False;Property;_RimColor;Rim Color;2;1;[HDR];Create;True;0;0;False;0;0,0,0,0;21.36125,21.36125,21.36125,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;34;-1416.638,709.7769;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;36;-1400.638,805.7769;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;41;-552.6375,132.7766;Inherit;False;Property;_AmbientColor;Ambient Color;1;0;Create;True;0;0;False;0;0,0,0,0;0.8867924,0.8867924,0.8867924,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-1096.638,773.7769;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-1560.637,-554.2234;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-920.6376,69.77663;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;45;-408.6373,-554.2234;Inherit;False;Property;_TintColor;TintColor;0;0;Create;True;0;0;False;0;0.735849,0.735849,0.735849,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-344.6372,-282.2234;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;49;-247.8369,-1109.685;Inherit;True;Property;_MainTexture;Main Texture;6;0;Create;True;0;0;False;0;-1;2ec3aff22090c1248aa82b65522cb127;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;7.362671,-538.2234;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;48;-223.5535,-843.4885;Inherit;True;Property;_Specular;Specular;8;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;285.3945,-588.876;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;51;574.7467,-386.5904;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;977.8463,-324.9825;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;BathroomElements;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;0;4;0
WireConnection;6;0;3;0
WireConnection;9;0;6;0
WireConnection;10;0;5;0
WireConnection;10;1;7;1
WireConnection;11;0;8;1
WireConnection;11;1;6;0
WireConnection;14;0;10;0
WireConnection;15;0;11;0
WireConnection;17;0;13;0
WireConnection;17;1;16;0
WireConnection;22;0;9;0
WireConnection;22;1;14;0
WireConnection;28;0;17;0
WireConnection;27;0;19;0
WireConnection;27;1;18;0
WireConnection;23;0;20;0
WireConnection;23;1;20;0
WireConnection;24;0;21;2
WireConnection;24;1;22;0
WireConnection;29;0;25;0
WireConnection;30;0;28;0
WireConnection;30;1;27;0
WireConnection;31;0;25;0
WireConnection;32;0;24;0
WireConnection;32;1;23;0
WireConnection;33;0;26;0
WireConnection;33;1;11;0
WireConnection;35;0;32;0
WireConnection;38;0;33;0
WireConnection;36;0;30;0
WireConnection;36;1;31;0
WireConnection;36;2;29;0
WireConnection;42;0;39;0
WireConnection;42;1;34;0
WireConnection;42;2;36;0
WireConnection;43;0;38;0
WireConnection;43;1;21;0
WireConnection;44;0;37;0
WireConnection;44;1;35;0
WireConnection;44;2;40;0
WireConnection;46;0;43;0
WireConnection;46;1;44;0
WireConnection;46;2;42;0
WireConnection;46;3;41;0
WireConnection;47;0;45;0
WireConnection;47;1;46;0
WireConnection;50;0;49;0
WireConnection;50;1;48;0
WireConnection;50;2;47;0
WireConnection;51;0;50;0
WireConnection;0;13;51;0
ASEEND*/
//CHKSM=6256924B43FC0ACABD2741EE2E22438A78C69B85