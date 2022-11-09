// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "HouseDoorRgb"
{
	Properties
	{
		_Min("Min", Float) = 0
		_Max("Max", Float) = 0
		_Door_Base_Color("Door_Base_Color", Color) = (0.9779412,0.9248784,0.2085316,0)
		_FirstPosition("First Position", Float) = 0
		_SecondPosition("Second Position", Float) = 0
		_Door_Border_Color("Door_Border_Color", Color) = (0.9632353,0.3477807,0.07082614,0)
		_SecondPositionIntensity("Second Position Intensity", Float) = 0
		_ShadowIntensity("Shadow Intensity", Float) = 0
		_Door_Center_Color("Door_Center_Color", Color) = (0.07082614,0.1877624,0.9632353,0)
		_MainTexture("Main Texture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
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

		uniform float4 _Door_Base_Color;
		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform float4 _Door_Border_Color;
		uniform float4 _Door_Center_Color;
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
			float temp_output_82_0 = min( _Min , _Max );
			float temp_output_81_0 = max( _Max , _Min );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldNormal = i.worldNormal;
			float dotResult72 = dot( ase_worldlightDir , ase_worldNormal );
			float temp_output_76_0 = ( ( dotResult72 + 1.0 ) * ase_lightAtten );
			float smoothstepResult86 = smoothstep( temp_output_82_0 , temp_output_81_0 , ( temp_output_76_0 - _FirstPosition ));
			float smoothstepResult85 = smoothstep( temp_output_82_0 , temp_output_81_0 , ( temp_output_76_0 - _SecondPosition ));
			float temp_output_90_0 = ( saturate( smoothstepResult86 ) + saturate( ( smoothstepResult85 - _SecondPositionIntensity ) ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			c.rgb = saturate( ( ( ( _Door_Base_Color * tex2DNode49.r ) + ( _Door_Border_Color * tex2DNode49.g ) + ( tex2DNode49.b * _Door_Center_Color ) ) * ( ( temp_output_90_0 + ( ( 1.0 - temp_output_90_0 ) * _ShadowIntensity ) ) * ase_lightColor * ase_lightAtten ) ) ).rgb;
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
382;558;1137;598;3872.101;1156.293;3.896012;True;False
Node;AmplifyShaderEditor.CommentaryNode;69;-4016.919,-253.8322;Inherit;False;2894.373;778.0368;Main Light;27;96;95;94;93;92;91;90;89;88;87;86;85;84;83;82;81;80;79;78;77;76;75;74;73;72;71;70;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;70;-3963.119,-215.5879;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;71;-3940.84,-76.71057;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;72;-3663.714,-180.7505;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;74;-3450.645,-23.75449;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;-3429.007,-185.1022;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-2965.946,147.4771;Inherit;False;Property;_SecondPosition;Second Position;4;0;Create;True;0;0;False;0;0;0.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-3556.179,204.8693;Inherit;False;Property;_Max;Max;1;0;Create;True;0;0;False;0;0;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-3550.179,120.8697;Inherit;False;Property;_Min;Min;0;0;Create;True;0;0;False;0;0;0.57;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-3284.039,-170.2944;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;81;-3219.179,211.8693;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-3067.156,-54.86438;Inherit;False;Property;_FirstPosition;First Position;3;0;Create;True;0;0;False;0;0;0.72;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;80;-2768.494,121.9564;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;82;-3218.179,108.8697;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;84;-2879.142,-119.0209;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;-2641.183,392.5876;Inherit;False;Property;_SecondPositionIntensity;Second Position Intensity;6;0;Create;True;0;0;False;0;0;3.74;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;85;-2630.143,183.7439;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;87;-2389.738,185.9026;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;86;-2624.146,-79.37579;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;89;-2287.109,4.560211;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;88;-2169.801,180.932;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-1989.623,78.25769;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;91;-1705.857,153.7044;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-1748.835,377.5026;Inherit;False;Property;_ShadowIntensity;Shadow Intensity;7;0;Create;True;0;0;False;0;0;1.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-1405.952,184.5027;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;61;-1164.947,-1009.859;Float;False;Property;_Door_Border_Color;Door_Border_Color;5;0;Create;True;0;0;False;0;0.9632353,0.3477807,0.07082614,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;64;-1141.87,-659.2891;Float;False;Property;_Door_Center_Color;Door_Center_Color;8;0;Create;True;0;0;False;0;0.07082614,0.1877624,0.9632353,0;1,0.4103774,0.4103774,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;49;-1756.501,-906.6935;Inherit;True;Property;_MainTexture;Main Texture;9;0;Create;True;0;0;False;0;-1;2ec3aff22090c1248aa82b65522cb127;c7882111acf7cd740af5593bba17abdd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;63;-1141.724,-1322.817;Float;False;Property;_Door_Base_Color;Door_Base_Color;2;0;Create;True;0;0;False;0;0.9779412,0.9248784,0.2085316,0;1,0,0,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;96;-1274.548,91.08221;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;95;-1261.051,357.3227;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;94;-1263.857,498.4962;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-874.9557,-1174.209;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-856.2104,-668.4178;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-867.6214,-920.6875;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;68;-646.6548,-666.5328;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-1019.656,172.9508;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-303.8011,-385.7003;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;56;-143.8013,-305.7003;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;278.2,-812.7;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;HouseDoorRgb;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;72;0;70;0
WireConnection;72;1;71;0
WireConnection;73;0;72;0
WireConnection;76;0;73;0
WireConnection;76;1;74;0
WireConnection;81;0;77;0
WireConnection;81;1;78;0
WireConnection;80;0;76;0
WireConnection;80;1;75;0
WireConnection;82;0;78;0
WireConnection;82;1;77;0
WireConnection;84;0;76;0
WireConnection;84;1;79;0
WireConnection;85;0;80;0
WireConnection;85;1;82;0
WireConnection;85;2;81;0
WireConnection;87;0;85;0
WireConnection;87;1;83;0
WireConnection;86;0;84;0
WireConnection;86;1;82;0
WireConnection;86;2;81;0
WireConnection;89;0;86;0
WireConnection;88;0;87;0
WireConnection;90;0;89;0
WireConnection;90;1;88;0
WireConnection;91;0;90;0
WireConnection;93;0;91;0
WireConnection;93;1;92;0
WireConnection;96;0;90;0
WireConnection;96;1;93;0
WireConnection;65;0;63;0
WireConnection;65;1;49;1
WireConnection;67;0;49;3
WireConnection;67;1;64;0
WireConnection;66;0;61;0
WireConnection;66;1;49;2
WireConnection;68;0;65;0
WireConnection;68;1;66;0
WireConnection;68;2;67;0
WireConnection;97;0;96;0
WireConnection;97;1;95;0
WireConnection;97;2;94;0
WireConnection;55;0;68;0
WireConnection;55;1;97;0
WireConnection;56;0;55;0
WireConnection;0;13;56;0
ASEEND*/
//CHKSM=8805F37781AE65B48C738ED4E025DAA1234165B9