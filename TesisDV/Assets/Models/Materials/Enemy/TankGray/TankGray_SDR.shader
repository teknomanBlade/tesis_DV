// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TankGray_SDR"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.75
		_Levels1("Levels", Range( 0 , 100)) = 71
		_NoiseDirection("NoiseDirection", Vector) = (0,1,0,0)
		_NoiseScrollspeed("NoiseScrollspeed", Float) = 1
		_NoiseScale("NoiseScale", Vector) = (2,2,0,0)
		_MainTexture("Main Texture", 2D) = "white" {}
		_EdgeThickness("EdgeThickness", Range( 0 , 0.3)) = 0
		_Tint1("Tint", Color) = (0,0,0,0)
		[HDR]_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		_LightIntensity1("LightIntensity", Range( 0 , 5)) = 0
		[Toggle]_VertexPosition("VertexPosition", Float) = 1
		_LerpLightDir1("LerpLightDir", Range( 0 , 1)) = 0
		_DissolveDirection("DissolveDirection", Vector) = (0,1,0,0)
		_UpperLimit("UpperLimit", Float) = -5
		_LowerLimit("LowerLimit", Float) = 5
		_ScaleDissolveGray("ScaleDissolveGray", Range( 0 , 1)) = 0.4301261
		_ElectricityEffect("ElectricityEffect", Range( 0 , 0.4)) = 0
		_PaintStains("Paint Stains", 2D) = "white" {}
		_LerpStains("LerpStains", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
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

		uniform float4 _EdgeColor;
		uniform float _VertexPosition;
		uniform float3 _DissolveDirection;
		uniform float _ScaleDissolveGray;
		uniform float _UpperLimit;
		uniform float _LowerLimit;
		uniform float3 _NoiseDirection;
		uniform float _NoiseScrollspeed;
		uniform float2 _NoiseScale;
		uniform float _EdgeThickness;
		uniform float _ElectricityEffect;
		uniform float4 _Tint1;
		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform sampler2D _PaintStains;
		uniform float4 _PaintStains_ST;
		uniform float _LerpStains;
		uniform float _LerpLightDir1;
		uniform float _Levels1;
		uniform float _LightIntensity1;
		uniform float _Cutoff = 0.75;


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
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
			float3 ase_worldPos = i.worldPos;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 normalizeResult30 = normalize( (( _VertexPosition )?( ase_vertex3Pos ):( ase_worldPos )) );
			float3 normalizeResult32 = normalize( _DissolveDirection );
			float dotResult37 = dot( normalizeResult30 , normalizeResult32 );
			float Fade47 = ( dotResult37 + (-_UpperLimit + (_ScaleDissolveGray - 0.0) * (-_LowerLimit - -_UpperLimit) / (1.0 - 0.0)) );
			float3 normalizeResult22 = normalize( _NoiseDirection );
			float simplePerlin3D48 = snoise( ( ase_vertex3Pos + ( ( normalizeResult22 * _NoiseScrollspeed ) * _Time.y ) )*_NoiseScale.x );
			simplePerlin3D48 = simplePerlin3D48*0.5 + 0.5;
			float Noise53 = simplePerlin3D48;
			float temp_output_58_0 = ( ( 1.0 - Fade47 ) * Noise53 );
			float temp_output_66_0 = ( temp_output_58_0 - Fade47 );
			float2 uv_MainTexture = i.uv_texcoord * _MainTexture_ST.xy + _MainTexture_ST.zw;
			float4 tex2DNode67 = tex2D( _MainTexture, uv_MainTexture );
			float2 uv_PaintStains = i.uv_texcoord * _PaintStains_ST.xy + _PaintStains_ST.zw;
			float4 tex2DNode84 = tex2D( _PaintStains, uv_PaintStains );
			float4 lerpResult96 = lerp( tex2DNode67 , ( tex2DNode67 + ( ( tex2DNode67 * tex2DNode84.a ) * tex2DNode84 ) ) , _LerpStains);
			float4 Albedo116 = ( _Tint1 * lerpResult96 );
			float3 ase_worldNormal = i.worldNormal;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult106 = dot( ase_worldNormal , ase_worldlightDir );
			float3 temp_cast_3 = (ase_worldNormal.x).xxx;
			float dotResult107 = dot( temp_cast_3 , ase_worldlightDir );
			float lerpResult109 = lerp( dotResult106 , dotResult107 , _LerpLightDir1);
			float Normal_LightDir110 = lerpResult109;
			float4 temp_cast_5 = (Normal_LightDir110).xxxx;
			float div118=256.0/float((int)(Normal_LightDir110*_Levels1 + _Levels1));
			float4 posterize118 = ( floor( temp_cast_5 * div118 ) / div118 );
			float4 Shadow121 = ( Albedo116 * posterize118 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 LightColor128 = ( Shadow121 * ase_lightColor * _LightIntensity1 );
			c.rgb = saturate( ( LightColor128 * ( 1.0 - step( ase_lightAtten , 0.33 ) ) ) ).rgb;
			c.a = 1;
			clip( temp_output_66_0 - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float3 ase_worldPos = i.worldPos;
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 normalizeResult30 = normalize( (( _VertexPosition )?( ase_vertex3Pos ):( ase_worldPos )) );
			float3 normalizeResult32 = normalize( _DissolveDirection );
			float dotResult37 = dot( normalizeResult30 , normalizeResult32 );
			float Fade47 = ( dotResult37 + (-_UpperLimit + (_ScaleDissolveGray - 0.0) * (-_LowerLimit - -_UpperLimit) / (1.0 - 0.0)) );
			float3 normalizeResult22 = normalize( _NoiseDirection );
			float simplePerlin3D48 = snoise( ( ase_vertex3Pos + ( ( normalizeResult22 * _NoiseScrollspeed ) * _Time.y ) )*_NoiseScale.x );
			simplePerlin3D48 = simplePerlin3D48*0.5 + 0.5;
			float Noise53 = simplePerlin3D48;
			float temp_output_58_0 = ( ( 1.0 - Fade47 ) * Noise53 );
			float temp_output_66_0 = ( temp_output_58_0 - Fade47 );
			float4 color80 = IsGammaSpace() ? float4(0,1,0.9999998,0) : float4(0,1,0.9999997,0);
			float4 lerpResult83 = lerp( ( _EdgeColor * step( temp_output_66_0 , ( _EdgeThickness + (0.0 + (0.0 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)) ) ) ) , ( temp_output_58_0 * color80 ) , _ElectricityEffect);
			o.Emission = lerpResult83.rgb;
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
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
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
410;591;1307;575;4460.922;-113.8352;3.693081;True;False
Node;AmplifyShaderEditor.CommentaryNode;98;-2908.17,455.6135;Inherit;False;2035.601;889.5018;Albedo;10;96;89;95;94;92;84;67;116;114;111;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;84;-2833.975,1021.237;Inherit;True;Property;_PaintStains;Paint Stains;17;0;Create;True;0;0;False;0;-1;None;396f2e04959cc10499a12c955885d792;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;67;-2785.391,814.8389;Inherit;True;Property;_MainTexture;Main Texture;5;0;Create;True;0;0;False;0;-1;None;174e8780559bee947b251d6158439000;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;97;-3136.232,1491.477;Inherit;False;1038.711;763.5355;Normal LightDir;9;110;109;108;107;106;105;104;103;102;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;102;-3040.53,2056.252;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;103;-3084.232,1698.984;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;104;-3068.232,1538.984;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-2415.157,942.3959;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldNormalVector;105;-3027.709,1880.35;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;107;-2778.268,1848.846;Inherit;True;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-2786.51,2125.869;Inherit;False;Property;_LerpLightDir1;LerpLightDir;11;0;Create;True;0;0;False;0;0;0.196;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;106;-2844.23,1586.984;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;8;-3132.597,-1950.302;Inherit;False;1987.844;732.4697;Comment;11;53;48;45;43;41;38;31;29;24;22;12;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;7;-2988.597,-638.3013;Inherit;False;1738.878;722.5874;Comment;14;47;46;39;37;35;33;32;30;23;21;19;18;11;10;Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-2187.771,993.2859;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-1988.425,1206.644;Inherit;False;Property;_LerpStains;LerpStains;18;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;95;-1947.711,789.6157;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;12;-3084.597,-1678.301;Inherit;False;Property;_NoiseDirection;NoiseDirection;2;0;Create;True;0;0;False;0;0,1,0;0,0,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;10;-2908.597,-542.3013;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;11;-2908.597,-398.3013;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;109;-2487.423,1729.459;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;-0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;22;-2892.597,-1614.301;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-2972.597,-110.3011;Inherit;False;Property;_LowerLimit;LowerLimit;14;0;Create;True;0;0;False;0;5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;19;-2636.597,-558.3013;Inherit;False;Property;_VertexPosition;VertexPosition;10;0;Create;True;0;0;False;0;1;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;21;-2604.597,-318.3013;Inherit;False;Property;_DissolveDirection;DissolveDirection;12;0;Create;True;0;0;False;0;0,1,0;0,0,1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;24;-3020.597,-1468.651;Inherit;False;Property;_NoiseScrollspeed;NoiseScrollspeed;3;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;111;-1731.727,543.2646;Inherit;False;Property;_Tint1;Tint;7;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;96;-1624.776,823.6387;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;-2300.084,1824.642;Inherit;False;Normal_LightDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;99;-1964.035,1814.097;Inherit;False;1371.36;494.1964;Shadow;7;121;120;119;118;117;115;113;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-2956.597,-222.3011;Inherit;False;Property;_UpperLimit;UpperLimit;13;0;Create;True;0;0;False;0;-5;-2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;30;-2348.597,-526.3013;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-2700.597,-1598.301;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TimeNode;31;-3020.597,-1374.301;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;32;-2380.597,-302.3013;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-2742.038,265.6738;Inherit;False;Property;_ScaleDissolveGray;ScaleDissolveGray;15;0;Create;True;0;0;False;0;0.4301261;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;35;-2780.597,-206.3011;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;33;-2780.597,-110.3011;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-1884.035,1958.097;Inherit;False;110;Normal_LightDir;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-1421.101,695.6913;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;115;-1900.035,2166.097;Inherit;False;Property;_Levels1;Levels;1;0;Create;True;0;0;False;0;71;15;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;39;-2140.597,-30.30115;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-2636.597,-1486.301;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;37;-2124.597,-302.3013;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;117;-1612.036,2102.096;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;116;-1086.483,875.8015;Inherit;False;Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;38;-3036.597,-1870.302;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;43;-2268.597,-1502.301;Inherit;False;Property;_NoiseScale;NoiseScale;4;0;Create;True;0;0;False;0;2,2;5,5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PosterizeNode;118;-1404.036,2054.097;Inherit;True;30;2;1;COLOR;0,0,0,0;False;0;INT;30;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-1820.597,-270.3011;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-2460.597,-1758.302;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;-1420.036,1878.097;Inherit;False;116;Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;-1116.035,1958.097;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-1532.597,-270.3011;Inherit;True;Fade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;48;-2044.597,-1774.302;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;121;-844.0347,2022.097;Inherit;False;Shadow;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-990.7139,-1102.301;Inherit;True;47;Fade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;53;-1372.597,-1646.301;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;100;-1868.035,2502.096;Inherit;False;1202.176;506.8776;Light Color;5;128;125;124;123;122;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-956.5967,-910.3013;Inherit;True;53;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;55;-652.5967,-286.3013;Inherit;False;820.2998;637.5504;GLow;5;71;70;65;61;59;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;123;-1836.036,2870.096;Inherit;False;Property;_LightIntensity1;LightIntensity;9;0;Create;True;0;0;False;0;0;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;-1708.035,2582.096;Inherit;False;121;Shadow;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;54;-714.1758,-1166.278;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;124;-1836.036,2710.096;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;126;-650.5085,1651.57;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;61;-604.5967,17.69885;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;125;-1436.035,2694.096;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-652.5967,-110.3011;Inherit;False;Property;_EdgeThickness;EdgeThickness;6;0;Create;True;0;0;False;0;0;0.3;0;0.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;60;-940.5967,-670.3013;Inherit;True;47;Fade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-465.0459,-1095.171;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-412.5967,1.698853;Inherit;True;2;2;0;FLOAT;0.01;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;66;-254.1306,-850.7871;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;127;-390.9844,1525.816;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.33;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;128;-908.0357,2662.096;Inherit;False;LightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;71;-172.5967,145.6989;Inherit;False;Property;_EdgeColor;EdgeColor;8;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,0.7137255,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;129;-148.05,1489.047;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;130;-196.1921,1198.733;Inherit;True;128;LightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;70;-172.5967,-158.3011;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;80;123.2956,-723.735;Inherit;False;Constant;_Color0;Color 0;21;0;Create;True;0;0;False;0;0,1,0.9999998,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;101;-2972.038,2358.097;Inherit;False;787.1289;475.5013;Normal ViewDir;4;135;134;133;132;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;392.4685,-894.9039;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;128.781,1333.747;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;82;391.2156,-519.5309;Inherit;False;Property;_ElectricityEffect;ElectricityEffect;16;0;Create;True;0;0;False;0;0;0;0;0.4;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;291.4033,-30.30115;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;83;769.3475,-665.5228;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldNormalVector;132;-2908.038,2422.097;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;133;-2380.036,2566.096;Inherit;False;Normal_ViewDir;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;134;-2892.037,2614.096;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;135;-2668.036,2454.097;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;72;728.2927,833.5127;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1412.649,34.87128;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;TankGray_SDR;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.75;True;True;0;True;Transparent;;AlphaTest;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;92;0;67;0
WireConnection;92;1;84;4
WireConnection;107;0;105;1
WireConnection;107;1;102;0
WireConnection;106;0;104;0
WireConnection;106;1;103;0
WireConnection;94;0;92;0
WireConnection;94;1;84;0
WireConnection;95;0;67;0
WireConnection;95;1;94;0
WireConnection;109;0;106;0
WireConnection;109;1;107;0
WireConnection;109;2;108;0
WireConnection;22;0;12;0
WireConnection;19;0;10;0
WireConnection;19;1;11;0
WireConnection;96;0;67;0
WireConnection;96;1;95;0
WireConnection;96;2;89;0
WireConnection;110;0;109;0
WireConnection;30;0;19;0
WireConnection;29;0;22;0
WireConnection;29;1;24;0
WireConnection;32;0;21;0
WireConnection;35;0;23;0
WireConnection;33;0;18;0
WireConnection;114;0;111;0
WireConnection;114;1;96;0
WireConnection;39;0;28;0
WireConnection;39;3;35;0
WireConnection;39;4;33;0
WireConnection;41;0;29;0
WireConnection;41;1;31;2
WireConnection;37;0;30;0
WireConnection;37;1;32;0
WireConnection;117;0;113;0
WireConnection;117;1;115;0
WireConnection;117;2;115;0
WireConnection;116;0;114;0
WireConnection;118;1;113;0
WireConnection;118;0;117;0
WireConnection;46;0;37;0
WireConnection;46;1;39;0
WireConnection;45;0;38;0
WireConnection;45;1;41;0
WireConnection;120;0;119;0
WireConnection;120;1;118;0
WireConnection;47;0;46;0
WireConnection;48;0;45;0
WireConnection;48;1;43;0
WireConnection;121;0;120;0
WireConnection;53;0;48;0
WireConnection;54;0;52;0
WireConnection;125;0;122;0
WireConnection;125;1;124;0
WireConnection;125;2;123;0
WireConnection;58;0;54;0
WireConnection;58;1;57;0
WireConnection;65;0;59;0
WireConnection;65;1;61;0
WireConnection;66;0;58;0
WireConnection;66;1;60;0
WireConnection;127;0;126;0
WireConnection;128;0;125;0
WireConnection;129;0;127;0
WireConnection;70;0;66;0
WireConnection;70;1;65;0
WireConnection;81;0;58;0
WireConnection;81;1;80;0
WireConnection;131;0;130;0
WireConnection;131;1;129;0
WireConnection;73;0;71;0
WireConnection;73;1;70;0
WireConnection;83;0;73;0
WireConnection;83;1;81;0
WireConnection;83;2;82;0
WireConnection;133;0;135;0
WireConnection;135;0;132;0
WireConnection;135;1;134;0
WireConnection;72;0;131;0
WireConnection;0;2;83;0
WireConnection;0;10;66;0
WireConnection;0;13;72;0
ASEEND*/
//CHKSM=6EF5E8DACE8473A9457819FE359F5C989985F640