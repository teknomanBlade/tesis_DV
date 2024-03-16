// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SDR_ExplosionCloud"
{
	Properties
	{
		_SizeExternalExplosion("SizeExternalExplosion", Range( 0 , 5)) = 2.47
		_SizeInternalExplosion("SizeInternalExplosion", Range( 0 , 5)) = 2.47
		_SizeMediumExplosion("SizeMediumExplosion", Range( 0 , 5)) = 2.47
		_StepInternalLayer("StepInternalLayer", Float) = 0
		_StepMediumLayer("StepMediumLayer", Float) = 0
		_OutlineWidth("OutlineWidth", Range( 0 , 1)) = 0.1414499
		_OutlineColor("OutlineColor", Color) = (0,0,0,0)
		_ColorTint("ColorTint", Color) = (0,0,0,0)
		_Alpha("Alpha", Range( 0 , 1)) = 0
		_AlphaMix("AlphaMix", Range( 0 , 1)) = 0
		_ColorMediumLayer("ColorMediumLayer", Color) = (0.9811321,0.5174171,0,0)
		_ColorInternalLayer("ColorInternalLayer", Color) = (0.8113208,0,0,0)
		_ColorExternalLayer("ColorExternalLayer", Color) = (0.8113208,0.2756369,0,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog alpha:premul  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float outlineVar = _OutlineWidth;
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = _OutlineColor.rgb;
			o.Alpha = _Alpha;
		}
		ENDCG
		

		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 viewDir;
			float3 worldNormal;
			float3 worldPos;
		};

		uniform float4 _ColorMediumLayer;
		uniform float _SizeMediumExplosion;
		uniform float _StepMediumLayer;
		uniform float4 _ColorExternalLayer;
		uniform float _SizeExternalExplosion;
		uniform float4 _ColorInternalLayer;
		uniform float _SizeInternalExplosion;
		uniform float _StepInternalLayer;
		uniform float _AlphaMix;
		uniform float4 _ColorTint;
		uniform float _OutlineWidth;
		uniform float4 _OutlineColor;
		uniform float _Alpha;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += 0;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult61 = dot( i.viewDir , ( ( ase_worldNormal * _SizeMediumExplosion ) + ase_worldlightDir ) );
			float dotResult36 = dot( i.viewDir , ( ( ase_worldNormal * _SizeExternalExplosion ) + ase_worldlightDir ) );
			float4 temp_cast_0 = (dotResult36).xxxx;
			float div100=256.0/float(138);
			float4 posterize100 = ( floor( temp_cast_0 * div100 ) / div100 );
			float4 temp_output_82_0 = ( _ColorExternalLayer * ( 1.0 - posterize100 ) );
			float dotResult59 = dot( i.viewDir , ( ( ase_worldNormal * _SizeInternalExplosion ) + ase_worldlightDir ) );
			float4 lerpResult91 = lerp( ( ( _ColorMediumLayer * ( 1.0 - step( dotResult61 , _StepMediumLayer ) ) ) + temp_output_82_0 ) , ( _ColorInternalLayer * ( 1.0 - step( dotResult59 , _StepInternalLayer ) ) ) , _AlphaMix);
			float4 temp_output_48_0 = ( saturate( lerpResult91 ) * _ColorTint );
			o.Emission = temp_output_48_0.rgb;
			o.Alpha = temp_output_48_0.r;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
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
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
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
331;475;1195;432;3395.823;1868.005;1.852294;True;False
Node;AmplifyShaderEditor.RangedFloatNode;31;-4761.958,-607.6365;Inherit;False;Property;_SizeExternalExplosion;SizeExternalExplosion;0;0;Create;True;0;0;False;0;2.47;2.05;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;30;-4665.302,-863.373;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;66;-4538.926,-1459.031;Inherit;False;Property;_SizeMediumExplosion;SizeMediumExplosion;2;0;Create;True;0;0;False;0;2.47;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;67;-4410.34,-1711.767;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;65;-4416.992,-1230.682;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-4168.69,-1600.918;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;52;-4277.068,-2498.482;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-4465.341,-714.3098;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;32;-4671.953,-382.2868;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;53;-4405.654,-2245.746;Inherit;False;Property;_SizeInternalExplosion;SizeInternalExplosion;1;0;Create;True;0;0;False;0;2.47;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-3874.794,-1337.097;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;34;-4140.696,-749.2496;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-4185.882,-481.3815;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-4035.417,-2387.633;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;54;-4283.719,-2017.397;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;63;-3719.794,-1536.636;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;36;-3930.362,-488.5812;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;61;-3575.348,-1310.133;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;-3741.521,-2123.812;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;56;-3586.521,-2323.351;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;69;-3565.573,-1040.48;Inherit;False;Property;_StepMediumLayer;StepMediumLayer;4;0;Create;True;0;0;False;0;0;1.13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-3679.664,-1795.188;Inherit;False;Property;_StepInternalLayer;StepInternalLayer;3;0;Create;True;0;0;False;0;0;3.13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosterizeNode;100;-3661.552,-373.1988;Inherit;True;138;2;1;COLOR;0,0,0,0;False;0;INT;138;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;59;-3442.075,-2096.848;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;68;-3260.701,-1212.695;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;78;-3211.977,-1493.852;Inherit;False;Property;_ColorMediumLayer;ColorMediumLayer;10;0;Create;True;0;0;False;0;0.9811321,0.5174171,0,0;0.9811321,0.5174171,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;60;-3127.428,-1999.41;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;81;-3505.53,-625.8683;Inherit;False;Property;_ColorExternalLayer;ColorExternalLayer;12;0;Create;True;0;0;False;0;0.8113208,0.2756369,0,0;1,0.3515859,0.07075471,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;85;-3290.642,-476.4853;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;77;-2984.294,-1289.923;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-2783.016,-1551.058;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;76;-2858.986,-1984.631;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-2972.2,-713.5368;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;73;-3099.779,-2249.064;Inherit;False;Property;_ColorInternalLayer;ColorInternalLayer;11;0;Create;True;0;0;False;0;0.8113208,0,0,0;0.8113208,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;86;-2463.725,-1649.028;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-2396.259,-1392.285;Inherit;False;Property;_AlphaMix;AlphaMix;9;0;Create;True;0;0;False;0;0;0.07495244;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;71;-2545.778,-2060.07;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;91;-1931.61,-1584.831;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.5754717;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;42;-1220.276,150.3445;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;43;-1384.759,-135.2991;Inherit;False;Property;_ColorTint;ColorTint;7;0;Create;True;0;0;False;0;0,0,0,0;0.8207547,0,0.1049531,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;46;-1786.094,-227.7652;Inherit;False;Property;_OutlineWidth;OutlineWidth;5;0;Create;True;0;0;False;0;0.1414499;0.267;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1846.924,-411.429;Inherit;False;Property;_Alpha;Alpha;8;0;Create;True;0;0;False;0;0;0.494;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;47;-1760.332,-631.814;Inherit;False;Property;_OutlineColor;OutlineColor;6;0;Create;True;0;0;False;0;0,0,0,0;0.8584906,0.6095997,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-984.8661,201.4279;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OutlineNode;51;-1425.267,-352.6404;Inherit;False;0;True;AlphaPremultiplied;0;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;101;-2693.709,-572.1355;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-527.204,293.3513;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;321.7523,-13.59517;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;SDR_ExplosionCloud;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;64;0;67;0
WireConnection;64;1;66;0
WireConnection;33;0;30;0
WireConnection;33;1;31;0
WireConnection;62;0;64;0
WireConnection;62;1;65;0
WireConnection;35;0;33;0
WireConnection;35;1;32;0
WireConnection;55;0;52;0
WireConnection;55;1;53;0
WireConnection;36;0;34;0
WireConnection;36;1;35;0
WireConnection;61;0;63;0
WireConnection;61;1;62;0
WireConnection;57;0;55;0
WireConnection;57;1;54;0
WireConnection;100;1;36;0
WireConnection;59;0;56;0
WireConnection;59;1;57;0
WireConnection;68;0;61;0
WireConnection;68;1;69;0
WireConnection;60;0;59;0
WireConnection;60;1;58;0
WireConnection;85;0;100;0
WireConnection;77;0;68;0
WireConnection;80;0;78;0
WireConnection;80;1;77;0
WireConnection;76;0;60;0
WireConnection;82;0;81;0
WireConnection;82;1;85;0
WireConnection;86;0;80;0
WireConnection;86;1;82;0
WireConnection;71;0;73;0
WireConnection;71;1;76;0
WireConnection;91;0;86;0
WireConnection;91;1;71;0
WireConnection;91;2;92;0
WireConnection;42;0;91;0
WireConnection;48;0;42;0
WireConnection;48;1;43;0
WireConnection;51;0;47;0
WireConnection;51;2;44;0
WireConnection;51;1;46;0
WireConnection;101;0;82;0
WireConnection;101;1;100;0
WireConnection;49;0;48;0
WireConnection;0;2;48;0
WireConnection;0;9;48;0
WireConnection;0;11;51;0
ASEEND*/
//CHKSM=1B06D2EBDB71BF1519CC40760DC98DB848D1512A