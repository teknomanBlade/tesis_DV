// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BasementWalls"
{
	Properties
	{
		_MainColor1("Main Color", Color) = (0.6698113,0.6698113,0.6698113,0)
		_AmbientColor1("Ambient Color", Color) = (0.490566,0.490566,0.490566,0)
		[HDR]_RimColor1("Rim Color", Color) = (0,0,0,0)
		_Rim1("Rim", Range( 0 , 1)) = 0
		_GlossinessAmount1("GlossinessAmount", Float) = 0
		[HDR]_SpecularColor1("Specular Color", Color) = (0,0,0,0)
		_MainTexture1("Main Texture", 2D) = "white" {}
		_RimAmount1("Rim Amount", Range( 0 , 1)) = 0
		_Glossiness1("Glossiness", 2D) = "white" {}
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

		uniform sampler2D _MainTexture1;
		uniform float4 _MainTexture1_ST;
		uniform sampler2D _Glossiness1;
		uniform float4 _Glossiness1_ST;
		uniform float4 _MainColor1;
		uniform float4 _SpecularColor1;
		uniform float _GlossinessAmount1;
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
			float2 uv_Glossiness1 = i.uv_texcoord * _Glossiness1_ST.xy + _Glossiness1_ST.zw;
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 normalizeResult7 = normalize( ase_normWorldNormal );
			float dotResult12 = dot( _WorldSpaceLightPos0.xyz , normalizeResult7 );
			float smoothstepResult37 = smoothstep( 0.0 , 0.001 , ( 0.0 * dotResult12 ));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 Normal10 = normalizeResult7;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult5 = normalize( ase_worldViewDir );
			float3 normalizeResult15 = normalize( ( normalizeResult5 + _WorldSpaceLightPos0.xyz ) );
			float dotResult20 = dot( Normal10 , normalizeResult15 );
			float smoothstepResult34 = smoothstep( 0.001 , 0.01 , pow( ( ase_lightColor.a * dotResult20 ) , ( _GlossinessAmount1 * _GlossinessAmount1 ) ));
			float dotResult17 = dot( ase_worldViewDir , Normal10 );
			float LdotN14 = dotResult12;
			float smoothstepResult33 = smoothstep( ( _RimAmount1 - 0.01 ) , ( _RimAmount1 + 0.01 ) , ( ( 1.0 - dotResult17 ) * pow( LdotN14 , _Rim1 ) ));
			c.rgb = ( tex2D( _MainTexture1, uv_MainTexture1 ) * tex2D( _Glossiness1, uv_Glossiness1 ) * ( _MainColor1 * ( ( smoothstepResult37 * ase_lightColor ) + ( _SpecularColor1 * smoothstepResult34 ) + ( _RimColor1 * smoothstepResult33 ) + _AmbientColor1 ) ) ).rgb;
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
246;469;1307;486;2965.811;1624.255;3.383135;True;False
Node;AmplifyShaderEditor.CommentaryNode;1;-3556.854,-975.7397;Inherit;False;1670.493;552.806;Más su color;10;40;37;30;22;14;12;10;8;7;3;Dirección de la luz;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;2;-3614.109,-317.2544;Inherit;False;2366.779;547.9448;;13;41;36;34;31;27;23;20;19;15;9;6;5;4;Specular/Reflecciones;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;3;-3518.186,-666.4811;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;4;-3558.208,-153.2435;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;5;-3320.628,-145.8653;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;6;-3564.109,29.73606;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.NormalizeNode;7;-3273.572,-666.6292;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;8;-3367.592,-857.8217;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;11;-3394.185,318.8703;Inherit;False;1969.371;712.1435;;14;38;35;33;32;29;28;26;25;24;21;18;17;16;13;Fresnel Manual;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;12;-3051.096,-764.6234;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;9;-3115.871,6.61306;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-3052.202,-537.9334;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;13;-3341.201,659.2794;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-2854.769,-648.8962;Inherit;False;LdotN;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;15;-2914.927,6.444363;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;-3344.185,844.9713;Inherit;False;10;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;17;-3025.949,662.6653;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-2990.751,906.5941;Inherit;False;Property;_Rim1;Rim;3;0;Create;True;0;0;False;0;0;0.603;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2396.617,105.7491;Inherit;False;Property;_GlossinessAmount1;GlossinessAmount;4;0;Create;True;0;0;False;0;0;5.71;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;20;-2656.256,-18.50063;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;-2930.732,806.7252;Inherit;False;14;LdotN;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;22;-2458.994,-624.7759;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-2349.57,-42.35298;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;26;-2814.845,662.6302;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;24;-2679.879,811.5944;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-2188.267,97.69051;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-2484.366,813.5992;Inherit;False;Property;_RimAmount1;Rim Amount;7;0;Create;True;0;0;False;0;0;0.587;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-2079.64,898.0129;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-2494.642,660.1815;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-2815.757,-789.9811;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;31;-1959.808,-43.77241;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;32;-2097.64,762.0133;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;37;-2463.354,-785.6874;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;35;-1916.248,370.6565;Inherit;False;Property;_RimColor1;Rim Color;2;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0.4245283,0.4245283,0.4245283,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;36;-1834.641,-267.2544;Inherit;False;Property;_SpecularColor1;Specular Color;5;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0.5849056,0.5849056,0.5849056,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;33;-1904.434,648.4392;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;34;-1697.186,-46.98438;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.001;False;2;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-1593.813,622.5063;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;39;-1051.065,-12.55044;Inherit;False;Property;_AmbientColor1;Ambient Color;1;0;Create;True;0;0;False;0;0.490566,0.490566,0.490566,0;0.7735849,0.7735849,0.7735849,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-2055.36,-697.7369;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1416.33,-80.48201;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;42;-911.0168,-698.0334;Inherit;False;Property;_MainColor1;Main Color;0;0;Create;True;0;0;False;0;0.6698113,0.6698113,0.6698113,0;0.5660378,0.5660378,0.5660378,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-842.1727,-438.8152;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-533.8496,-730.9749;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;44;-908.4177,-1288.162;Inherit;True;Property;_MainTexture1;Main Texture;6;0;Create;True;0;0;False;0;-1;2ec3aff22090c1248aa82b65522cb127;58e4b22313f014c408a7a87146bcf8b5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;46;-899.9358,-1089.232;Inherit;True;Property;_Glossiness1;Glossiness;8;0;Create;True;0;0;False;0;-1;ab611d0bba8a0334ca5fac9eaaf7419f;ab611d0bba8a0334ca5fac9eaaf7419f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-338.2412,-947.0895;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;131.942,-935.3594;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;BasementWalls;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;0;4;0
WireConnection;7;0;3;0
WireConnection;12;0;8;1
WireConnection;12;1;7;0
WireConnection;9;0;5;0
WireConnection;9;1;6;1
WireConnection;10;0;7;0
WireConnection;14;0;12;0
WireConnection;15;0;9;0
WireConnection;17;0;13;0
WireConnection;17;1;16;0
WireConnection;20;0;10;0
WireConnection;20;1;15;0
WireConnection;27;0;22;2
WireConnection;27;1;20;0
WireConnection;26;0;17;0
WireConnection;24;0;21;0
WireConnection;24;1;18;0
WireConnection;23;0;19;0
WireConnection;23;1;19;0
WireConnection;28;0;25;0
WireConnection;29;0;26;0
WireConnection;29;1;24;0
WireConnection;30;1;12;0
WireConnection;31;0;27;0
WireConnection;31;1;23;0
WireConnection;32;0;25;0
WireConnection;37;0;30;0
WireConnection;33;0;29;0
WireConnection;33;1;32;0
WireConnection;33;2;28;0
WireConnection;34;0;31;0
WireConnection;38;0;35;0
WireConnection;38;1;33;0
WireConnection;40;0;37;0
WireConnection;40;1;22;0
WireConnection;41;0;36;0
WireConnection;41;1;34;0
WireConnection;43;0;40;0
WireConnection;43;1;41;0
WireConnection;43;2;38;0
WireConnection;43;3;39;0
WireConnection;45;0;42;0
WireConnection;45;1;43;0
WireConnection;47;0;44;0
WireConnection;47;1;46;0
WireConnection;47;2;45;0
WireConnection;0;13;47;0
ASEEND*/
//CHKSM=F6A8E799FEF05BFC249B5AE8E884F939E65A97FD