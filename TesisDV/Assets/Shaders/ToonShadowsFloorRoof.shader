// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ToonShadowsFloorRoof"
{
	Properties
	{
		_MainTexture("Main Texture", 2D) = "white" {}
		_Tint("Tint", Color) = (0,0,0,0)
		_LightIntensity("LightIntensity", Range( 0 , 5)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
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
		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
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
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float4 Albedo105 = ( _Tint * tex2D( _MainTexture, uv_MainTexture ) );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 LightColor115 = ( Albedo105 * ase_lightColor * _LightIntensity );
			c.rgb = ( LightColor115 * ( 1.0 - step( ase_lightAtten , 0.57 ) ) ).rgb;
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
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
-1920;5;1920;1011;4632.864;5131.416;3.556906;True;True
Node;AmplifyShaderEditor.ColorNode;101;-1241.724,-3848.181;Inherit;False;Property;_Tint;Tint;1;0;Create;True;0;0;False;0;0,0,0,0;0.8773585,0.8773585,0.8773585,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;45;-1265.192,-3632.034;Inherit;True;Property;_MainTexture;Main Texture;0;0;Create;True;0;0;False;0;-1;None;f7c9146a68fc7574883e5abc17fdf78f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-931.097,-3695.755;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;105;-596.481,-3515.644;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;89;-1431.651,-2501.107;Inherit;False;1202.176;506.8776;Light Color;5;115;114;113;112;111;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;-1271.651,-2421.107;Inherit;False;105;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;111;-1399.651,-2293.107;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;113;-1399.651,-2133.107;Inherit;False;Property;_LightIntensity;LightIntensity;2;0;Create;True;0;0;False;0;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-999.6512,-2309.107;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;90;314.004,-1779.787;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;91;573.5269,-1905.541;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.57;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;-471.6509,-2341.107;Inherit;False;LightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;93;-2535.653,-2645.107;Inherit;False;787.1289;475.5013;Normal ViewDir;4;119;118;117;116;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;87;-2503.653,-3205.107;Inherit;False;787.1289;475.5013;Normal LightDir;4;99;98;97;96;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;92;816.4604,-1942.31;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;88;-1527.651,-3189.107;Inherit;False;1371.36;494.1964;Shadow;7;110;109;108;107;106;102;120;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;768.3187,-2232.624;Inherit;True;115;LightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;98;-2215.652,-3013.107;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;96;-2455.653,-2901.107;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;116;-2231.652,-2549.107;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-679.651,-3045.107;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;118;-2455.653,-2389.107;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosterizeNode;107;-967.6512,-2949.107;Inherit;True;30;2;1;COLOR;0,0,0,0;False;0;INT;30;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;-974.6512,-3068.107;Inherit;False;105;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;-407.6509,-2981.107;Inherit;False;Shadow;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;1093.292,-2097.61;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;106;-1175.651,-2901.107;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;117;-1943.651,-2437.107;Inherit;False;Normal_ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;119;-2471.653,-2581.107;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;-1895.651,-3029.107;Inherit;False;Normal_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-1447.651,-3045.107;Inherit;False;99;Normal_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;97;-2439.652,-3061.107;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;120;-1493.763,-2818.41;Inherit;False;Property;_Levels;Levels;3;0;Create;True;0;0;False;0;0;24.11765;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1547.484,-1923.222;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;ToonShadowsFloorRoof;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;104;0;101;0
WireConnection;104;1;45;0
WireConnection;105;0;104;0
WireConnection;114;0;112;0
WireConnection;114;1;111;0
WireConnection;114;2;113;0
WireConnection;91;0;90;0
WireConnection;115;0;114;0
WireConnection;92;0;91;0
WireConnection;98;0;97;0
WireConnection;98;1;96;0
WireConnection;116;0;119;0
WireConnection;116;1;118;0
WireConnection;109;0;108;0
WireConnection;109;1;107;0
WireConnection;107;1;102;0
WireConnection;107;0;106;0
WireConnection;110;0;109;0
WireConnection;95;0;94;0
WireConnection;95;1;92;0
WireConnection;106;0;102;0
WireConnection;106;1;120;0
WireConnection;106;2;120;0
WireConnection;117;0;116;0
WireConnection;99;0;98;0
WireConnection;0;13;95;0
ASEEND*/
//CHKSM=C12E55A6F070F03DB6DE7F155ED6513D4546ACF1