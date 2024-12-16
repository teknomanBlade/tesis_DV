// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "KitchenPantryAndMisc"
{
	Properties
	{
		_Levels3("Levels", Range( 0 , 100)) = 71
		_KitchenPantryAndMisc("KitchenPantryAndMisc", 2D) = "white" {}
		_Tint3("Tint", Color) = (0,0,0,0)
		_LightIntensity3("LightIntensity", Range( 0 , 5)) = 0
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

		uniform float4 _Tint3;
		uniform sampler2D _KitchenPantryAndMisc;
		uniform float4 _KitchenPantryAndMisc_ST;
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
			float2 uv_KitchenPantryAndMisc = i.uv_texcoord * _KitchenPantryAndMisc_ST.xy + _KitchenPantryAndMisc_ST.zw;
			float4 Albedo100 = ( _Tint3 * tex2D( _KitchenPantryAndMisc, uv_KitchenPantryAndMisc ) );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult91 = dot( ase_normWorldNormal , ase_worldlightDir );
			float Normal_LightDir92 = dotResult91;
			float4 temp_cast_1 = (Normal_LightDir92).xxxx;
			float div102=256.0/float((int)(Normal_LightDir92*_Levels3 + _Levels3));
			float4 posterize102 = ( floor( temp_cast_1 * div102 ) / div102 );
			float4 Shadow104 = ( Albedo100 * posterize102 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 LightColor112 = ( Shadow104 * ase_lightColor * _LightIntensity3 );
			c.rgb = ( LightColor112 * ( 1.0 - step( ase_lightAtten , 0.57 ) ) ).rgb;
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
234;405;1307;649;4761.209;4136.545;4.173934;True;False
Node;AmplifyShaderEditor.CommentaryNode;88;-3338.419,-3250.431;Inherit;False;787.1289;475.5013;Normal LightDir;4;92;91;90;89;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;90;-3290.419,-2946.432;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;89;-3274.419,-3106.431;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;91;-3050.419,-3058.431;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;95;-2362.419,-3234.431;Inherit;False;1371.36;494.1964;Shadow;7;104;103;102;101;99;98;97;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;94;-2076.492,-3893.504;Inherit;False;Property;_Tint3;Tint;6;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;-2730.419,-3074.431;Inherit;False;Normal_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;46;-2129.877,-3677.111;Inherit;True;Property;_KitchenPantryAndMisc;KitchenPantryAndMisc;4;0;Create;True;0;0;False;0;-1;None;8c18c912f77d87d43b8464a027a9f9f5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-1765.865,-3741.078;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-2298.419,-2882.432;Inherit;False;Property;_Levels3;Levels;3;0;Create;True;0;0;False;0;71;19.9;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-2282.419,-3090.431;Inherit;False;92;Normal_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;99;-2010.419,-2946.432;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;-1431.249,-3560.968;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;-1818.419,-3170.431;Inherit;False;100;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;102;-1802.419,-2994.431;Inherit;True;30;2;1;COLOR;0,0,0,0;False;0;INT;30;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-1514.419,-3090.431;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;-1242.419,-3026.431;Inherit;False;Shadow;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;105;-2266.419,-2546.432;Inherit;False;1202.176;506.8776;Light Color;5;112;109;108;107;106;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;106;-2234.419,-2178.432;Inherit;False;Property;_LightIntensity3;LightIntensity;7;0;Create;True;0;0;False;0;0;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;107;-2106.419,-2466.432;Inherit;False;104;Shadow;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;108;-2234.419,-2338.432;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;110;-520.764,-1825.11;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-1834.419,-2354.432;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;111;-261.2412,-1950.865;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.57;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;112;-1306.419,-2386.432;Inherit;False;LightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-66.44897,-2277.948;Inherit;True;112;LightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;114;-3370.419,-2690.432;Inherit;False;787.1289;475.5013;Normal ViewDir;4;120;119;118;117;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;115;-18.30701,-1987.634;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;51;-3100.857,-704.7054;Inherit;False;2894.373;778.0368;Main Light;20;78;77;75;74;73;72;71;70;69;65;61;58;57;55;54;53;52;83;84;87;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-2189.401,-537.292;Inherit;False;Property;_FirstPosition;First Position;0;0;Create;True;0;0;False;0;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;81;-367.3019,162.9335;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;78;-358.4854,-359.791;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;77;-344.9884,-93.55049;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;82;-220.6685,49.46403;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;117;-3066.419,-2594.432;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;55;-2512.945,-635.9754;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;73;-789.7945,-297.1688;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-2419.485,-239.5383;Inherit;False;Property;_SecondPosition;Second Position;1;0;Create;True;0;0;False;0;0;0.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;87;-2510.248,-481.8421;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;54;-2747.652,-631.6237;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-489.8897,-266.3705;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-103.5933,-277.9224;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-2367.977,-621.1676;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;80;-539.6961,426.0164;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;118;-3290.419,-2434.432;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;70;-1253.738,-269.9412;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;85;-2145.047,-327.1525;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;419.7986,-624.8629;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;119;-2778.419,-2482.432;Inherit;False;Normal_ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;120;-3306.419,-2626.432;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;52;-3047.057,-666.4611;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;72;-1073.561,-372.6156;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-832.7725,-73.37057;Inherit;False;Property;_ShadowIntensity;Shadow Intensity;5;0;Create;True;0;0;False;0;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;86;-1894.135,-332.5806;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;258.524,-2142.934;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;83;-1971.66,-607.5626;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;69;-1473.675,-264.9706;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;84;-1702.541,-616.3242;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;71;-1371.046,-446.313;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;53;-3024.778,-527.5839;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;65;-1788.979,-25.38915;Inherit;False;Property;_SecondPositionIntensity;Second Position Intensity;2;0;Create;True;0;0;False;0;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;859.9761,-1365.232;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;KitchenPantryAndMisc;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;91;0;89;0
WireConnection;91;1;90;0
WireConnection;92;0;91;0
WireConnection;96;0;94;0
WireConnection;96;1;46;0
WireConnection;99;0;97;0
WireConnection;99;1;98;0
WireConnection;99;2;98;0
WireConnection;100;0;96;0
WireConnection;102;1;97;0
WireConnection;102;0;99;0
WireConnection;103;0;101;0
WireConnection;103;1;102;0
WireConnection;104;0;103;0
WireConnection;109;0;107;0
WireConnection;109;1;108;0
WireConnection;109;2;106;0
WireConnection;111;0;110;0
WireConnection;112;0;109;0
WireConnection;115;0;111;0
WireConnection;81;0;80;0
WireConnection;78;0;72;0
WireConnection;78;1;75;0
WireConnection;82;0;81;0
WireConnection;117;0;120;0
WireConnection;117;1;118;0
WireConnection;55;0;54;0
WireConnection;73;0;72;0
WireConnection;54;0;52;0
WireConnection;54;1;53;0
WireConnection;75;0;73;0
WireConnection;75;1;74;0
WireConnection;79;0;78;0
WireConnection;79;1;77;0
WireConnection;79;2;82;0
WireConnection;58;0;55;0
WireConnection;58;1;87;0
WireConnection;70;0;69;0
WireConnection;85;0;58;0
WireConnection;85;1;57;0
WireConnection;47;1;79;0
WireConnection;119;0;117;0
WireConnection;72;0;71;0
WireConnection;72;1;70;0
WireConnection;86;0;85;0
WireConnection;116;0;113;0
WireConnection;116;1;115;0
WireConnection;83;0;58;0
WireConnection;83;1;61;0
WireConnection;69;0;86;0
WireConnection;69;1;65;0
WireConnection;84;0;83;0
WireConnection;71;0;84;0
WireConnection;0;13;116;0
ASEEND*/
//CHKSM=790F5D6875D1F335CBB1C9ACF41EBDE52C4A2D5C