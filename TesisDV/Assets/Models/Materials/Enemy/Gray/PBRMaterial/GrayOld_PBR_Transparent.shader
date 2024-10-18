// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "GrayOld_PBR_Transparent"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Gray_Albedo("Gray_Albedo", 2D) = "white" {}
		_SpaceSuit_Albedo("SpaceSuit_Albedo", 2D) = "white" {}
		_NoiseDirection("NoiseDirection", Vector) = (0,1,0,0)
		_SpaceSuit_Albedo_DISP("SpaceSuit_Albedo_DISP", 2D) = "white" {}
		_SpaceSuit_Albedo_SPEC("SpaceSuit_Albedo_SPEC", 2D) = "white" {}
		_NoiseScrollspeed("NoiseScrollspeed", Float) = 1
		_SpaceSuit_Metallic_Amount("SpaceSuit_Metallic_Amount", Float) = 0
		_SpaceSuit_Normal("SpaceSuit_Normal", 2D) = "bump" {}
		_GrayOldEyes_NORM("GrayOldEyes_NORM", 2D) = "bump" {}
		_GrayOld_Normal("GrayOld_Normal", 2D) = "bump" {}
		_GrayOldEyes_DISP("GrayOldEyes_DISP", 2D) = "white" {}
		_SpaceSuit_NormalAmount("SpaceSuit_NormalAmount", Float) = 0
		_EyesMetallic_Amount("EyesMetallic_Amount", Float) = 0
		_EyesNormal_Amount("EyesNormal_Amount", Float) = 0
		_FresnelBias("FresnelBias", Float) = 0
		_FresnelScale("FresnelScale", Float) = 0
		_FresnelPower("FresnelPower", Float) = 0
		_OutlineWidth("OutlineWidth", Float) = 0
		_OutlineTint("OutlineTint", Color) = (0,0,0,0)
		_TimeScale("TimeScale", Float) = 0
		_NoiseScale("NoiseScale", Vector) = (5,5,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0"}
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float outlineVar = _OutlineWidth;
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 normalizeResult83 = normalize( _NoiseDirection );
			float mulTime33 = _Time.y * _TimeScale;
			float simplePerlin2D71 = snoise( ( ase_vertex3Pos + ( ( normalizeResult83 * _NoiseScrollspeed ) * mulTime33 ) ).xy*_NoiseScale.x );
			simplePerlin2D71 = simplePerlin2D71*0.5 + 0.5;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV17 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode17 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV17, _FresnelPower ) );
			float Fresnel88 = fresnelNode17;
			float temp_output_90_0 = ( simplePerlin2D71 * Fresnel88 );
			o.Emission = _OutlineTint.rgb;
			clip( temp_output_90_0 - _Cutoff );
			o.Normal = float3(0,0,-1);
		}
		ENDCG
		

		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _GrayOld_Normal;
		uniform float4 _GrayOld_Normal_ST;
		uniform sampler2D _SpaceSuit_Normal;
		uniform float4 _SpaceSuit_Normal_ST;
		uniform float _SpaceSuit_NormalAmount;
		uniform sampler2D _Gray_Albedo;
		uniform float4 _Gray_Albedo_ST;
		uniform sampler2D _SpaceSuit_Albedo;
		uniform float4 _SpaceSuit_Albedo_ST;
		uniform float3 _NoiseDirection;
		uniform float _NoiseScrollspeed;
		uniform float _TimeScale;
		uniform float2 _NoiseScale;
		uniform float _FresnelBias;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float4 _OutlineTint;
		uniform sampler2D _SpaceSuit_Albedo_SPEC;
		uniform float4 _SpaceSuit_Albedo_SPEC_ST;
		uniform sampler2D _SpaceSuit_Albedo_DISP;
		uniform float4 _SpaceSuit_Albedo_DISP_ST;
		uniform sampler2D _GrayOldEyes_DISP;
		uniform float4 _GrayOldEyes_DISP_ST;
		uniform float _EyesMetallic_Amount;
		uniform sampler2D _GrayOldEyes_NORM;
		uniform float4 _GrayOldEyes_NORM_ST;
		uniform float _EyesNormal_Amount;
		uniform float _SpaceSuit_Metallic_Amount;
		uniform float _OutlineWidth;
		uniform float _Cutoff = 0.5;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 Outline32 = 0;
			v.vertex.xyz += Outline32;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_GrayOld_Normal = i.uv_texcoord * _GrayOld_Normal_ST.xy + _GrayOld_Normal_ST.zw;
			float2 uv_SpaceSuit_Normal = i.uv_texcoord * _SpaceSuit_Normal_ST.xy + _SpaceSuit_Normal_ST.zw;
			float3 Normal68 = ( UnpackNormal( tex2D( _GrayOld_Normal, uv_GrayOld_Normal ) ) + ( UnpackNormal( tex2D( _SpaceSuit_Normal, uv_SpaceSuit_Normal ) ) * _SpaceSuit_NormalAmount ) );
			o.Normal = Normal68;
			float2 uv_Gray_Albedo = i.uv_texcoord * _Gray_Albedo_ST.xy + _Gray_Albedo_ST.zw;
			float2 uv_SpaceSuit_Albedo = i.uv_texcoord * _SpaceSuit_Albedo_ST.xy + _SpaceSuit_Albedo_ST.zw;
			o.Albedo = ( tex2D( _Gray_Albedo, uv_Gray_Albedo ) + tex2D( _SpaceSuit_Albedo, uv_SpaceSuit_Albedo ) ).rgb;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 normalizeResult83 = normalize( _NoiseDirection );
			float mulTime33 = _Time.y * _TimeScale;
			float simplePerlin2D71 = snoise( ( ase_vertex3Pos + ( ( normalizeResult83 * _NoiseScrollspeed ) * mulTime33 ) ).xy*_NoiseScale.x );
			simplePerlin2D71 = simplePerlin2D71*0.5 + 0.5;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV17 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode17 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNdotV17, _FresnelPower ) );
			float Fresnel88 = fresnelNode17;
			float temp_output_90_0 = ( simplePerlin2D71 * Fresnel88 );
			float4 Noise93 = ( temp_output_90_0 * _OutlineTint );
			o.Emission = Noise93.rgb;
			float2 uv_SpaceSuit_Albedo_SPEC = i.uv_texcoord * _SpaceSuit_Albedo_SPEC_ST.xy + _SpaceSuit_Albedo_SPEC_ST.zw;
			float2 uv_SpaceSuit_Albedo_DISP = i.uv_texcoord * _SpaceSuit_Albedo_DISP_ST.xy + _SpaceSuit_Albedo_DISP_ST.zw;
			float2 uv_GrayOldEyes_DISP = i.uv_texcoord * _GrayOldEyes_DISP_ST.xy + _GrayOldEyes_DISP_ST.zw;
			float2 uv_GrayOldEyes_NORM = i.uv_texcoord * _GrayOldEyes_NORM_ST.xy + _GrayOldEyes_NORM_ST.zw;
			float4 temp_output_15_0 = ( ( ( tex2D( _SpaceSuit_Albedo_SPEC, uv_SpaceSuit_Albedo_SPEC ) * tex2D( _SpaceSuit_Albedo_DISP, uv_SpaceSuit_Albedo_DISP ) ) + ( ( tex2D( _GrayOldEyes_DISP, uv_GrayOldEyes_DISP ) * _EyesMetallic_Amount ) * float4( ( UnpackNormal( tex2D( _GrayOldEyes_NORM, uv_GrayOldEyes_NORM ) ) * _EyesNormal_Amount ) , 0.0 ) ) ) * _SpaceSuit_Metallic_Amount );
			o.Metallic = temp_output_15_0.r;
			o.Smoothness = temp_output_15_0.r;
			o.Alpha = ( Fresnel88 + Normal68 ).x;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

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
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
407;467;1137;585;3770.303;1883.714;2.01168;True;False
Node;AmplifyShaderEditor.Vector3Node;79;-5115.694,-733.0794;Inherit;False;Property;_NoiseDirection;NoiseDirection;3;0;Create;True;0;0;False;0;0,1,0;1,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;51;-5024.451,-225.9364;Inherit;False;Property;_TimeScale;TimeScale;20;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-5051.694,-523.4286;Inherit;False;Property;_NoiseScrollspeed;NoiseScrollspeed;6;0;Create;True;0;0;False;0;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;83;-4923.694,-669.0789;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-4788.845,-670.5391;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;21;-2050.943,1112.433;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;27;-2087.719,1303.626;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;20;-2153.998,1694.629;Inherit;False;Property;_FresnelPower;FresnelPower;17;0;Create;True;0;0;False;0;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-2158.659,1577.198;Inherit;False;Property;_FresnelScale;FresnelScale;16;0;Create;True;0;0;False;0;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-2169.735,1508.399;Inherit;False;Property;_FresnelBias;FresnelBias;15;0;Create;True;0;0;False;0;0;0.64;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;33;-4811.22,-389.1689;Inherit;False;1;0;FLOAT;1.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-4614.214,-609.1943;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;17;-1791.187,1157.905;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;86;-5067.694,-925.0794;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;87;-4534.475,-407.49;Inherit;False;Property;_NoiseScale;NoiseScale;21;0;Create;True;0;0;False;0;5,5;25,25;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;23;-3222.565,-1328.924;Inherit;True;Property;_SpaceSuit_Normal;SpaceSuit_Normal;8;0;Create;True;0;0;False;0;-1;None;befada114f952fb4ca37ea3cd0efbee7;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;82;-4418.651,-575.0838;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;-1357.763,1159.929;Inherit;False;Fresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-3136.865,-1094.819;Inherit;False;Property;_SpaceSuit_NormalAmount;SpaceSuit_NormalAmount;12;0;Create;True;0;0;False;0;0;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1845.528,846.9167;Inherit;False;Property;_EyesNormal_Amount;EyesNormal_Amount;14;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1927.684,451.4016;Inherit;False;Property;_EyesMetallic_Amount;EyesMetallic_Amount;13;0;Create;True;0;0;False;0;0;0.31;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-2871.105,-1282.833;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;91;-4340.362,-165.6549;Inherit;False;88;Fresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;6;-2071.684,179.4016;Inherit;True;Property;_GrayOldEyes_DISP;GrayOldEyes_DISP;11;0;Create;True;0;0;False;0;-1;222b6bd1d454f22479d5ddbff405664a;222b6bd1d454f22479d5ddbff405664a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;71;-4252.838,-537.577;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-1936.182,581.7741;Inherit;True;Property;_GrayOldEyes_NORM;GrayOldEyes_NORM;9;0;Create;True;0;0;False;0;-1;d74555a0eff2ee940bd55d3c424daaf0;d74555a0eff2ee940bd55d3c424daaf0;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;24;-3015.03,-1543.881;Inherit;True;Property;_GrayOld_Normal;GrayOld_Normal;10;0;Create;True;0;0;False;0;-1;None;66a2bf118f5d418429061f0faeb0fae0;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-1687.684,163.4016;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-2621.987,-1424.674;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;12;-1927.684,-300.5984;Inherit;True;Property;_SpaceSuit_Albedo_SPEC;SpaceSuit_Albedo_SPEC;5;0;Create;True;0;0;False;0;-1;3ee7e0378c7744545986aef34f9fc98a;3ee7e0378c7744545986aef34f9fc98a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;11;-1911.684,-92.59837;Inherit;True;Property;_SpaceSuit_Albedo_DISP;SpaceSuit_Albedo_DISP;4;0;Create;True;0;0;False;0;-1;c4890cea4e662484bae8ec77deb86682;c4890cea4e662484bae8ec77deb86682;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;29;-3770.566,-556.3353;Inherit;False;Property;_OutlineTint;OutlineTint;19;0;Create;True;0;0;False;0;0,0,0,0;0.5424528,1,0.5854282,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;30;-3246.114,-366.2953;Inherit;False;Property;_OutlineWidth;OutlineWidth;18;0;Create;True;0;0;False;0;0;0.004;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-3980.554,-331.9493;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-1539.903,570.9651;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OutlineNode;28;-3037.827,-498.4443;Inherit;False;0;True;Masked;0;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-3378.879,-249.7556;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;-1543.684,-220.5984;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1351.684,227.4016;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;68;-2254.766,-1409.43;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-2695.869,-387.0947;Inherit;False;Outline;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;-675.4117,778.4868;Inherit;False;68;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;93;-2685.851,-240.5338;Inherit;False;Noise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-935.684,-188.5984;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-719.4504,635.5053;Inherit;False;88;Fresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-871.684,67.40163;Inherit;False;Property;_SpaceSuit_Metallic_Amount;SpaceSuit_Metallic_Amount;7;0;Create;True;0;0;False;0;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1267.137,-799.1423;Inherit;True;Property;_SpaceSuit_Albedo;SpaceSuit_Albedo;2;0;Create;True;0;0;False;0;-1;None;e065f6f3d761b3b45940dc52835e50e8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-1238.237,-1031.235;Inherit;True;Property;_Gray_Albedo;Gray_Albedo;0;0;Create;True;0;0;False;0;-1;None;55d559a5c7bebba4ab7715b8e9276180;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;92;-218.6288,-190.4686;Inherit;False;68;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-574.8779,-104.2562;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;40;-313.1997,155.481;Inherit;False;32;Outline;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;3;-706.2729,-1019.453;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;94;-87.95752,48.58115;Inherit;False;93;Noise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;70;-346.7473,553.7681;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;221.8325,-153.4639;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;GrayOld_PBR_Transparent;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;83;0;79;0
WireConnection;85;0;83;0
WireConnection;85;1;80;0
WireConnection;33;0;51;0
WireConnection;84;0;85;0
WireConnection;84;1;33;0
WireConnection;17;0;21;0
WireConnection;17;4;27;0
WireConnection;17;1;18;0
WireConnection;17;2;19;0
WireConnection;17;3;20;0
WireConnection;82;0;86;0
WireConnection;82;1;84;0
WireConnection;88;0;17;0
WireConnection;25;0;23;0
WireConnection;25;1;22;0
WireConnection;71;0;82;0
WireConnection;71;1;87;0
WireConnection;8;0;6;0
WireConnection;8;1;7;0
WireConnection;26;0;24;0
WireConnection;26;1;25;0
WireConnection;90;0;71;0
WireConnection;90;1;91;0
WireConnection;5;0;4;0
WireConnection;5;1;16;0
WireConnection;28;0;29;0
WireConnection;28;2;90;0
WireConnection;28;1;30;0
WireConnection;95;0;90;0
WireConnection;95;1;29;0
WireConnection;13;0;12;0
WireConnection;13;1;11;0
WireConnection;9;0;8;0
WireConnection;9;1;5;0
WireConnection;68;0;26;0
WireConnection;32;0;28;0
WireConnection;93;0;95;0
WireConnection;14;0;13;0
WireConnection;14;1;9;0
WireConnection;15;0;14;0
WireConnection;15;1;10;0
WireConnection;3;0;2;0
WireConnection;3;1;1;0
WireConnection;70;0;89;0
WireConnection;70;1;69;0
WireConnection;0;0;3;0
WireConnection;0;1;92;0
WireConnection;0;2;94;0
WireConnection;0;3;15;0
WireConnection;0;4;15;0
WireConnection;0;9;70;0
WireConnection;0;11;40;0
ASEEND*/
//CHKSM=B965EFFD5ECBA64C2919D9E62C4248E3D373775B