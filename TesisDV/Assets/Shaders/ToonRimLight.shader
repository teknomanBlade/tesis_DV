// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EdShaders/ToonRimLight"
{
	Properties
	{
		_ToonRamp("Toon Ramp", 2D) = "white" {}
		_RimPower("Rim Power", Range( 0 , 10)) = 0.5
		_RimOffset("Rim Offset", Float) = 0.24
		_Diffuse("Diffuse", 2D) = "white" {}
		_EdgeSaturation("Edge Saturation", Float) = 1
		_OutlineLightOverride("Outline Light Override", Range( 0 , 1)) = 0.02
		_OutlineWidth("Outline Width", Range( 0 , 0.1)) = 0.02
		_OutlineBrightness("Outline Brightness", Float) = 0
		_OutlineColour("Outline Colour", Color) = (0,0,0,0)
		_PointLightAttenuationSteps("Point Light Attenuation Steps", Float) = 6
		[Toggle]_IncludeTextureinSaturationBoost("Include Texture in Saturation Boost", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 ase_vertexNormal = v.normal.xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult106 = dot( ase_vertexNormal , ase_worldlightDir );
			float outlineVar = ( _OutlineWidth * saturate( ( ( 1.0 - saturate( ase_lightColor.a ) ) + saturate( ( 1.0 - ( dotResult106 + 0.1 ) ) ) + _OutlineLightOverride ) ) );
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			o.Emission = ( _OutlineColour * _OutlineBrightness ).rgb;
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float3 worldPos;
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

		uniform float _IncludeTextureinSaturationBoost;
		uniform sampler2D _Diffuse;
		uniform float4 _Diffuse_ST;
		uniform float _PointLightAttenuationSteps;
		uniform sampler2D _ToonRamp;
		uniform float _RimOffset;
		uniform float _RimPower;
		uniform float _EdgeSaturation;
		uniform float _OutlineWidth;
		uniform float _OutlineLightOverride;
		uniform float4 _OutlineColour;
		uniform float _OutlineBrightness;


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			v.vertex.xyz += 0;
		}

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
			float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
			float4 tex2DNode43 = tex2D( _Diffuse, uv_Diffuse );
			float temp_output_121_0 = ( ase_lightAtten * _PointLightAttenuationSteps );
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult3 = dot( ase_worldNormal , ase_worldlightDir );
			float temp_output_15_0 = saturate( (dotResult3*0.5 + 0.5) );
			float dotResult38 = dot( ase_worldNormal , i.viewDir );
			float RimMask79 = pow( ( 1.0 - saturate( ( dotResult38 + _RimOffset ) ) ) , _RimPower );
			float dotResult61 = dot( -i.viewDir , ase_worldlightDir );
			float2 temp_cast_1 = (( saturate( ( temp_output_15_0 + saturate( ( ase_lightAtten + _WorldSpaceLightPos0.w ) ) ) ) * ( ( RimMask79 * saturate( dotResult61 ) ) + temp_output_15_0 ) )).xx;
			float4 tex2DNode6 = tex2D( _ToonRamp, temp_cast_1 );
			float ToonNdotL77 = tex2DNode6.r;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 hsvTorgb4_g1 = RGBToHSV( ( ase_lightColor * saturate( ( lerp(1.0,0.0,_IncludeTextureinSaturationBoost) + tex2DNode43 ) ) ).rgb );
			float temp_output_72_0 = ( ( 1.0 - tex2DNode6.b ) * 0.5 );
			float3 hsvTorgb8_g1 = HSVToRGB( float3(( hsvTorgb4_g1.x + temp_output_72_0 ),( hsvTorgb4_g1.y + ( ( tex2DNode6.g + RimMask79 + temp_output_72_0 ) * _EdgeSaturation ) ),( hsvTorgb4_g1.z + 0.0 )) );
			c.rgb = ( saturate( ( ( 1.0 - lerp(1.0,0.0,_IncludeTextureinSaturationBoost) ) + tex2DNode43 ) ) * float4( ( ( saturate( ( ( 1.0 - _WorldSpaceLightPos0.w ) + ( round( temp_output_121_0 ) / _PointLightAttenuationSteps ) ) ) * ToonNdotL77 ) * saturate( hsvTorgb8_g1 ) ) , 0.0 ) ).rgb;
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
			o.Emission = UNITY_LIGHTMODEL_AMBIENT.rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 

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
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
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
Version=16800
393;288;1906;1021;4127.273;1778.951;4.158376;True;True
Node;AmplifyShaderEditor.CommentaryNode;49;-3486.292,-965.5445;Float;False;507.201;385.7996;Comment;3;36;37;38;N . V;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;50;-2858.77,-953.1841;Float;False;1288.905;478.0881;;7;30;29;28;27;25;24;79;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;36;-3438.292,-917.5448;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;37;-3390.292,-757.5449;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;24;-2778.77,-681.184;Float;False;Property;_RimOffset;Rim Offset;2;0;Create;True;0;0;False;0;0.24;0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;38;-3134.292,-837.545;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;48;-2604.121,-46.96078;Float;False;540.401;320.6003;Comment;3;1;3;2;N . L;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;78;-1482.802,-800.619;Float;False;948.8068;506.2413;Comment;7;64;61;59;60;62;63;58;Light Wrap Rim;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-2570.769,-793.184;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;58;-1432.802,-733.1711;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;2;-2540.121,161.0393;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;27;-2410.769,-793.184;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;1;-2492.121,1.039217;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;51;-1709.438,-164.7096;Float;False;723.599;290;Also know as Lambert Wrap or Half Lambert;3;5;4;15;Diffuse Wrap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;94;-1618.37,409.3994;Float;False;1184.111;710.0645;;11;123;120;92;91;122;93;127;121;124;90;85;Point Light Attenuation Soft Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;3;-2204.121,65.03924;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;59;-1228.052,-717.2859;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-2346.769,-665.184;Float;False;Property;_RimPower;Rim Power;1;0;Create;True;0;0;False;0;0.5;0.7;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;65;-1362.804,181.6979;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;60;-1435.249,-510.6295;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;29;-2234.769,-793.184;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;85;-1317.937,459.3994;Float;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;5;-1659.438,10.29036;Float;False;Constant;_WrapperValue;Wrapper Value;0;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;4;-1394.036,-114.7096;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;125;-1064.923,196.2749;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;30;-2042.769,-793.184;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;61;-1101.718,-595.9122;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;15;-1160.839,-107.91;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;126;-880.6193,217.7993;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;79;-1794.183,-765.6219;Float;False;RimMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;64;-972.2211,-582.9735;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-846.8452,-55.72789;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-810.6138,-614.1736;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;82;-709.8836,-39.28242;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;63;-665.9835,-615.1584;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;136;160.4025,1690.689;Float;False;1805.298;751.3068;;17;105;104;106;135;110;133;132;130;134;131;107;101;99;102;108;103;98;Outline;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;124;-1468.507,1002.097;Float;False;Property;_PointLightAttenuationSteps;Point Light Attenuation Steps;9;0;Create;True;0;0;False;0;6;3.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;90;-1338.571,577.7899;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-524.8389,-83.69728;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;104;482.9965,1968.355;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;105;439.2329,2146.897;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;6;-333.6906,-93.39909;Float;True;Property;_ToonRamp;Toon Ramp;0;0;Create;True;0;0;False;0;52e66a9243cdfed44b5e906f5910d35b;b95db1a65c4d1d6489313603708e1063;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;-1153.711,914.6539;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;106;700.7346,2069.641;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;97;-35.20629,273.8762;Float;False;1255.156;672.975;;8;96;57;8;56;71;95;67;72;Edge Saturation and backfacing hue shift;1,1,1,1;0;0
Node;AmplifyShaderEditor.RoundOpNode;127;-951.1843,869.3184;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;145;-450.3042,1244.593;Float;False;Property;_IncludeTextureinSaturationBoost;Include Texture in Saturation Boost;10;0;Create;True;0;0;False;0;1;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;43;-503.463,1413.5;Float;True;Property;_Diffuse;Diffuse;3;0;Create;True;0;0;False;0;84508b93f15f2b64386ec07486afc7a3;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;135;835.7897,2075.866;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;8;40.06291,731.6876;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;67;396.7483,323.8762;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;72;671.8268,421.6549;Float;False;0.5;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;143;-47.57329,1102.782;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;95;14.79371,457.8009;Float;False;79;RimMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;93;-1008.978,473.9491;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;110;969.7583,2087.919;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;122;-781.0691,956.3577;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;133;210.4025,2256.827;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;228.24,396.4576;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;144;274.2208,987.4604;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;134;948.8837,2326.996;Float;False;Property;_OutlineLightOverride;Outline Light Override;5;0;Create;True;0;0;False;0;0.02;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;132;1137.364,2129.416;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;-949.0901,550.55;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;130;395.0565,2290.065;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;240.1485,533.0564;Float;False;Property;_EdgeSaturation;Edge Saturation;4;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;139;-5.034878,1269.56;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;80.21562,-128.0357;Float;False;ToonNdotL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;92;-645.4559,585.3992;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;525.0857,753.8966;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;526.0392,488.5156;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;131;1305.4,2181.118;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;141;284.5903,1392.622;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;1124.737,-160.672;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;102;1529.891,2043.354;Float;False;Property;_OutlineColour;Outline Colour;8;0;Create;True;0;0;False;0;0,0,0,0;0.1409754,0.170893,0.9056604,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;101;1489.048,2278.457;Float;False;Property;_OutlineBrightness;Outline Brightness;7;0;Create;True;0;0;False;0;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;99;1310.326,1740.689;Float;False;Property;_OutlineWidth;Outline Width;6;0;Create;True;0;0;False;0;0.02;0.04;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;107;1324.923,2004.804;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;71;943.9498,507.5983;Float;False;HueShift;-1;;1;9f07e9ddd8ab81c47b3582f22189b65b;0;4;14;COLOR;0,0,0,0;False;15;FLOAT;0;False;16;FLOAT;0;False;17;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;142;661.2515,1401.468;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;1307.714,263.9403;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;1788.583,2100.253;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;108;1527.35,1795.654;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleNode;120;-1091.828,685.9565;Float;False;5;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;1775.991,432.577;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FloorOpNode;123;-965.3722,944.2501;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OutlineNode;98;1715.701,1782.873;Float;False;0;True;None;0;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;129;1661.868,221.6564;Float;False;UNITY_LIGHTMODEL_AMBIENT;0;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2032.157,335.607;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;EdShaders/ToonRimLight;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0.02;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;38;0;36;0
WireConnection;38;1;37;0
WireConnection;25;0;38;0
WireConnection;25;1;24;0
WireConnection;27;0;25;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;59;0;58;0
WireConnection;29;0;27;0
WireConnection;4;0;3;0
WireConnection;4;1;5;0
WireConnection;4;2;5;0
WireConnection;125;0;65;0
WireConnection;125;1;85;2
WireConnection;30;0;29;0
WireConnection;30;1;28;0
WireConnection;61;0;59;0
WireConnection;61;1;60;0
WireConnection;15;0;4;0
WireConnection;126;0;125;0
WireConnection;79;0;30;0
WireConnection;64;0;61;0
WireConnection;81;0;15;0
WireConnection;81;1;126;0
WireConnection;62;0;79;0
WireConnection;62;1;64;0
WireConnection;82;0;81;0
WireConnection;63;0;62;0
WireConnection;63;1;15;0
WireConnection;66;0;82;0
WireConnection;66;1;63;0
WireConnection;6;1;66;0
WireConnection;121;0;90;0
WireConnection;121;1;124;0
WireConnection;106;0;104;0
WireConnection;106;1;105;0
WireConnection;127;0;121;0
WireConnection;135;0;106;0
WireConnection;67;0;6;3
WireConnection;72;0;67;0
WireConnection;143;0;145;0
WireConnection;143;1;43;0
WireConnection;93;0;85;2
WireConnection;110;0;135;0
WireConnection;122;0;127;0
WireConnection;122;1;124;0
WireConnection;133;0;8;2
WireConnection;96;0;6;2
WireConnection;96;1;95;0
WireConnection;96;2;72;0
WireConnection;144;0;143;0
WireConnection;132;0;110;0
WireConnection;91;0;93;0
WireConnection;91;1;122;0
WireConnection;130;0;133;0
WireConnection;139;0;145;0
WireConnection;77;0;6;1
WireConnection;92;0;91;0
WireConnection;137;0;8;0
WireConnection;137;1;144;0
WireConnection;56;0;96;0
WireConnection;56;1;57;0
WireConnection;131;0;130;0
WireConnection;131;1;132;0
WireConnection;131;2;134;0
WireConnection;141;0;139;0
WireConnection;141;1;43;0
WireConnection;89;0;92;0
WireConnection;89;1;77;0
WireConnection;107;0;131;0
WireConnection;71;14;137;0
WireConnection;71;15;72;0
WireConnection;71;16;56;0
WireConnection;142;0;141;0
WireConnection;73;0;89;0
WireConnection;73;1;71;0
WireConnection;103;0;102;0
WireConnection;103;1;101;0
WireConnection;108;0;99;0
WireConnection;108;1;107;0
WireConnection;120;0;90;0
WireConnection;76;0;142;0
WireConnection;76;1;73;0
WireConnection;123;0;121;0
WireConnection;98;0;103;0
WireConnection;98;1;108;0
WireConnection;0;2;129;0
WireConnection;0;13;76;0
WireConnection;0;11;98;0
ASEEND*/
//CHKSM=B09105A725A1D88F7169887BA6F2573157A5F1F7