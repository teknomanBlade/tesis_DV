// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TallGray_Melee_PBRTransparent"
{
	Properties
	{
		_TilingCloakNoise("TilingCloakNoise", Float) = 15
		_TimeScaleNoise("TimeScaleNoise", Float) = 2
		_Albedo("Albedo", 2D) = "white" {}
		_AmbientOcclusion1("AmbientOcclusion", 2D) = "white" {}
		_DisplacementMap1("DisplacementMap", 2D) = "white" {}
		_CloakTint("CloakTint", Color) = (0,0.5402541,1,0)
		_Specular1("Specular", 2D) = "white" {}
		_PumpingParts1("PumpingParts", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_EyesEmission1("EyesEmission", 2D) = "white" {}
		_ActivateCloak("ActivateCloak", Range( 0 , 1)) = 0
		_Opacity("Opacity", Range( 0 , 1)) = 0
		_PeriodGlowing1("PeriodGlowing", Float) = 0
		_NoisePower("NoisePower", Float) = 0
		_CloakValue("CloakValue", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
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
			float3 worldRefl;
			INTERNAL_DATA
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float _TimeScaleNoise;
		uniform float _TilingCloakNoise;
		uniform float _NoisePower;
		uniform float4 _CloakTint;
		uniform float _ActivateCloak;
		uniform float _CloakValue;
		uniform sampler2D _EyesEmission1;
		uniform float4 _EyesEmission1_ST;
		uniform float _PeriodGlowing1;
		uniform sampler2D _PumpingParts1;
		uniform float4 _PumpingParts1_ST;
		uniform sampler2D _DisplacementMap1;
		uniform float4 _DisplacementMap1_ST;
		uniform sampler2D _Specular1;
		uniform float4 _Specular1_ST;
		uniform sampler2D _AmbientOcclusion1;
		uniform float4 _AmbientOcclusion1_ST;
		uniform float _Opacity;


		float2 voronoihash2( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi2( float2 v, float time, inout float2 id, float smoothness )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mr = 0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash2( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = g - f + o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			 		}
			 	}
			}
			return F1;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 Normal17 = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			o.Normal = Normal17;
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 Albedo9 = tex2D( _Albedo, uv_Albedo );
			float mulTime6 = _Time.y * _TimeScaleNoise;
			float time2 = mulTime6;
			float2 temp_cast_0 = (_TilingCloakNoise).xx;
			float2 temp_cast_1 = (mulTime6).xx;
			float2 uv_TexCoord3 = i.uv_texcoord * temp_cast_0 + temp_cast_1;
			float2 coords2 = uv_TexCoord3 * 1.0;
			float2 id2 = 0;
			float voroi2 = voronoi2( coords2, time2,id2, 0 );
			float4 lerpResult14 = lerp( Albedo9 , ( Albedo9 + ( pow( ( 1.0 - voroi2 ) , _NoisePower ) * ( voroi2 * _CloakTint ) ) ) , _ActivateCloak);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldReflection = WorldReflectionVector( i, float3( 0, 0, 1 ) );
			float4 temp_cast_2 = (( distance( ase_worldViewDir , ase_worldReflection ) * _CloakValue )).xxxx;
			float div72=256.0/float(26);
			float4 posterize72 = ( floor( temp_cast_2 * div72 ) / div72 );
			float grayscale75 = Luminance(Normal17);
			float4 lerpResult15 = lerp( lerpResult14 , ( posterize72 + grayscale75 ) , _ActivateCloak);
			float2 uv_EyesEmission1 = i.uv_texcoord * _EyesEmission1_ST.xy + _EyesEmission1_ST.zw;
			float mulTime40 = _Time.y * _PeriodGlowing1;
			float4 ifLocalVar47 = 0;
			if( _ActivateCloak == 1.0 )
				ifLocalVar47 = ( tex2D( _EyesEmission1, uv_EyesEmission1 ) * saturate( sin( mulTime40 ) ) );
			o.Emission = ( lerpResult15 + ifLocalVar47 ).rgb;
			float2 uv_PumpingParts1 = i.uv_texcoord * _PumpingParts1_ST.xy + _PumpingParts1_ST.zw;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float mulTime51 = _Time.y * 2.0;
			float2 uv_DisplacementMap1 = i.uv_texcoord * _DisplacementMap1_ST.xy + _DisplacementMap1_ST.zw;
			o.Metallic = ( ( tex2D( _PumpingParts1, uv_PumpingParts1 ) + float4( ase_vertex3Pos , 0.0 ) + sin( mulTime51 ) ) * tex2D( _DisplacementMap1, uv_DisplacementMap1 ) ).r;
			float2 uv_Specular1 = i.uv_texcoord * _Specular1_ST.xy + _Specular1_ST.zw;
			o.Smoothness = tex2D( _Specular1, uv_Specular1 ).r;
			float2 uv_AmbientOcclusion1 = i.uv_texcoord * _AmbientOcclusion1_ST.xy + _AmbientOcclusion1_ST.zw;
			o.Occlusion = tex2D( _AmbientOcclusion1, uv_AmbientOcclusion1 ).r;
			o.Alpha = _Opacity;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

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
				surfIN.worldRefl = -worldViewDir;
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
407;467;1137;585;3110.053;-341.4816;1;True;False
Node;AmplifyShaderEditor.RangedFloatNode;7;-3208.389,180.7422;Inherit;False;Property;_TimeScaleNoise;TimeScaleNoise;1;0;Create;True;0;0;False;0;2;-4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-3026.483,-226.0857;Inherit;False;Property;_TilingCloakNoise;TilingCloakNoise;0;0;Create;True;0;0;False;0;15;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;6;-2959.631,128.1935;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-2753.057,-194.3725;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VoronoiNode;2;-2505.948,-179.9335;Inherit;True;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;2;FLOAT;0;FLOAT;1
Node;AmplifyShaderEditor.WorldReflectionVector;69;-3094.846,548.0162;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;68;-3081.352,342.2191;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;31;-2210.974,-576.1378;Inherit;False;Property;_NoisePower;NoisePower;14;0;Create;True;0;0;False;0;0;-4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;16;-3457.719,-636.9073;Inherit;True;Property;_Normal;Normal;9;0;Create;True;0;0;False;0;-1;None;273ecc34bf0df054e8bfcc48d04e49ee;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;11;-2620.993,84.5464;Inherit;False;Property;_CloakTint;CloakTint;6;0;Create;True;0;0;False;0;0,0.5402541,1,0;0,0.6732655,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;39;-1513.572,-721.1599;Inherit;False;Property;_PeriodGlowing1;PeriodGlowing;13;0;Create;True;0;0;False;0;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-3435.654,-898.3788;Inherit;True;Property;_Albedo;Albedo;3;0;Create;True;0;0;False;0;-1;3bae34aab64e7a849b871eb540c85cbf;3bae34aab64e7a849b871eb540c85cbf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;28;-2172.247,-400.553;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;17;-3085.887,-650.2909;Inherit;False;Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DistanceOpNode;67;-2798.416,420.6736;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;40;-1310.784,-776.0865;Inherit;False;1;0;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-2690,723.4498;Inherit;False;Property;_CloakValue;CloakValue;15;0;Create;True;0;0;False;0;0;0.36;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-2199.643,-104.9993;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;30;-1933.454,-374.1119;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;-4;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-3055.068,-889.46;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-2492.637,512.5922;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;-2243.282,707.1281;Inherit;False;17;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SinOpNode;41;-1121.43,-801.2098;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;12;-1622.546,-518.9263;Inherit;False;9;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1766.8,-228.9885;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCGrayscale;75;-1975.319,652.4249;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;43;-857.5918,-746.9158;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;51;-1313.266,1323.182;Inherit;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-1526.782,50.59927;Inherit;False;Property;_ActivateCloak;ActivateCloak;11;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;42;-1025.138,-1034.409;Inherit;True;Property;_EyesEmission1;EyesEmission;10;0;Create;True;0;0;False;0;-1;None;892b9e4b3c0a8ac4e8e956d838fb2e3d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;13;-1472.347,-334.756;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosterizeNode;72;-2109.132,377.7559;Inherit;True;26;2;1;COLOR;0,0,0,0;False;0;INT;26;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;52;-1220.301,761.4884;Inherit;True;Property;_PumpingParts1;PumpingParts;8;0;Create;True;0;0;False;0;-1;None;b3f262f2ea0a1b946aaf412596ccceed;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;53;-1139.385,1240.427;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-711.026,-324.98;Inherit;False;Constant;_CloakTrueValue;CloakTrueValue;14;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;14;-1201.467,-494.0452;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;54;-1164.047,995.4058;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-687.8359,-776.1295;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;74;-1696.066,467.8456;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;55;-851.6024,1176.362;Inherit;True;Property;_DisplacementMap1;DisplacementMap;5;0;Create;True;0;0;False;0;-1;None;5d86ad3f68d19664f99caa1fcda32df8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ConditionalIfNode;47;-417.5998,-562.3322;Inherit;True;False;5;0;FLOAT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;-812.3324,929.1034;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;15;-774.5198,-82.45862;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-449.4754,1044.893;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-140.1367,-3.026703;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;50;-670.9146,526.5942;Inherit;True;Property;_AmbientOcclusion1;AmbientOcclusion;4;0;Create;True;0;0;False;0;-1;None;cd9b5ceb0044b3d45b5843654c351e19;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;18;86.43448,-63.43184;Inherit;False;17;Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;49;-660.4616,297.177;Inherit;True;Property;_Specular1;Specular;7;0;Create;True;0;0;False;0;-1;None;b6f9c35186fa35644a797ff1ec8c2699;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;20;-336.7422,351.5374;Inherit;False;Property;_Opacity;Opacity;12;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;278.7288,-8.040253;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;TallGray_Melee_PBRTransparent;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;5;True;True;0;True;TransparentCutout;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;69;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;2;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;7;0
WireConnection;3;0;4;0
WireConnection;3;1;6;0
WireConnection;2;0;3;0
WireConnection;2;1;6;0
WireConnection;28;0;2;0
WireConnection;17;0;16;0
WireConnection;67;0;68;0
WireConnection;67;1;69;0
WireConnection;40;0;39;0
WireConnection;10;0;2;0
WireConnection;10;1;11;0
WireConnection;30;0;28;0
WireConnection;30;1;31;0
WireConnection;9;0;8;0
WireConnection;70;0;67;0
WireConnection;70;1;71;0
WireConnection;41;0;40;0
WireConnection;29;0;30;0
WireConnection;29;1;10;0
WireConnection;75;0;73;0
WireConnection;43;0;41;0
WireConnection;13;0;12;0
WireConnection;13;1;29;0
WireConnection;72;1;70;0
WireConnection;53;0;51;0
WireConnection;14;0;12;0
WireConnection;14;1;13;0
WireConnection;14;2;21;0
WireConnection;44;0;42;0
WireConnection;44;1;43;0
WireConnection;74;0;72;0
WireConnection;74;1;75;0
WireConnection;47;0;21;0
WireConnection;47;1;48;0
WireConnection;47;3;44;0
WireConnection;56;0;52;0
WireConnection;56;1;54;0
WireConnection;56;2;53;0
WireConnection;15;0;14;0
WireConnection;15;1;74;0
WireConnection;15;2;21;0
WireConnection;57;0;56;0
WireConnection;57;1;55;0
WireConnection;46;0;15;0
WireConnection;46;1;47;0
WireConnection;0;1;18;0
WireConnection;0;2;46;0
WireConnection;0;3;57;0
WireConnection;0;4;49;0
WireConnection;0;5;50;0
WireConnection;0;9;20;0
ASEEND*/
//CHKSM=C1043769BDC53B8F8EC7E8728D9B1EDB2451AE0C