// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ToonShadowsInteriorWalls"
{
	Properties
	{
		_Levels("Levels", Range( 0 , 100)) = 71
		_Tint("Tint", Color) = (0,0,0,0)
		_LightIntensity("LightIntensity", Range( 0 , 5)) = 0
		_WoodBedsTexture("WoodBedsTexture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
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

		uniform float4 _Tint;
		uniform sampler2D _WoodBedsTexture;
		uniform float4 _WoodBedsTexture_ST;
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
			float2 uv_WoodBedsTexture = i.uv_texcoord * _WoodBedsTexture_ST.xy + _WoodBedsTexture_ST.zw;
			float4 Albedo106 = ( _Tint * tex2D( _WoodBedsTexture, uv_WoodBedsTexture ) );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult97 = dot( ase_normWorldNormal , ase_worldlightDir );
			float Normal_LightDir101 = dotResult97;
			float4 temp_cast_1 = (Normal_LightDir101).xxxx;
			float div108=256.0/float((int)(Normal_LightDir101*_Levels + _Levels));
			float4 posterize108 = ( floor( temp_cast_1 * div108 ) / div108 );
			float4 Shadow111 = ( Albedo106 * posterize108 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 LightColor119 = ( Shadow111 * ase_lightColor * _LightIntensity );
			c.rgb = saturate( ( LightColor119 * ( 1.0 - step( ase_lightAtten , 0.0 ) ) ) ).rgb;
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
-1920;5;1920;1011;162.0729;2057.669;1.3;True;True
Node;AmplifyShaderEditor.CommentaryNode;94;-3027.16,-3960.924;Inherit;False;787.1289;475.5013;Normal LightDir;4;101;97;96;95;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;95;-2963.16,-3816.924;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;96;-2979.16,-3656.924;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;98;-2307.067,-4670.239;Inherit;False;983.5848;609.9885;Albedo;4;106;103;99;93;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;97;-2739.159,-3768.924;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-2419.158,-3784.924;Inherit;False;Normal_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;99;-2172.669,-4582.589;Inherit;False;Property;_Tint;Tint;4;0;Create;True;0;0;False;0;0,0,0,0;0.9245283,0.9245283,0.9245283,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;102;-2051.158,-3944.924;Inherit;False;1371.36;494.1964;Shadow;7;111;110;109;108;107;105;104;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;93;-2236.092,-4351.994;Inherit;True;Property;_WoodBedsTexture;WoodBedsTexture;10;0;Create;True;0;0;False;0;-1;None;af6ade9429ff0fb4e85823683edfa5aa;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;105;-1987.158,-3592.924;Inherit;False;Property;_Levels;Levels;2;0;Create;True;0;0;False;0;71;13;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;104;-1971.158,-3800.924;Inherit;False;101;Normal_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-1862.042,-4430.162;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;107;-1699.158,-3656.924;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;-1527.425,-4250.051;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;-1507.158,-3880.924;Inherit;False;106;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;108;-1491.158,-3704.924;Inherit;True;30;2;1;COLOR;0,0,0,0;False;0;INT;30;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-1203.158,-3800.924;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;111;-931.1583,-3736.924;Inherit;False;Shadow;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;112;-1955.158,-3256.924;Inherit;False;1202.176;506.8776;Light Color;5;119;116;115;114;113;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightColorNode;114;-1923.158,-3048.924;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;115;-1923.158,-2888.924;Inherit;False;Property;_LightIntensity;LightIntensity;6;0;Create;True;0;0;False;0;0;1.66;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-1795.158,-3176.924;Inherit;False;111;Shadow;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-1523.158,-3064.924;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;117;-133.0437,-1405.083;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;119;-995.1583,-3096.924;Inherit;False;LightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;118;126.4792,-1530.837;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;120;369.4113,-1567.606;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;321.2693,-1857.919;Inherit;True;119;LightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;646.2415,-1722.906;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;1;-3571.496,1428.407;Inherit;False;1670.493;552.806;Más su color;11;38;34;32;21;14;11;9;8;4;49;51;Dirección de la luz;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;10;-3395.496,2724.407;Inherit;False;1969.371;712.1435;;15;39;36;35;30;29;28;26;24;23;22;20;17;16;13;47;Fresnel Manual;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;2;-3619.496,2084.407;Inherit;False;2366.779;547.9448;;15;41;37;33;31;27;25;19;18;15;12;5;3;48;52;53;Specular/Reflecciones;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;122;-3059.16,-3400.924;Inherit;False;787.1289;475.5013;Normal ViewDir;4;128;127;125;124;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-2819.496,1620.407;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-2867.496,1748.407;Inherit;False;LdotN;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;83;-17.37207,239.3005;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;26;-2691.495,3220.407;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-499.4954,1716.407;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;-2355.495,2356.407;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;4;-3523.496,1732.407;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;43;-915.4955,1700.407;Inherit;False;Property;_TintColor;TintColor;0;0;Create;True;0;0;False;0;0.735849,0.735849,0.735849,0;0.2392157,0.2392157,0.2392157,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;74;-512,-352;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-240,80;Inherit;False;Property;_ShadowIntensity;ShadowIntensity;15;0;Create;True;0;0;False;0;0;0.86;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;23;-2819.496,3060.408;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;50;1228.774,-548.0247;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;48;-1715.495,2516.407;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;55;-2624,-400;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NormalizeNode;15;-2915.496,2404.407;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2403.495,2516.407;Inherit;False;Property;_Glossiness;Glossiness;7;0;Create;True;0;0;False;0;0;0.27;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;37;-1699.496,2356.407;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.001;False;2;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;86;-1037.166,-549.6703;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;124;-2979.16,-3144.924;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LightColorNode;80;219.9052,-154.404;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;49;-3043.496,1508.407;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-851.4955,1972.407;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;51;-3489.739,1510.93;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-3059.496,1860.407;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;125;-2995.16,-3336.924;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SmoothstepOpNode;36;-1907.495,3060.408;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;33;-1843.495,2132.407;Inherit;False;Property;_SpecularColor;Specular Color;8;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0.245283,0.245283,0.245283,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;69;-704,-432;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;126;869.1695,-1660.889;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;76;190.6673,-411.4761;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-37.79108,-127.9322;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;88;230.3047,9.624029;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;8;-3243.496,1568.407;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;75;-208,-176;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-2067.495,1700.407;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;18;-2659.495,2388.407;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;53;-3320.081,2447.24;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;35;-1923.495,2772.407;Inherit;False;Property;_RimColor;Rim Color;3;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;71;-1163.307,-246.7231;Inherit;False;Property;_SecondPositionIntensity;SecondPositionIntensity;14;0;Create;True;0;0;False;0;0;0.38;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;29;-2099.495,3172.408;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;85;-1465.733,-163.1363;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-1957.456,-528.8586;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-1791.202,108.6075;Inherit;False;Property;_SecondPosition;SecondPosition;13;0;Create;True;0;0;False;0;0;0.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;56;-2381,-554;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-1934.902,-333.9709;Inherit;False;Property;_FirstPosition;FirstPosition;12;0;Create;True;0;0;False;0;0;0.88;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;741.0109,-424.2421;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;-2132.309,-491.7713;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;9;-3059.496,1636.407;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;20;-2931.496,3204.408;Inherit;False;14;LdotN;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2995.496,3316.407;Inherit;False;Property;_Rim;Rim;5;0;Create;True;0;0;False;0;0;0.212;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;54;-2646.472,-594.7263;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;73;-704,-176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;128;-2755.159,-3304.924;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;-3347.496,3252.407;Inherit;False;11;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;921.5961,-701.881;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;89;492.0918,-23.29413;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;127;-2467.158,-3192.924;Inherit;False;Normal_ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1427.496,2324.407;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1603.496,3028.408;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-2499.495,3220.407;Inherit;False;Property;_RimAmount;Rim Amount;11;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;34;-2499.058,1583.583;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.001;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-2195.495,2500.407;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;40;-1059.496,2387.407;Inherit;False;Property;_AmbientColor;Ambient Color;1;0;Create;True;0;0;False;0;0,0,0,0;0.6981132,0.6981132,0.6981132,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightColorNode;21;-2467.495,1780.407;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;47;-1923.495,2964.408;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;45;536.8118,-851.7736;Inherit;True;Property;_MainTexture;Main Texture;9;0;Create;True;0;0;False;0;-1;None;a4edd094e1ae2da4cb80612063911ae3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;17;-3027.496,3060.408;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-2083.495,3300.407;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;3;-3571.496,2244.407;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;87;-1132.345,-38.12811;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-2499.495,3060.408;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;84;-1480.43,-481.2562;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;12;-3123.496,2404.407;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;5;-3331.496,2259.188;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;70;-875.3562,-157.179;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;52;-3564.677,2441.986;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;13;-3347.496,3060.408;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;31;-1971.495,2356.407;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1467.097,-1700.645;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;ToonShadowsInteriorWalls;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;97;0;95;0
WireConnection;97;1;96;0
WireConnection;101;0;97;0
WireConnection;103;0;99;0
WireConnection;103;1;93;0
WireConnection;107;0;104;0
WireConnection;107;1;105;0
WireConnection;107;2;105;0
WireConnection;106;0;103;0
WireConnection;108;1;104;0
WireConnection;108;0;107;0
WireConnection;110;0;109;0
WireConnection;110;1;108;0
WireConnection;111;0;110;0
WireConnection;116;0;113;0
WireConnection;116;1;114;0
WireConnection;116;2;115;0
WireConnection;119;0;116;0
WireConnection;118;0;117;0
WireConnection;120;0;118;0
WireConnection;123;0;121;0
WireConnection;123;1;120;0
WireConnection;32;0;49;0
WireConnection;32;1;9;0
WireConnection;14;0;9;0
WireConnection;26;0;20;0
WireConnection;26;1;22;0
WireConnection;44;0;43;0
WireConnection;44;1;42;0
WireConnection;27;0;21;2
WireConnection;27;1;18;0
WireConnection;74;0;69;0
WireConnection;74;1;73;0
WireConnection;23;0;17;0
WireConnection;50;0;82;0
WireConnection;15;0;12;0
WireConnection;37;0;31;0
WireConnection;86;0;84;0
WireConnection;42;0;38;0
WireConnection;42;1;41;0
WireConnection;42;2;39;0
WireConnection;42;3;40;0
WireConnection;11;0;4;0
WireConnection;36;0;30;0
WireConnection;36;1;29;0
WireConnection;36;2;28;0
WireConnection;69;0;86;0
WireConnection;126;0;123;0
WireConnection;76;0;74;0
WireConnection;76;1;77;0
WireConnection;77;0;75;0
WireConnection;77;1;78;0
WireConnection;88;0;83;0
WireConnection;8;0;51;0
WireConnection;75;0;74;0
WireConnection;38;0;34;0
WireConnection;38;1;21;0
WireConnection;18;0;11;0
WireConnection;18;1;15;0
WireConnection;53;0;52;0
WireConnection;29;0;24;0
WireConnection;85;0;58;0
WireConnection;85;1;66;0
WireConnection;58;0;57;0
WireConnection;56;0;54;0
WireConnection;56;1;55;0
WireConnection;79;0;76;0
WireConnection;79;1;80;0
WireConnection;79;2;89;0
WireConnection;57;0;56;0
WireConnection;9;0;8;0
WireConnection;9;1;4;0
WireConnection;73;0;70;0
WireConnection;128;0;125;0
WireConnection;128;1;124;0
WireConnection;82;0;45;0
WireConnection;82;1;79;0
WireConnection;89;0;88;0
WireConnection;127;0;128;0
WireConnection;41;0;33;0
WireConnection;41;1;37;0
WireConnection;41;2;48;0
WireConnection;39;0;35;0
WireConnection;39;1;47;0
WireConnection;39;2;36;0
WireConnection;34;0;32;0
WireConnection;25;0;19;0
WireConnection;25;1;19;0
WireConnection;17;0;13;0
WireConnection;17;1;16;0
WireConnection;28;0;24;0
WireConnection;87;0;85;0
WireConnection;30;0;23;0
WireConnection;30;1;26;0
WireConnection;84;0;58;0
WireConnection;84;1;60;0
WireConnection;12;0;5;0
WireConnection;12;1;53;0
WireConnection;5;0;3;0
WireConnection;70;0;87;0
WireConnection;70;1;71;0
WireConnection;31;0;27;0
WireConnection;31;1;25;0
WireConnection;0;13;126;0
ASEEND*/
//CHKSM=D1F8037B2D945D1FFF5A4623A2B7ACB1EF405282