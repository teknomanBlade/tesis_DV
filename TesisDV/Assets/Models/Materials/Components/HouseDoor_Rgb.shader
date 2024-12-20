// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "HouseDoorRgb"
{
	Properties
	{
		_Door_Base_Color("Door_Base_Color", Color) = (0.9779412,0.9248784,0.2085316,0)
		_Levels3("Levels", Range( 0 , 100)) = 71
		_Door_Border_Color("Door_Border_Color", Color) = (0.9632353,0.3477807,0.07082614,0)
		_Tint3("Tint", Color) = (0,0,0,0)
		_Door_Center_Color("Door_Center_Color", Color) = (0.07082614,0.1877624,0.9632353,0)
		_LightIntensity3("LightIntensity", Range( 0 , 5)) = 0
		_MainTexture("Main Texture", 2D) = "white" {}
		_LerpLightDir1("LerpLightDir", Range( 0 , 1)) = 0
		_Opacity("Opacity", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		
		AlphaToMask On
		ColorMask RGB
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

		uniform float _Opacity;
		uniform float4 _Tint3;
		uniform float4 _Door_Base_Color;
		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform float4 _Door_Border_Color;
		uniform float4 _Door_Center_Color;
		uniform float _LerpLightDir1;
		uniform float _Levels3;
		uniform float _LightIntensity3;

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
			float4 Albedo127 = ( _Tint3 * ( ( _Door_Base_Color * tex2DNode49.r ) + ( _Door_Border_Color * tex2DNode49.g ) + ( tex2DNode49.b * _Door_Center_Color ) ) );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult114 = dot( ase_normWorldNormal , ase_worldlightDir );
			float dotResult116 = dot( ase_normWorldNormal.x , ase_worldlightDir.z );
			float lerpResult117 = lerp( dotResult114 , dotResult116 , _LerpLightDir1);
			float Normal_LightDir120 = lerpResult117;
			float4 temp_cast_1 = (Normal_LightDir120).xxxx;
			float div128=256.0/float((int)(Normal_LightDir120*_Levels3 + _Levels3));
			float4 posterize128 = ( floor( temp_cast_1 * div128 ) / div128 );
			float4 Shadow131 = ( Albedo127 * posterize128 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 LightColor139 = ( Shadow131 * ase_lightColor * _LightIntensity3 );
			c.rgb = saturate( ( LightColor139 * ( 1.0 - step( ase_lightAtten , 0.57 ) ) ) ).rgb;
			c.a = _Opacity;
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
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows noshadow exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			AlphaToMask Off
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
-1913;44;1920;873;8350.025;4206.393;3.778082;True;True
Node;AmplifyShaderEditor.CommentaryNode;109;-5584.566,-2140.945;Inherit;False;982.1296;776.1276;Normal LightDir;9;120;117;116;115;114;113;112;111;110;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;110;-5546.972,-1755.227;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;111;-5541.757,-2083.372;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;112;-5553.009,-1604.381;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;113;-5526.604,-1929.163;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;118;-4508.322,-3306.353;Inherit;False;2045.348;1351.237;Albedo;6;121;123;127;68;49;61;;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;114;-5286.604,-1775.287;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;116;-5287.289,-2084.122;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-5297.738,-1473.725;Inherit;False;Property;_LerpLightDir1;LerpLightDir;12;0;Create;True;0;0;False;0;0;0.438;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;61;-3830.728,-2838.11;Float;False;Property;_Door_Border_Color;Door_Border_Color;5;0;Create;True;0;0;False;0;0.9632353,0.3477807,0.07082614,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;49;-4388.276,-2844.509;Inherit;True;Property;_MainTexture;Main Texture;11;0;Create;True;0;0;False;0;-1;None;c7882111acf7cd740af5593bba17abdd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;63;-3822.617,-3101.953;Float;False;Property;_Door_Base_Color;Door_Base_Color;0;0;Create;True;0;0;False;0;0.9779412,0.9248784,0.2085316,0;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;64;-3822.762,-2438.425;Float;False;Property;_Door_Center_Color;Door_Center_Color;9;0;Create;True;0;0;False;0;0.07082614,0.1877624,0.9632353,0;0.7924528,0.743859,0.743859,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-3537.104,-2447.554;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-3548.515,-2699.823;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-3550.29,-3003.375;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;117;-4966.643,-1847.477;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;120;-4771.411,-1713.071;Inherit;False;Normal_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;122;-4559.817,-1866.976;Inherit;False;1371.36;494.1964;Shadow;7;131;130;129;128;126;125;124;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;121;-3177.974,-3181.256;Inherit;False;Property;_Tint3;Tint;8;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;68;-3289.543,-2759.915;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;124;-4479.817,-1722.976;Inherit;False;120;Normal_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-2976.572,-2891.522;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;125;-4495.817,-1514.976;Inherit;False;Property;_Levels3;Levels;3;0;Create;True;0;0;False;0;71;16;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;127;-2698.126,-2683.324;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;126;-4207.817,-1578.976;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;129;-4015.816,-1802.976;Inherit;False;127;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;128;-3999.816,-1626.976;Inherit;True;30;2;1;COLOR;0,0,0,0;False;0;INT;30;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;-3711.816,-1722.976;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;131;-3439.816,-1658.976;Inherit;False;Shadow;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;132;-4463.817,-1178.976;Inherit;False;1202.176;506.8776;Light Color;5;139;137;135;134;133;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightColorNode;135;-4431.817,-970.976;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;134;-4303.816,-1098.976;Inherit;False;131;Shadow;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;133;-4431.817,-810.9759;Inherit;False;Property;_LightIntensity3;LightIntensity;10;0;Create;True;0;0;False;0;0;3.85;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;-4031.816,-986.9758;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;136;-1299.891,140.4646;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;138;-1040.367,14.71051;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.57;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;139;-3503.816,-1018.976;Inherit;False;LightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;142;-845.5757,-312.3726;Inherit;True;139;LightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;141;-797.4341,-22.05841;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;69;-4348.926,819.2575;Inherit;False;2894.373;778.0368;Main Light;20;96;95;93;92;91;90;89;88;87;83;79;76;75;73;72;71;70;99;98;100;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;-520.6032,-177.3584;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;140;-5567.816,-1322.976;Inherit;False;787.1289;475.5013;Normal ViewDir;4;147;146;144;143;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;-1606.554,1164.172;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;144;-5503.816,-1258.976;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-1737.958,1257.592;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;95;-1593.057,1430.413;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.StepOpNode;103;-1700.886,1638.596;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;71;-4272.847,996.3791;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-1249.011,1243.653;Inherit;True;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-3399.162,1018.225;Inherit;False;Property;_FirstPosition;First Position;2;0;Create;True;0;0;False;0;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;147;-5263.816,-1226.976;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;88;-2501.807,1254.022;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-3616.045,902.7952;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;70;-4295.126,857.5018;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;75;-3453.121,1437.804;Inherit;False;Property;_SecondPosition;Second Position;4;0;Create;True;0;0;False;0;0;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;91;-2037.863,1226.794;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;101;-2947.831,1413.939;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;146;-4975.816,-1114.976;Inherit;False;Normal_ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;143;-5487.816,-1066.976;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StepOpNode;100;-3188.118,1374.871;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;102;-1925.346,1742.057;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;98;-3160.876,856.9918;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-2080.841,1450.592;Inherit;False;Property;_ShadowIntensity;Shadow Intensity;7;0;Create;True;0;0;False;0;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-3044.792,1165.176;Inherit;False;Property;_SecondPositionIntensity;Second Position Intensity;6;0;Create;True;0;0;False;0;0;0.38;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;87;-2777.719,1178.984;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;99;-2821.023,879.5052;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;89;-2619.115,1077.65;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;56;-143.8013,-305.7003;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-2321.629,1151.348;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;104;-1441.965,1548.018;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;-3761.013,887.9875;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;72;-3995.72,892.3392;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-314.6565,-668.3845;Inherit;False;Property;_Opacity;Opacity;13;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;451.6224,-637.3177;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;HouseDoorRgb;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.85;True;True;0;True;TransparentCutout;;Transparent;ForwardOnly;14;all;True;True;True;False;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;-0.19;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;-1;-1;0;True;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;114;0;110;0
WireConnection;114;1;112;0
WireConnection;116;0;111;1
WireConnection;116;1;113;3
WireConnection;67;0;49;3
WireConnection;67;1;64;0
WireConnection;66;0;61;0
WireConnection;66;1;49;2
WireConnection;65;0;63;0
WireConnection;65;1;49;1
WireConnection;117;0;114;0
WireConnection;117;1;116;0
WireConnection;117;2;115;0
WireConnection;120;0;117;0
WireConnection;68;0;65;0
WireConnection;68;1;66;0
WireConnection;68;2;67;0
WireConnection;123;0;121;0
WireConnection;123;1;68;0
WireConnection;127;0;123;0
WireConnection;126;0;124;0
WireConnection;126;1;125;0
WireConnection;126;2;125;0
WireConnection;128;1;124;0
WireConnection;128;0;126;0
WireConnection;130;0;129;0
WireConnection;130;1;128;0
WireConnection;131;0;130;0
WireConnection;137;0;134;0
WireConnection;137;1;135;0
WireConnection;137;2;133;0
WireConnection;138;0;136;0
WireConnection;139;0;137;0
WireConnection;141;0;138;0
WireConnection;145;0;142;0
WireConnection;145;1;141;0
WireConnection;96;0;90;0
WireConnection;96;1;93;0
WireConnection;93;0;91;0
WireConnection;93;1;92;0
WireConnection;103;0;102;0
WireConnection;97;0;96;0
WireConnection;97;1;95;0
WireConnection;97;2;104;0
WireConnection;147;0;144;0
WireConnection;147;1;143;0
WireConnection;88;0;87;0
WireConnection;76;0;73;0
WireConnection;91;0;90;0
WireConnection;101;0;100;0
WireConnection;146;0;147;0
WireConnection;100;0;76;0
WireConnection;100;1;75;0
WireConnection;98;0;76;0
WireConnection;98;1;79;0
WireConnection;87;0;101;0
WireConnection;87;1;83;0
WireConnection;99;0;98;0
WireConnection;89;0;99;0
WireConnection;56;0;145;0
WireConnection;90;0;89;0
WireConnection;90;1;88;0
WireConnection;104;0;103;0
WireConnection;73;0;72;0
WireConnection;72;0;70;0
WireConnection;72;1;71;0
WireConnection;0;9;106;0
WireConnection;0;13;56;0
ASEEND*/
//CHKSM=CDE2532EF254E11FE88F5CF01021FD329B2AAF20