// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ToonShadowsDecalsWithTransparency"
{
	Properties
	{
		_MainTexture("Main Texture", 2D) = "white" {}
		_FirstPosition("FirstPosition", Float) = 0
		_Min("Min", Float) = 0
		_Max("Max", Float) = 0
		_SecondPosition("SecondPosition", Float) = 0
		_SecondPositionIntensity("SecondPositionIntensity", Float) = 0
		_ShadowIntensity("ShadowIntensity", Float) = 0
		_Color_Decals("Color_Decals", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
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
			float3 worldPos;
			float3 worldNormal;
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
		uniform float4 _Color_Decals;
		uniform float _Min;
		uniform float _Max;
		uniform float _FirstPosition;
		uniform float _SecondPosition;
		uniform float _SecondPositionIntensity;
		uniform float _ShadowIntensity;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float4 tex2DNode45 = tex2D( _MainTexture, uv_MainTexture );
			float temp_output_64_0 = min( _Min , _Max );
			float temp_output_65_0 = max( _Max , _Min );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldNormal = i.worldNormal;
			float dotResult56 = dot( ase_worldlightDir , ase_worldNormal );
			float temp_output_58_0 = ( ( dotResult56 + 1.0 ) * 0.5 );
			float smoothstepResult61 = smoothstep( temp_output_64_0 , temp_output_65_0 , ( temp_output_58_0 - _FirstPosition ));
			float smoothstepResult68 = smoothstep( temp_output_64_0 , temp_output_65_0 , ( temp_output_58_0 - _SecondPosition ));
			float temp_output_74_0 = ( saturate( smoothstepResult61 ) + saturate( ( smoothstepResult68 - _SecondPositionIntensity ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			c.rgb = saturate( ( ( tex2DNode45 * _Color_Decals ) * ( ( temp_output_74_0 + ( ( 1.0 - temp_output_74_0 ) * _ShadowIntensity ) ) * ase_lightColor ) ) ).rgb;
			c.a = tex2DNode45.a;
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
		#pragma surface surf StandardCustomLighting alpha:fade keepalpha fullforwardshadows 

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
341;204;1100;540;-678.9778;783.8294;1.3;True;True
Node;AmplifyShaderEditor.WorldNormalVector;55;-2624,-400;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;54;-2624,-576;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;56;-2336,-496;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;-2128,-464;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-2032,-48;Inherit;False;Property;_Max;Max;10;0;Create;True;0;0;False;0;0;-0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-1568,-176;Inherit;False;Property;_SecondPosition;SecondPosition;11;0;Create;True;0;0;False;0;0;31.11;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-1936,-512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2032,-176;Inherit;False;Property;_Min;Min;9;0;Create;True;0;0;False;0;0;-67.41;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;65;-1760,-48;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-1872,-336;Inherit;False;Property;_FirstPosition;FirstPosition;8;0;Create;True;0;0;False;0;0;-11.62;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;67;-1360,-240;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;64;-1760,-176;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;59;-1712,-464;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-1184,32;Inherit;False;Property;_SecondPositionIntensity;SecondPositionIntensity;12;0;Create;True;0;0;False;0;0;56.13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;68;-1200,-224;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;70;-912,-224;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;61;-1216,-528;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;69;-704,-432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;73;-704,-176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;74;-512,-352;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-240,80;Inherit;False;Property;_ShadowIntensity;ShadowIntensity;13;0;Create;True;0;0;False;0;0;0.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;75;-208,-176;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;48,-80;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;45;536.8118,-851.7736;Inherit;True;Property;_MainTexture;Main Texture;6;0;Create;True;0;0;False;0;-1;None;08011258ca7aa6e4e911b36a61d68cb3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;83;582.6647,-1080.045;Inherit;False;Property;_Color_Decals;Color_Decals;14;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;76;240,-320;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;80;128,192;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;592.3793,-424.2421;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;856.6647,-955.0452;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;2;-3619.496,2084.407;Inherit;False;2366.779;547.9448;;15;41;37;33;31;27;25;19;18;15;12;5;3;48;52;53;Specular/Reflecciones;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;10;-3395.496,2724.407;Inherit;False;1969.371;712.1435;;15;39;36;35;30;29;28;26;24;23;22;20;17;16;13;47;Fresnel Manual;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;1062.596,-706.881;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;1;-3571.496,1428.407;Inherit;False;1670.493;552.806;Más su color;11;38;34;32;21;14;11;9;8;4;49;51;Dirección de la luz;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2499.495,3220.407;Inherit;False;Property;_RimAmount;Rim Amount;7;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-2931.496,3204.408;Inherit;False;14;LdotN;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-2195.495,2500.407;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;49;-3043.496,1508.407;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-499.4954,1716.407;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;40;-1059.496,2387.407;Inherit;False;Property;_AmbientColor;Ambient Color;1;0;Create;True;0;0;False;0;0,0,0,0;0.6981132,0.6981132,0.6981132,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;23;-2819.496,3060.408;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;4;-3523.496,1732.407;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1427.496,2324.407;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;51;-3489.739,1510.93;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-2499.495,3060.408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;33;-1843.495,2132.407;Inherit;False;Property;_SpecularColor;Specular Color;5;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0.245283,0.245283,0.245283,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;5;-3331.496,2259.188;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;53;-3320.081,2447.24;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightAttenuation;48;-1715.495,2516.407;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1603.496,3028.408;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;21;-2467.495,1780.407;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.NormalizeNode;15;-2915.496,2404.407;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;3;-3571.496,2244.407;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SmoothstepOpNode;37;-1699.496,2356.407;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.001;False;2;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-2067.495,1700.407;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;35;-1923.495,2772.407;Inherit;False;Property;_RimColor;Rim Color;2;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-2355.495,2356.407;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;17;-3027.496,3060.408;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;50;1228.774,-548.0247;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2995.496,3316.407;Inherit;False;Property;_Rim;Rim;3;0;Create;True;0;0;False;0;0;0.212;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-3123.496,2404.407;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2403.495,2516.407;Inherit;False;Property;_Glossiness;Glossiness;4;0;Create;True;0;0;False;0;0;0.27;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;36;-1907.495,3060.408;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;-3347.496,3252.407;Inherit;False;11;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;43;-915.4955,1700.407;Inherit;False;Property;_TintColor;TintColor;0;0;Create;True;0;0;False;0;0.735849,0.735849,0.735849,0;0.2392157,0.2392157,0.2392157,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;47;-1923.495,2964.408;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;34;-2499.058,1583.583;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;29;-2099.495,3172.408;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-2083.495,3300.407;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;13;-3347.496,3060.408;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-2867.496,1748.407;Inherit;False;LdotN;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;18;-2659.495,2388.407;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;8;-3243.496,1568.407;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-851.4955,1972.407;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-2819.496,1620.407;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;52;-3564.677,2441.986;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;31;-1971.495,2356.407;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;9;-3059.496,1636.407;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-3059.496,1860.407;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;26;-2691.495,3220.407;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1540.351,-475.3055;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;ToonShadowsDecalsWithTransparency;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;56;0;54;0
WireConnection;56;1;55;0
WireConnection;57;0;56;0
WireConnection;58;0;57;0
WireConnection;65;0;63;0
WireConnection;65;1;62;0
WireConnection;67;0;58;0
WireConnection;67;1;66;0
WireConnection;64;0;62;0
WireConnection;64;1;63;0
WireConnection;59;0;58;0
WireConnection;59;1;60;0
WireConnection;68;0;67;0
WireConnection;68;1;64;0
WireConnection;68;2;65;0
WireConnection;70;0;68;0
WireConnection;70;1;71;0
WireConnection;61;0;59;0
WireConnection;61;1;64;0
WireConnection;61;2;65;0
WireConnection;69;0;61;0
WireConnection;73;0;70;0
WireConnection;74;0;69;0
WireConnection;74;1;73;0
WireConnection;75;0;74;0
WireConnection;77;0;75;0
WireConnection;77;1;78;0
WireConnection;76;0;74;0
WireConnection;76;1;77;0
WireConnection;79;0;76;0
WireConnection;79;1;80;0
WireConnection;84;0;45;0
WireConnection;84;1;83;0
WireConnection;82;0;84;0
WireConnection;82;1;79;0
WireConnection;25;0;19;0
WireConnection;25;1;19;0
WireConnection;44;0;43;0
WireConnection;44;1;42;0
WireConnection;23;0;17;0
WireConnection;41;0;33;0
WireConnection;41;1;37;0
WireConnection;41;2;48;0
WireConnection;30;0;23;0
WireConnection;30;1;26;0
WireConnection;5;0;3;0
WireConnection;53;0;52;0
WireConnection;39;0;35;0
WireConnection;39;1;47;0
WireConnection;39;2;36;0
WireConnection;15;0;12;0
WireConnection;37;0;31;0
WireConnection;38;0;34;0
WireConnection;38;1;21;0
WireConnection;27;0;21;2
WireConnection;27;1;18;0
WireConnection;17;0;13;0
WireConnection;17;1;16;0
WireConnection;50;0;82;0
WireConnection;12;0;5;0
WireConnection;12;1;53;0
WireConnection;36;0;30;0
WireConnection;36;1;29;0
WireConnection;36;2;28;0
WireConnection;34;0;32;0
WireConnection;29;0;24;0
WireConnection;28;0;24;0
WireConnection;14;0;9;0
WireConnection;18;0;11;0
WireConnection;18;1;15;0
WireConnection;8;0;51;0
WireConnection;42;0;38;0
WireConnection;42;1;41;0
WireConnection;42;2;39;0
WireConnection;42;3;40;0
WireConnection;32;0;49;0
WireConnection;32;1;9;0
WireConnection;31;0;27;0
WireConnection;31;1;25;0
WireConnection;9;0;8;0
WireConnection;9;1;4;0
WireConnection;11;0;4;0
WireConnection;26;0;20;0
WireConnection;26;1;22;0
WireConnection;0;9;45;4
WireConnection;0;13;50;0
ASEEND*/
//CHKSM=50C2BF652300A359FDD06380B7C627B8C103C74F