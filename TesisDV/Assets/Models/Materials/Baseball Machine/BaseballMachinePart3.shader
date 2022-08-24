// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BaseballMachinePart3"
{
	Properties
	{
		_TintColor1("TintColor", Color) = (0.735849,0.735849,0.735849,0)
		_AmbientColor2("Ambient Color", Color) = (0,0,0,0)
		[HDR]_RimColor2("Rim Color", Color) = (0,0,0,0)
		_Rim2("Rim", Range( 0 , 1)) = 0
		_Glossiness2("Glossiness", Float) = 0
		[HDR]_SpecularColor2("Specular Color", Color) = (0,0,0,0)
		_MainTexture2("Main Texture", 2D) = "white" {}
		_RimAmount2("Rim Amount", Range( 0 , 1)) = 0
		_TintActive2("TintActive", Color) = (1,0.9813726,0,0)
		_ColorInterpolator2("ColorInterpolator", Range( 0 , 0.8)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
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

		uniform sampler2D _MainTexture2;
		uniform float4 _MainTexture2_ST;
		uniform float4 _TintActive2;
		uniform float _ColorInterpolator2;
		uniform float4 _TintColor1;
		uniform float4 _SpecularColor2;
		uniform float _Glossiness2;
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
			float2 uv_MainTexture2 = i.uv_texcoord * _MainTexture2_ST.xy + _MainTexture2_ST.zw;
			float4 tex2DNode48 = tex2D( _MainTexture2, uv_MainTexture2 );
			float3 ase_worldNormal = i.worldNormal;
			float3 normalizeResult5 = normalize( ase_worldNormal );
			float dotResult11 = dot( _WorldSpaceLightPos0.xyz , normalizeResult5 );
			float smoothstepResult37 = smoothstep( 0.0 , 0.001 , ( ase_lightAtten * dotResult11 ));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 Normal9 = normalizeResult5;
			float3 normalizeResult7 = normalize( i.viewDir );
			float3 normalizeResult15 = normalize( ( normalizeResult7 + _WorldSpaceLightPos0.xyz ) );
			float dotResult18 = dot( Normal9 , normalizeResult15 );
			float smoothstepResult38 = smoothstep( 0.001 , 0.01 , pow( ( ase_lightColor.a * dotResult18 ) , ( _Glossiness2 * _Glossiness2 ) ));
			float dotResult17 = dot( i.viewDir , Normal9 );
			float LdotN14 = dotResult11;
			float smoothstepResult40 = smoothstep( ( _RimAmount2 - 0.01 ) , ( _RimAmount2 + 0.01 ) , ( ( 1.0 - dotResult17 ) * pow( LdotN14 , _Rim2 ) ));
			c.rgb = saturate( ( tex2DNode48 * ( _TintColor1 * ( ( smoothstepResult37 * ase_lightColor ) + ( _SpecularColor2 * smoothstepResult38 * ase_lightAtten ) + ( _RimColor2 * ase_lightAtten * smoothstepResult40 ) + _AmbientColor2 ) ) ) ).rgb;
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
			float2 uv_MainTexture2 = i.uv_texcoord * _MainTexture2_ST.xy + _MainTexture2_ST.zw;
			float4 tex2DNode48 = tex2D( _MainTexture2, uv_MainTexture2 );
			o.Emission = saturate( ( tex2DNode48.a * _TintActive2 * _ColorInterpolator2 ) ).rgb;
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
474;399;1307;378;-694.8728;1295.438;2.129744;True;False
Node;AmplifyShaderEditor.CommentaryNode;2;-1487.364,-310.2698;Inherit;False;2366.779;547.9448;;14;43;39;38;34;32;25;23;19;18;15;10;8;7;4;Specular/Reflecciones;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1;-1430.108,-968.7551;Inherit;False;1670.493;552.806;Más su color;11;41;37;33;27;21;14;11;9;6;5;3;Dirección de la luz;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;3;-1391.44,-659.4967;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;4;-1431.462,-146.2589;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;5;-1146.827,-659.6447;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;6;-1240.847,-850.8372;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.NormalizeNode;7;-1193.883,-138.8808;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;8;-1437.364,36.72059;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-925.457,-530.9489;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-989.125,13.59759;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;11;-924.3511,-757.6389;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;12;-1267.439,325.8548;Inherit;False;1969.371;712.1435;;15;42;40;36;35;31;30;29;28;26;24;22;20;17;16;13;Fresnel Manual;1,1,1,1;0;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;13;-1214.456,666.2639;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-728.0231,-641.9116;Inherit;False;LdotN;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;15;-788.182,13.42889;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;-1217.439,851.9557;Inherit;False;9;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;17;-899.2041,669.6498;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;18;-529.511,-11.51611;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-268.8721,112.7336;Inherit;False;Property;_Glossiness2;Glossiness;4;0;Create;True;0;0;False;0;0;66.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-803.9871,813.7098;Inherit;False;14;LdotN;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;21;-332.249,-617.7913;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;22;-864.006,913.5785;Inherit;False;Property;_Rim2;Rim;3;0;Create;True;0;0;False;0;0;0.687;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-222.8251,-35.36845;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-357.6211,820.5837;Inherit;False;Property;_RimAmount2;Rim Amount;7;0;Create;True;0;0;False;0;0;0.122;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-61.52191,104.675;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;27;-901.6271,-895.9796;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;28;-553.134,818.5788;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;26;-688.1001,669.6147;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;47.10474,904.9974;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;30;29.10474,768.9979;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-367.8971,667.1659;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;32;166.9374,-36.78788;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-689.0121,-782.9967;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;35;210.4971,377.641;Inherit;False;Property;_RimColor2;Rim Color;2;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0.8396226,0.8396226,0.8396226,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;36;218.4092,565.9228;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;34;419.4877,120.4383;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;39;292.1044,-260.2698;Inherit;False;Property;_SpecularColor2;Specular Color;5;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0.7735849,0.7735849,0.7735849,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;40;222.3109,655.4238;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;38;429.5601,-39.99986;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.001;False;2;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;37;-336.608,-778.703;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;71.38477,-690.7525;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;532.9321,629.4908;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;710.4155,-73.49748;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;44;1075.68,-5.56591;Inherit;False;Property;_AmbientColor2;Ambient Color;1;0;Create;True;0;0;False;0;0,0,0,0;0.6226415,0.6226415,0.6226415,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;46;1284.573,-431.8306;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;45;1215.729,-691.049;Inherit;False;Property;_TintColor1;TintColor;0;0;Create;True;0;0;False;0;0.735849,0.735849,0.735849,0;0.7830189,0.7830189,0.7830189,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;1630.828,-684.3344;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;48;1426.682,-959.8719;Inherit;True;Property;_MainTexture2;Main Texture;6;0;Create;True;0;0;False;0;-1;639cb484332926745b5369d9b80ccdda;639cb484332926745b5369d9b80ccdda;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;52;1840.086,-1143.228;Inherit;False;Property;_TintActive2;TintActive;8;0;Create;True;0;0;False;0;1,0.9813726,0,0;1,0.9813726,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;51;1842.289,-890.1066;Inherit;False;Property;_ColorInterpolator2;ColorInterpolator;9;0;Create;True;0;0;False;0;0;0;0;0.8;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;1859.027,-404.3394;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;2161.206,-1080.849;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;54;2400.857,-974.7047;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;50;2077.357,-308.843;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2639.546,-356.8073;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;BaseballMachinePart3;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;5;0;3;0
WireConnection;7;0;4;0
WireConnection;9;0;5;0
WireConnection;10;0;7;0
WireConnection;10;1;8;1
WireConnection;11;0;6;1
WireConnection;11;1;5;0
WireConnection;14;0;11;0
WireConnection;15;0;10;0
WireConnection;17;0;13;0
WireConnection;17;1;16;0
WireConnection;18;0;9;0
WireConnection;18;1;15;0
WireConnection;23;0;21;2
WireConnection;23;1;18;0
WireConnection;25;0;19;0
WireConnection;25;1;19;0
WireConnection;28;0;20;0
WireConnection;28;1;22;0
WireConnection;26;0;17;0
WireConnection;29;0;24;0
WireConnection;30;0;24;0
WireConnection;31;0;26;0
WireConnection;31;1;28;0
WireConnection;32;0;23;0
WireConnection;32;1;25;0
WireConnection;33;0;27;0
WireConnection;33;1;11;0
WireConnection;40;0;31;0
WireConnection;40;1;30;0
WireConnection;40;2;29;0
WireConnection;38;0;32;0
WireConnection;37;0;33;0
WireConnection;41;0;37;0
WireConnection;41;1;21;0
WireConnection;42;0;35;0
WireConnection;42;1;36;0
WireConnection;42;2;40;0
WireConnection;43;0;39;0
WireConnection;43;1;38;0
WireConnection;43;2;34;0
WireConnection;46;0;41;0
WireConnection;46;1;43;0
WireConnection;46;2;42;0
WireConnection;46;3;44;0
WireConnection;47;0;45;0
WireConnection;47;1;46;0
WireConnection;49;0;48;0
WireConnection;49;1;47;0
WireConnection;53;0;48;4
WireConnection;53;1;52;0
WireConnection;53;2;51;0
WireConnection;54;0;53;0
WireConnection;50;0;49;0
WireConnection;0;2;54;0
WireConnection;0;13;50;0
ASEEND*/
//CHKSM=C11A32F170DEEE31BDE43709646FF754D4E3D00D